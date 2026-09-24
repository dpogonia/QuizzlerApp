import Foundation

public protocol FileStoring: Sendable {
    func write(_ data: Data, toRelativePath path: String) async throws
    func read(fromRelativePath path: String) async -> Data?
    func remove(relativePath path: String) async
    func exists(relativePath path: String) async -> Bool
}
