//
//  JSONParser.swift
//  CoreServices
//
//  Created by Dmitrii Pogonia on 16.02.2026.
//

import Foundation

public struct JSONParser: JSONParsing { // тонкая обёртка над JSONDecoder / JSONEncoder
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    public init(decoder: JSONDecoder = JSONDecoder(), encoder: JSONEncoder = JSONEncoder()) { // можно подсунуть свой decoder с датами, по умолчанию системный
        self.decoder = decoder
        self.encoder = encoder
    }

    public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T { // байты с сети / диска → структура
        try decoder.decode(type, from: data)
    }

    public func encode<T: Encodable>(_ value: T) throws -> Data { // структура → байты, потом DiskFileStore.write
        try encoder.encode(value)
    }
}
