//
//  QuizBankCache.swift
//  QuizServices
//
//  Created by Dmitrii Pogonia on 14.03.2026.
//

import CoreServices
import Foundation

public protocol QuizBankCaching: Sendable {
    func saveRM(_ characters: [RMCharacter]) async
    func loadRM() async -> [RMCharacter]?
    func saveSP(_ characters: [SPCharacter]) async
    func loadSP() async -> [SPCharacter]?
    func saveBM(_ characters: [BMCharacter]) async
    func loadBM() async -> [BMCharacter]?
}

public final class QuizBankCache: QuizBankCaching, @unchecked Sendable {
    private enum FileName {
        static let rm = "banks/rm.json"
        static let sp = "banks/sp.json"
        static let bm = "banks/bm.json"
    }

    private let files: any FileStoring
    private let parser: any JSONParsing

    public init(files: any FileStoring, parser: any JSONParsing) {
        self.files = files
        self.parser = parser
    }

    public func saveRM(_ characters: [RMCharacter]) async {
        await save(characters, to: FileName.rm)
    }

    public func loadRM() async -> [RMCharacter]? {
        await load(from: FileName.rm)
    }

    public func saveSP(_ characters: [SPCharacter]) async {
        await save(characters, to: FileName.sp)
    }

    public func loadSP() async -> [SPCharacter]? {
        await load(from: FileName.sp)
    }

    public func saveBM(_ characters: [BMCharacter]) async {
        await save(characters, to: FileName.bm)
    }

    public func loadBM() async -> [BMCharacter]? {
        await load(from: FileName.bm)
    }

    private func save<T: Encodable>(_ value: T, to path: String) async {
        guard let data = try? parser.encode(value) else { return }
        try? await files.write(data, toRelativePath: path)
    }

    private func load<T: Decodable>(from path: String) async -> T? {
        guard let data = await files.read(fromRelativePath: path) else { return nil }
        return try? parser.decode(T.self, from: data)
    }
}
