//
//  JSONParsing.swift
//  CoreServices
//
//  Created by Dmitrii Pogonia on 16.02.2026.
//

import Foundation

public protocol JSONParsing: Sendable { // Data ↔ Codable, чтобы сеть не знала JSONDecoder
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
    func encode<T: Encodable>(_ value: T) throws -> Data
}

public extension JSONParsing {
    func decodeList<T: Decodable>(_ type: T.Type, from data: Data) throws -> [T] { // сразу массив, без [T].self в каждом вызове
        try decode([T].self, from: data)
    }
}
