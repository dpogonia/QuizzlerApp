//
//  SoundSettingsService.swift
//  QuizServices
//
//  Created by Dmitrii Pogonia on 14.04.2026.
//

import CoreServices
import Foundation

public protocol SoundSettingsProviding: AnyObject {
    var isEnabled: Bool { get set }
}

public final class SoundSettingsService: SoundSettingsProviding {
    private let storage: any KeyValueStoring

    private let storageKey = "app_sounds"

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
