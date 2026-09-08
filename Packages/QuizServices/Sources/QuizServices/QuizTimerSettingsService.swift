import CoreServices
import Foundation

public protocol QuizTimerSettingsProviding: AnyObject {
    var availableDurations: [Int] { get }
    var currentDuration: Int { get set }
}

public final class QuizTimerSettingsService: QuizTimerSettingsProviding {
    private let storage: any KeyValueStoring

    private let storageKey = "quiz_timer_duration"
    public let availableDurations: [Int] = [3, 5, 7, 10, 15]

    public init(storage: any KeyValueStoring = ServiceLocator.shared.resolve()) {
        self.storage = storage
    }

    public var currentDuration: Int {
        get {
            let value = storage.integer(forKey: storageKey)
            return value > 0 ? value : 10
        }
        set {
            storage.set(newValue, forKey: storageKey)
        }
    }
}
