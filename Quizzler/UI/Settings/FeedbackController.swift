//
//  FeedbackController.swift
//  Quizzler
//
//  Created by Dmitrii Pogonia on 18.07.2026.
//

import Combine

@MainActor
protocol FeedbackPlaying: AnyObject {
    func playTap()
    func playSelection()
    func playSuccess()
    func playError()
    func startUrgency()
    func stopUrgency()
    func startGameMusic()
    func stopGameMusic()
    func pauseGameMusic()
}

@MainActor
final class FeedbackController: ObservableObject, FeedbackPlaying {
    let haptics: HapticController
    let sounds: SoundController

    private var cancellables = Set<AnyCancellable>()

    init(haptics: HapticController, sounds: SoundController) {
        self.haptics = haptics
        self.sounds = sounds

        haptics.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        sounds.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func playTap() {
        haptics.playTap()
        sounds.playTap()
    }

    func playSelection() {
        haptics.playSelection()
        sounds.playSelection()
    }

    func playSuccess() {
        haptics.playSuccess()
        sounds.playSuccess()
    }

    func playError() {
        haptics.playError()
        sounds.playError()
    }

    func startUrgency() {
        haptics.startUrgency()
    }

    func stopUrgency() {
        haptics.stopUrgency()
    }

    func startGameMusic() {
        sounds.startGameMusic()
    }

    func stopGameMusic() {
        sounds.stopGameMusic()
    }

    func pauseGameMusic() {
        sounds.pauseGameMusic()
    }
}
