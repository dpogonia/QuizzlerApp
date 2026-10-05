//
//  UserDefaultsStorage.swift
//  CoreServices
//
//  Created by Dmitrii Pogonia on 21.02.2026.
//

import Foundation

public final class UserDefaultsStorage: KeyValueStoring, @unchecked Sendable { // обёртка, чтобы сервисы не импортировали UserDefaults напрямую
    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) { // .standard — обычные настройки приложения
        self.defaults = defaults
    }

    public func set(_ value: Int, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    public func integer(forKey key: String) -> Int { // нет ключа → 0, это системное поведение UserDefaults
        defaults.integer(forKey: key)
    }

    public func set(_ value: String?, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    public func string(forKey key: String) -> String? {
        defaults.string(forKey: key)
    }

    public func set(_ data: Data, forKey key: String) {
        defaults.set(data, forKey: key)
    }

    public func data(forKey key: String) -> Data? {
        defaults.data(forKey: key)
    }
}
