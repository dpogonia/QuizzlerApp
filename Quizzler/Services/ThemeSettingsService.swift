import CoreServices
import Foundation

protocol ThemeSettingsProviding: AnyObject {
    var current: AppTheme { get set }
}

final class ThemeSettingsService: ThemeSettingsProviding {
    private let storage: any KeyValueStoring

    private let storageKey = "app_theme"

    init(storage: any KeyValueStoring = ServiceLocator.shared.resolve()) {
        self.storage = storage
    }

    var current: AppTheme {
        get {
            if let raw = storage.string(forKey: storageKey),
               let value = AppTheme(rawValue: raw) {
                return value
            }
            return .system
        }
        set {
            storage.set(newValue.rawValue, forKey: storageKey)
        }
    }
}
