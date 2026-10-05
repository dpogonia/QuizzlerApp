//
//  FileStoring.swift
//  CoreServices
//
//  Created by Dmitrii Pogonia on 19.02.2026.
//

import Foundation

public protocol FileStoring: Sendable { // путь относительный, корень — Application Support/Quizzler
    func write(_ data: Data, toRelativePath path: String) async throws
    func read(fromRelativePath path: String) async -> Data?
    func remove(relativePath path: String) async
    func exists(relativePath path: String) async -> Bool
}
