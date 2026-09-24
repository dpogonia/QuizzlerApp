import CoreServices
import Foundation

public protocol LanguageSettingsProviding: AnyObject {
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
            return .systemDefault
        }
        set {
            storage.set(newValue.rawValue, forKey: storageKey)
        }
    }
}
