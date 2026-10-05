//
//  LanguageController.swift
//  Quizzler
//
//  Created by Dmitrii Pogonia on 02.07.2026.
//

import Combine
import QuizServices
import SwiftUI

// Язык интерфейса. Пишем в сервис и в AppLocalization, иначе L10n останется на старом бандле.
@MainActor
final class LanguageController: ObservableObject {
    private let languageSettings: any LanguageSettingsProviding

    @Published var current: AppLanguage

    init(languageSettings: any LanguageSettingsProviding) {
        self.languageSettings = languageSettings
        let language = languageSettings.current
        self.current = language
        AppLocalization.language = language
    }

    var locale: Locale {
        current.locale
    }

    func select(_ language: AppLanguage) {
        languageSettings.current = language
        AppLocalization.language = language
        current = language
    }
}
