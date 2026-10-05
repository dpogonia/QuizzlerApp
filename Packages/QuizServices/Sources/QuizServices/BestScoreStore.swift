//
//  BestScoreStore.swift
//  QuizServices
//
//  Created by Dmitrii Pogonia on 02.04.2026.
//

import CoreServices
import Foundation

public protocol BestScoreStoring: AnyObject {
    func bestScore(for mode: GameMode) -> (score: Int, total: Int)?
    func updateBestScore(correct: Int, total: Int, for mode: GameMode)
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

    private func bestScoreKey(for mode: GameMode, timer: Int) -> String {
        "bestScore_\(mode.rawValue)_\(timer)"
    }

    private func bestTotalKey(for mode: GameMode, timer: Int) -> String {
        "bestTotal_\(mode.rawValue)_\(timer)"
    }
}
