//
//  DiskFileStore.swift
//  CoreServices
//
//  Created by Dmitrii Pogonia on 19.02.2026.
//

import Foundation

public actor DiskFileStore: FileStoring {
    private let rootURL: URL
    private let fileManager: FileManager

    public init(
        directory: FileManager.SearchPathDirectory = .applicationSupportDirectory,
        folderName: String = "Quizzler",
        fileManager: FileManager = .default
    ) {
        self.fileManager = fileManager
        let base = fileManager.urls(for: directory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        self.rootURL = base.appendingPathComponent(folderName, isDirectory: true)
        try? fileManager.createDirectory(at: rootURL, withIntermediateDirectories: true)
    }

    public func write(_ data: Data, toRelativePath path: String) throws {
        let url = url(for: path)
        try fileManager.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: url, options: .atomic)
    }

    public func read(fromRelativePath path: String) -> Data? {
        try? Data(contentsOf: url(for: path))
    }

    public func remove(relativePath path: String) {
        try? fileManager.removeItem(at: url(for: path))
    }

    public func exists(relativePath path: String) -> Bool {
        fileManager.fileExists(atPath: url(for: path).path)
    }

    private func url(for path: String) -> URL {
        path.split(separator: "/").reduce(rootURL) { partial, component in
            partial.appendingPathComponent(String(component))
        }
    }
}
