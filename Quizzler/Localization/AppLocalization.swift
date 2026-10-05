//
//  AppLocalization.swift
//  Quizzler
//
//  Created by Dmitrii Pogonia on 06.08.2026.
//

import Foundation
import QuizServices
// Без этого файла смена языка в настройках не подхватила бы .strings. Тексты лежат в Resources. AppLocalization выбирает папку языка. L10n (Generated) даёт имена в коде. QuizLocalization подставляет готовые строки в режимы и форматтеры.

enum AppLocalization { // сейчас у приложения какой язык
    static var language: AppLanguage = .systemDefault // ru или en из настроек

    static var locale: Locale {
        language.locale
    }

    static var bundle: Bundle { // папка ru.lproj или en.lproj внутри приложения.
        if let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        return .main
    }

    static func string(forKey key: String, table: String, fallback: String) -> String { // достать перевод по ключу. Именно её вызывает L10n в Strings+Generated.
        bundle.localizedString(forKey: key, value: fallback, table: table)
    }
}
