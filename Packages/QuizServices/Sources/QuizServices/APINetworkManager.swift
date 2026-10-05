//
//  APINetworkManager.swift
//  QuizServices
//
//  Created by Dmitrii Pogonia on 10.03.2026.
//

import CoreServices
import CryptoKit
import Foundation
import UIKit

public enum QuizAPIError: LocalizedError {
    case southParkImageNotFound

    public var errorDescription: String? {
        switch self {
        case .southParkImageNotFound:
            return NSLocalizedString("error.south_park_image", comment: "")
        }
    }
}

public protocol QuizNetworking: Sendable { // списки персонажей и картинки. не общий NetworkServing — знает URL квиза
    func fetchRMCharacters(page: Int) async throws -> [RMCharacter]
    func fetchSPCharacters(page: Int) async throws -> [SPCharacter]
    func fetchBMCharacters() async throws -> [BMCharacter]
    func fetchImage(from urlString: String) async throws -> UIImage
}

public final class APINetworkManager: QuizNetworking, @unchecked Sendable {
    private let network: any NetworkServing
    private let parser: any JSONParsing
    private let imageStore: any FileStoring
    private let imageCache = NSCache<NSString, UIImage>()

    public init(
        network: any NetworkServing,
        parser: any JSONParsing,
        imageStore: any FileStoring
    ) {
        self.network = network
        self.parser = parser
        self.imageStore = imageStore
        imageCache.countLimit = 150 // столько постеров в RAM, дальше NSCache сам выкинет
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
        request.setValue("Quizzler/1.0", forHTTPHeaderField: "User-Agent") // Fandom без UA иногда режет
        let data = try await network.data(for: request)
        let decoded = try parser.decode(FandomCategoryResponse.self, from: data)
        return decoded.query.categorymembers.map { BMCharacter(pageid: $0.pageid, name: $0.title) }
    }

    public func fetchImage(from urlString: String) async throws -> UIImage { // память → диск (sha256) → сеть. spwiki:/bmwiki: — не прямой URL, ищем thumbnail на вики
        let cacheKey = NSString(string: urlString)
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            return cachedImage
        }

        if let data = await imageStore.read(fromRelativePath: imagePath(for: urlString)),
           let image = UIImage(data: data) {
            imageCache.setObject(image, forKey: cacheKey)
            return image
        }

        if urlString.lowercased().hasPrefix("spwiki:") {
            let name = String(urlString.dropFirst("spwiki:".count)).trimmingCharacters(in: .whitespacesAndNewlines)
            let image = try await fetchSouthParkCharacterImage(name: name)
            await remember(image, for: urlString)
            return image
        }

        if urlString.lowercased().hasPrefix("bmwiki:") {
            let name = String(urlString.dropFirst("bmwiki:".count)).trimmingCharacters(in: .whitespacesAndNewlines)
            let image = try await fetchBigMouthCharacterImage(name: name)
            await remember(image, for: urlString)
            return image
        }

        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let data = try await network.data(from: url)
        guard let image = UIImage(data: data) else { throw URLError(.cannotDecodeRawData) }

        await remember(image, for: urlString)
        return image
    }

    private func remember(_ image: UIImage, for urlString: String) async {
        imageCache.setObject(image, forKey: NSString(string: urlString))
        if let data = image.jpegData(compressionQuality: 0.85) ?? image.pngData() {
            try? await imageStore.write(data, toRelativePath: imagePath(for: urlString))
        }
    }

    private func imagePath(for urlString: String) -> String {
        let digest = SHA256.hash(data: Data(urlString.utf8))
        let hex = digest.map { String(format: "%02x", $0) }.joined()
        return "images/\(hex).jpg" // имя файла из хеша URL, не из имени персонажа (слэши/кириллица)
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

    private func fetchFandomThumbnailURL(baseAPI: String, name: String) async throws -> String { // pageimages → thumbnail 600px
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
}
