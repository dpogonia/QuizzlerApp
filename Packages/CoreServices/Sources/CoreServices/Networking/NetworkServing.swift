//
//  NetworkServing.swift
//  CoreServices
//
//  Created by Dmitrii Pogonia on 12.02.2026.
//

import Foundation

public enum NetworkError: Error, Equatable {
    case invalidResponse // пришло не HTTP (странно для URLSession, но мало ли)
    case statusCode(Int) // не 2xx — 404, 500 и т.д.
}

public protocol NetworkServing: Sendable { // качальщик байт, без знания Rick and Morty
    func data(for request: URLRequest) async throws -> Data
}

public extension NetworkServing {
    func data(from url: URL) async throws -> Data { // короткий путь: только URL, без ручной сборки URLRequest
        try await data(for: URLRequest(url: url))
    }
}
