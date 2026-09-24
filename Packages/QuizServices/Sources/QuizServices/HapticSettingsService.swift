import CoreServices
import Foundation

public protocol HapticSettingsProviding: AnyObject {
    var isEnabled: Bool { get set }
}

public final class HapticSettingsService: HapticSettingsProviding {
    private let storage: any KeyValueStoring

    private let storageKey = "app_haptics"

    public init(storage: any KeyValueStoring) {
        self.storage = storage
    }

    public var isEnabled: Bool {
        get {
            storage.string(forKey: storageKey) != "off"
        }
        set {
            storage.set(newValue ? "on" : "off", forKey: storageKey)
        }
    }
}
