//
//  ThemeController.swift
//  Quizzler
//
//  Created by Dmitrii Pogonia on 28.06.2026.
//

import Combine
import QuizServices
import SwiftUI

// Тема на всё приложение. QuizzlerApp читает colorScheme. Пишем и в UserDefaults через ThemeSettingsService.
@MainActor
final class ThemeController: ObservableObject {
    private let themeSettings: any ThemeSettingsProviding

    @Published var current: AppTheme

    init(themeSettings: any ThemeSettingsProviding) {
        self.themeSettings = themeSettings
        self.current = themeSettings.current
    }

    var colorScheme: ColorScheme? { // nil = системная, SwiftUI сам решит светлая/тёмная
        switch current {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }

    func select(_ theme: AppTheme) {
        themeSettings.current = theme
        current = theme
    }
}
