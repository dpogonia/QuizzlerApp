import Combine
import QuizServices
import SwiftUI

@MainActor
final class RecordsViewModel: ObservableObject {
    private let scoreStore: any BestScoreStoring

    @Published private(set) var duration: Int

    init(
        scoreStore: any BestScoreStoring,
        duration: Int
    ) {
        self.scoreStore = scoreStore
        self.duration = duration
    }

    func updateDuration(_ value: Int) {
        duration = value
    }

    func recordText(for mode: GameMode) -> String {
        if let best = scoreStore.bestScore(for: mode) {
            return "Лучший результат (\(duration)s): \(best.score)/\(best.total)"
        }
        return "Нет рекордов для скорости \(duration) секунд"
    }
}

@MainActor
final class TimerSettingsViewModel: ObservableObject {
    private let timerSettings: any QuizTimerSettingsProviding

    @Published var selectedDuration: Int

    var availableDurations: [Int] {
        timerSettings.availableDurations
    }

    init(timerSettings: any QuizTimerSettingsProviding) {
        self.timerSettings = timerSettings
        self.selectedDuration = timerSettings.currentDuration
    }

    func selectDuration(_ value: Int) {
        timerSettings.currentDuration = value
        selectedDuration = value
    }
}

@MainActor
final class SettingsViewModel: ObservableObject {
    let records: RecordsViewModel
    let timer: TimerSettingsViewModel

    private var cancellables = Set<AnyCancellable>()

    init(
        scoreStore: any BestScoreStoring,
        timerSettings: any QuizTimerSettingsProviding
    ) {
        let timerVM = TimerSettingsViewModel(timerSettings: timerSettings)
        self.timer = timerVM
        self.records = RecordsViewModel(scoreStore: scoreStore, duration: timerVM.selectedDuration)

        timerVM.$selectedDuration
            .sink { [records] duration in
                records.updateDuration(duration)
            }
            .store(in: &cancellables)

        records.objectWillChange
            .merge(with: timerVM.objectWillChange)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}
