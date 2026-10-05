//
//  ThemeSettingsService.swift
//  QuizServices
//
//  Created by Dmitrii Pogonia on 05.04.2026.
//

import CoreServices
import Foundation

public protocol ThemeSettingsProviding: AnyObject { // light / dark / system в UserDefaults
    var current: AppTheme { get set }
}

public final class ThemeSettingsService: ThemeSettingsProviding {
    private let storage: any KeyValueStoring

    private let storageKey = "app_theme"

    public init(storage: any KeyValueStoring) {
        self.storage = storage
    }

    public var current: AppTheme {
        get {
            if let raw = storage.string(forKey: storageKey),
               let value = AppTheme(rawValue: raw) {
                return value
            }
            return .system // первый запуск — как в iOS
        }
        set {
            storage.set(newValue.rawValue, forKey: storageKey)
        }
    }
}
