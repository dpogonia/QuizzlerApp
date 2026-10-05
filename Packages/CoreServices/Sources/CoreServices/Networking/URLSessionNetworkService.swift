//
//  URLSessionNetworkService.swift
//  CoreServices
//
//  Created by Dmitrii Pogonia on 14.02.2026.
//

import Foundation

public struct URLSessionNetworkService: NetworkServing { // URLSession + свой URLCache на картинки/json
    private let session: URLSession

    public init(session: URLSession = URLSessionNetworkService.makeCachedSession()) { // по умолчанию сессия с кэшем 20 МБ RAM / 100 МБ диск
        self.session = session
    }

    public static func makeCachedSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache(
            memoryCapacity: 20 * 1024 * 1024,
            diskCapacity: 100 * 1024 * 1024,
            diskPath: "QuizzlerURLCache" // папка кэша URLSession, отдельно от нашего DiskFileStore
        )
        return URLSession(configuration: configuration)
    }

    public func data(for request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw NetworkError.statusCode(http.statusCode) // 404 картинки не глотаем как успех
        }
        return data
    }
}
