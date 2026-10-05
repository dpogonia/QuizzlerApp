//
//  AppLocalization.swift
//  Quizzler
//
//  Created by Dmitrii Pogonia on 06.08.2026.
//

import Foundation
import QuizServices

enum AppLocalization {
    static var language: AppLanguage = .systemDefault

    static var locale: Locale {
        language.locale
    }

    static var bundle: Bundle {
        if let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        return .main
    }

    static func string(forKey key: String, table: String, fallback: String) -> String {
        bundle.localizedString(forKey: key, value: fallback, table: table)
    }
}
