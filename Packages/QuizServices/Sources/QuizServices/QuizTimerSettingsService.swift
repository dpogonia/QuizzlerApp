import CoreServices
import Foundation

public protocol QuizTimerSettingsProviding: AnyObject {
    var availableDurations: [Int] { get }
    var currentDuration: Int { get set }
}

public final class QuizTimerSettingsService: QuizTimerSettingsProviding {
    private let storage: any KeyValueStoring

    private let storageKey = "quiz_timer_duration"
    public let availableDurations: [Int] = [1, 3, 5, 7, 10]

    public init(storage: any KeyValueStoring) {
        self.storage = storage
    }

    public var currentDuration: Int {
        get {
            let value = storage.integer(forKey: storageKey)
            return availableDurations.contains(value) ? value : 10
        }
        set {
            guard availableDurations.contains(newValue) else { return }
            storage.set(newValue, forKey: storageKey)
        }
    }
}
