//
//  LanguageSettingsService.swift
//  QuizServices
//
//  Created by Dmitrii Pogonia on 08.04.2026.
//

import CoreServices
import Foundation

public protocol LanguageSettingsProviding: AnyObject { // ru / en, первый запуск — язык телефона
    var current: AppLanguage { get set }
}

public final class LanguageSettingsService: LanguageSettingsProviding {
    private let storage: any KeyValueStoring

    private let storageKey = "app_language"

    public init(storage: any KeyValueStoring) {
        self.storage = storage
    }

    public var current: AppLanguage {
        get {
            if let raw = storage.string(forKey: storageKey),
               let value = AppLanguage(rawValue: raw) {
                return value
            }
            return .systemDefault // нет ключа — как язык телефона
        }
        set {
            storage.set(newValue.rawValue, forKey: storageKey)
        }
    }
}
