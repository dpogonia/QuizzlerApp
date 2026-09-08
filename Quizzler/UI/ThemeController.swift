import Combine
import CoreServices
import SwiftUI

@MainActor
final class ThemeController: ObservableObject {
    private let themeSettings: any ThemeSettingsProviding

    @Published var current: AppTheme

    init(themeSettings: any ThemeSettingsProviding = ServiceLocator.shared.resolve()) {
        self.themeSettings = themeSettings
        self.current = themeSettings.current
    }

    var colorScheme: ColorScheme? {
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
