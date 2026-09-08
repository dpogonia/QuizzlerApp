import Foundation

public enum NetworkError: Error, Equatable {
    case invalidResponse
    case statusCode(Int)
}

public protocol NetworkServing: Sendable {
    func data(for request: URLRequest) async throws -> Data
}

public extension NetworkServing {
    func data(from url: URL) async throws -> Data {
        try await data(for: URLRequest(url: url))
    }
}
