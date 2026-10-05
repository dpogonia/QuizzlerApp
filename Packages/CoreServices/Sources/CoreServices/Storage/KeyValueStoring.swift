//
//  KeyValueStoring.swift
//  CoreServices
//
//  Created by Dmitrii Pogonia on 21.02.2026.
//

import Foundation

// Ключ-значение: рекорды, тема, язык, таймер. Сейчас реализация — UserDefaults.
public protocol KeyValueStoring: Sendable {
    func set(_ value: Int, forKey key: String)
    func integer(forKey key: String) -> Int
    func set(_ value: String?, forKey key: String)
    func string(forKey key: String) -> String?
    func set(_ data: Data, forKey key: String) // на будущее, рекорды сейчас int
    func data(forKey key: String) -> Data?
}
