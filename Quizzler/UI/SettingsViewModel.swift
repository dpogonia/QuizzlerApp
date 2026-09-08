import Combine
import CoreServices
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    private let scoreStore: any BestScoreStoring
    private let timerSettings: any QuizTimerSettingsProviding

    @Published var selectedDuration: Int

    var availableDurations: [Int] {
        timerSettings.availableDurations
    }

    init(
        scoreStore: any BestScoreStoring = ServiceLocator.shared.resolve(),
        timerSettings: any QuizTimerSettingsProviding = ServiceLocator.shared.resolve()
    ) {
        self.scoreStore = scoreStore
        self.timerSettings = timerSettings
        self.selectedDuration = timerSettings.currentDuration
    }

    func recordText(for mode: GameMode) -> String {
        if let best = scoreStore.bestScore(for: mode) {
            return "Лучший результат (\(selectedDuration)s): \(best.score)/\(best.total)"
        }
        return "Нет рекордов для скорости \(selectedDuration) секунд"
    }

    func selectDuration(_ value: Int) {
        timerSettings.currentDuration = value
        selectedDuration = value
    }
}
