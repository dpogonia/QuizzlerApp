import CoreServices
import Foundation

protocol QuizTimerSettingsProviding: AnyObject {
    var availableDurations: [Int] { get }
    var currentDuration: Int { get set }
}

final class QuizTimerSettingsService: QuizTimerSettingsProviding {
    private let storage: any KeyValueStoring

    private let storageKey = "quiz_timer_duration"
    let availableDurations: [Int] = [3, 5, 7, 10, 15]

    init(storage: any KeyValueStoring = ServiceLocator.shared.resolve()) {
        self.storage = storage
    }

    var currentDuration: Int {
        get {
            let value = storage.integer(forKey: storageKey)
            return value > 0 ? value : 10
        }
        set {
            storage.set(newValue, forKey: storageKey)
        }
    }
}
