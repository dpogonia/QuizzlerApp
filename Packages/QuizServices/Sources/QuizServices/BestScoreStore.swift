import CoreServices
import Foundation

public protocol BestScoreStoring: AnyObject {
    func bestScore(for mode: GameMode) -> (score: Int, total: Int)?
    func updateBestScore(correct: Int, total: Int, for mode: GameMode)
    func bestOverall() -> (mode: GameMode, score: Int, total: Int)?
}

public final class BestScoreStore: BestScoreStoring {
    private let storage: any KeyValueStoring
    private let timerSettings: any QuizTimerSettingsProviding

    public init(
        storage: any KeyValueStoring,
        timerSettings: any QuizTimerSettingsProviding
    ) {
        self.storage = storage
        self.timerSettings = timerSettings
    }

    public func bestScore(for mode: GameMode) -> (score: Int, total: Int)? {
        let timer = timerSettings.currentDuration
        let score = storage.integer(forKey: bestScoreKey(for: mode, timer: timer))
        let total = storage.integer(forKey: bestTotalKey(for: mode, timer: timer))
        guard total > 0 else { return nil }
        return (score, total)
    }

    public func updateBestScore(correct: Int, total: Int, for mode: GameMode) {
        guard total > 0 else { return }
        if let current = bestScore(for: mode), correct <= current.score {
            return
        }
        let timer = timerSettings.currentDuration
        storage.set(correct, forKey: bestScoreKey(for: mode, timer: timer))
        storage.set(total, forKey: bestTotalKey(for: mode, timer: timer))
    }

    public func bestOverall() -> (mode: GameMode, score: Int, total: Int)? {
        var best: (mode: GameMode, score: Int, total: Int)?
        for mode in GameMode.allCases {
            if let value = bestScore(for: mode) {
                if let currentBest = best {
                    if value.score > currentBest.score {
                        best = (mode, value.score, value.total)
                    }
                } else {
                    best = (mode, value.score, value.total)
                }
            }
        }
        return best
    }

    private func bestScoreKey(for mode: GameMode, timer: Int) -> String {
        "bestScore_\(mode.rawValue)_\(timer)"
    }

    private func bestTotalKey(for mode: GameMode, timer: Int) -> String {
        "bestTotal_\(mode.rawValue)_\(timer)"
    }
}
