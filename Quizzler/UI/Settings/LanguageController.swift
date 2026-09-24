import Combine
import QuizServices
import SwiftUI

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
