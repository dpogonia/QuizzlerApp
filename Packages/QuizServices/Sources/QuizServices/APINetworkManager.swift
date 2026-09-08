import CoreServices
import Foundation
import UIKit

public enum QuizAPIError: LocalizedError {
    case southParkImageNotFound

    public var errorDescription: String? {
        switch self {
        case .southParkImageNotFound:
            return "Не удалось найти картинку персонажа."
        }
    }
}

public protocol QuizNetworking: Sendable {
    func fetchRMCharacters(page: Int) async throws -> [RMCharacter]
    func fetchSPCharacters(page: Int) async throws -> [SPCharacter]
    func fetchBMCharacters() async throws -> [BMCharacter]
    func fetchImage(from urlString: String) async throws -> UIImage
}

public final class APINetworkManager: QuizNetworking, @unchecked Sendable {
    private let network: any NetworkServing
    private let parser: any JSONParsing
    private let imageCache = NSCache<NSString, UIImage>()

    public init(
        network: any NetworkServing = ServiceLocator.shared.resolve(),
        parser: any JSONParsing = ServiceLocator.shared.resolve()
    ) {
        self.network = network
        self.parser = parser
        imageCache.countLimit = 150
    }

    public func fetchRMCharacters(page: Int) async throws -> [RMCharacter] {
        let urlString = "https://rickandmortyapi.com/api/character/?page=\(page)"
        let response: RMAPIResponse = try await fetchJSON(urlString: urlString)
        return response.results
    }

    public func fetchSPCharacters(page: Int) async throws -> [SPCharacter] {
        let urlString = "https://spapi.dev/api/characters?page=\(page)"
        let response: SPAPIResponse = try await fetchJSON(urlString: urlString)
        return response.data
    }

    public func fetchBMCharacters() async throws -> [BMCharacter] {
        var components = URLComponents(string: "https://bigmouth.fandom.com/api.php")!
        components.queryItems = [
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "list", value: "categorymembers"),
            URLQueryItem(name: "cmtitle", value: "Category:Characters"),
            URLQueryItem(name: "cmlimit", value: "500"),
            URLQueryItem(name: "format", value: "json")
        ]
        guard let url = components.url else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.setValue("Quizzler/1.0", forHTTPHeaderField: "User-Agent")
        let data = try await network.data(for: request)
        let decoded = try parser.decode(FandomCategoryResponse.self, from: data)
        return decoded.query.categorymembers.map { BMCharacter(pageid: $0.pageid, name: $0.title) }
    }

    public func fetchImage(from urlString: String) async throws -> UIImage {
        let cacheKey = NSString(string: urlString)
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            return cachedImage
        }

        if urlString.lowercased().hasPrefix("spwiki:") {
            let name = String(urlString.dropFirst("spwiki:".count)).trimmingCharacters(in: .whitespacesAndNewlines)
            do {
                let image = try await fetchSouthParkCharacterImage(name: name)
                imageCache.setObject(image, forKey: cacheKey)
                return image
            } catch {
                let image = makeSouthParkFallbackImage()
                imageCache.setObject(image, forKey: cacheKey)
                return image
            }
        }

        if urlString.lowercased().hasPrefix("bmwiki:") {
            let name = String(urlString.dropFirst("bmwiki:".count)).trimmingCharacters(in: .whitespacesAndNewlines)
            let image = try await fetchBigMouthCharacterImage(name: name)
            imageCache.setObject(image, forKey: cacheKey)
            return image
        }

        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let data = try await network.data(from: url)
        guard let image = UIImage(data: data) else { throw URLError(.cannotDecodeRawData) }

        imageCache.setObject(image, forKey: cacheKey)
        return image
    }

    private func fetchJSON<T: Decodable>(urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let data = try await network.data(from: url)
        return try parser.decode(T.self, from: data)
    }

    private struct FandomPageImagesResponse: Decodable {
        let query: Query
        struct Query: Decodable {
            let pages: [Page]
        }
        struct Page: Decodable {
            let title: String?
            let thumbnail: Thumbnail?
        }
        struct Thumbnail: Decodable {
            let source: String
            let width: Int?
            let height: Int?
        }
    }

    private func fetchSouthParkCharacterImage(name: String) async throws -> UIImage {
        let thumbURLString = try await fetchSouthParkCharacterThumbnailURL(name: name)
        guard let url = URL(string: thumbURLString) else { throw URLError(.badURL) }
        let data = try await network.data(from: url)
        guard let image = UIImage(data: data) else { throw URLError(.cannotDecodeRawData) }
        return image
    }

    private func fetchBigMouthCharacterImage(name: String) async throws -> UIImage {
        let thumbURLString = try await fetchBigMouthCharacterThumbnailURL(name: name)
        guard let url = URL(string: thumbURLString) else { throw URLError(.badURL) }
        let data = try await network.data(from: url)
        guard let image = UIImage(data: data) else { throw URLError(.cannotDecodeRawData) }
        return image
    }

    private func fetchFandomThumbnailURL(baseAPI: String, name: String) async throws -> String {
        var components = URLComponents(string: baseAPI)!
        components.queryItems = [
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "titles", value: name),
            URLQueryItem(name: "prop", value: "pageimages"),
            URLQueryItem(name: "pithumbsize", value: "600"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "formatversion", value: "2"),
            URLQueryItem(name: "redirects", value: "1")
        ]
        guard let url = components.url else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.setValue("Quizzler/1.0", forHTTPHeaderField: "User-Agent")
        let data = try await network.data(for: request)
        let decoded = try parser.decode(FandomPageImagesResponse.self, from: data)
        guard let source = decoded.query.pages.first?.thumbnail?.source else {
            throw QuizAPIError.southParkImageNotFound
        }
        return source
    }

    private func fetchBigMouthCharacterThumbnailURL(name: String) async throws -> String {
        try await fetchFandomThumbnailURL(baseAPI: "https://bigmouth.fandom.com/api.php", name: name)
    }

    private func fetchSouthParkCharacterThumbnailURL(name: String) async throws -> String {
        try await fetchFandomThumbnailURL(baseAPI: "https://southpark.fandom.com/api.php", name: name)
    }

    private func makeSouthParkFallbackImage() -> UIImage {
        let size = CGSize(width: 600, height: 900)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor(white: 0.12, alpha: 1.0).setFill()
            ctx.fill(CGRect(origin: .zero, size: size))

            let iconSize: CGFloat = 220
            let iconRect = CGRect(
                x: (size.width - iconSize) / 2,
                y: (size.height - iconSize) / 2,
                width: iconSize,
                height: iconSize
            )
            let symbol = UIImage(systemName: "person.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
            symbol?.draw(in: iconRect)
        }
    }
}
