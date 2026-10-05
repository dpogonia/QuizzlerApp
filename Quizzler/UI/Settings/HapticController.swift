//
//  HapticController.swift
//  Quizzler
//
//  Created by Dmitrii Pogonia on 10.07.2026.
//

import Combine
import CoreHaptics
import QuizServices
import UIKit

@MainActor
final class HapticController: ObservableObject {
    private let settings: any HapticSettingsProviding
    private let supportsEngine: Bool
    private let tapGenerator = UIImpactFeedbackGenerator(style: .light)
    private let pressGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()

    private var engine: CHHapticEngine?
    private var urgencyPlayer: CHHapticPatternPlayer?
    private var urgencyPulseTask: Task<Void, Never>?
    private var isUrgencyActive = false

    @Published private(set) var isEnabled: Bool {
        didSet {
            guard oldValue != isEnabled else { return }
            settings.isEnabled = isEnabled
            if isEnabled {
                prepare()
            } else {
                stopUrgency()
            }
        }
    }

    init(settings: any HapticSettingsProviding) {
        self.settings = settings
        self.isEnabled = settings.isEnabled
        self.supportsEngine = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        prepare()
    }

    func select(_ enabled: Bool) {
        if enabled {
            isEnabled = true
            playSelection()
        } else {
            playSelection()
            isEnabled = false
        }
    }

    func playTap() {
        guard isEnabled else { return }
        pressGenerator.impactOccurred()
    }

    func playSelection() {
        guard isEnabled else { return }
        selectionGenerator.selectionChanged()
    }

    func playSuccess() {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(.success)
    }

    func playError() {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(.error)
    }

    func startUrgency() {
        guard isEnabled, !isUrgencyActive else { return }
        isUrgencyActive = true

        if supportsEngine, startEngineUrgency() {
            return
        }

        startPulseUrgency()
    }

    func stopUrgency() {
        guard isUrgencyActive else { return }
        isUrgencyActive = false
        try? urgencyPlayer?.stop(atTime: CHHapticTimeImmediate)
        urgencyPlayer = nil
        urgencyPulseTask?.cancel()
        urgencyPulseTask = nil
    }

    private func prepare() {
        tapGenerator.prepare()
        pressGenerator.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
        prepareEngine()
    }

    private func prepareEngine() {
        guard supportsEngine, engine == nil else { return }

        engine = try? CHHapticEngine()
        engine?.playsHapticsOnly = true
        engine?.isAutoShutdownEnabled = true
        engine?.resetHandler = { [weak self] in
            Task { @MainActor in
                try? self?.engine?.start()
            }
        }
        engine?.stoppedHandler = { [weak self] _ in
            Task { @MainActor in
                try? self?.engine?.start()
            }
        }
        try? engine?.start()
    }

    private func startEngineUrgency() -> Bool {
        prepareEngine()
        guard let engine else { return false }

        do {
            try engine.start()
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.32)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.18)
            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [intensity, sharpness],
                relativeTime: 0,
                duration: 4
            )
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
            urgencyPlayer = player
            return true
        } catch {
            return false
        }
    }

    private func startPulseUrgency() {
        urgencyPulseTask?.cancel()
        urgencyPulseTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self, self.isEnabled else { return }
                self.tapGenerator.impactOccurred(intensity: 0.38)
                try? await Task.sleep(for: .milliseconds(170))
            }
        }
    }
}
