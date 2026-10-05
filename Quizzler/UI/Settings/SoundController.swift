//
//  SoundController.swift
//  Quizzler
//
//  Created by Dmitrii Pogonia on 14.07.2026.
//

import AVFoundation
import Combine
import QuizServices

@MainActor
final class SoundController: ObservableObject {
    private let settings: any SoundSettingsProviding
    private var tapPlayer: AVAudioPlayer?
    private var successPlayer: AVAudioPlayer?
    private var errorPlayer: AVAudioPlayer?
    private var musicPlayer: AVAudioPlayer?
    private var isGameMusicRequested = false

    @Published private(set) var isEnabled: Bool {
        didSet {
            guard oldValue != isEnabled else { return }
            settings.isEnabled = isEnabled
            if isEnabled {
                prepare()
                if isGameMusicRequested {
                    startGameMusic()
                }
            } else {
                stopPlayback()
            }
        }
    }

    init(settings: any SoundSettingsProviding) {
        self.settings = settings
        self.isEnabled = settings.isEnabled
        configureSession()
        prepare()
    }

    func select(_ enabled: Bool) {
        if enabled {
            isEnabled = true
            playTap()
        } else {
            playTap()
            isEnabled = false
        }
    }

    func playTap() {
        play(tapPlayer)
    }

    func playSelection() {
        play(tapPlayer)
    }

    func playSuccess() {
        play(successPlayer)
    }

    func playError() {
        play(errorPlayer)
    }

    func startGameMusic() {
        isGameMusicRequested = true
        guard isEnabled, let musicPlayer, !musicPlayer.isPlaying else { return }
        musicPlayer.numberOfLoops = -1
        musicPlayer.play()
    }

    func stopGameMusic() {
        isGameMusicRequested = false
        musicPlayer?.pause()
        musicPlayer?.currentTime = 0
    }

    func pauseGameMusic() {
        musicPlayer?.pause()
    }

    private func play(_ player: AVAudioPlayer?) {
        guard isEnabled, let player else { return }
        player.pause()
        player.currentTime = 0
        player.play()
    }

    private func stopPlayback() {
        tapPlayer?.stop()
        successPlayer?.stop()
        errorPlayer?.stop()
        musicPlayer?.pause()
        musicPlayer?.currentTime = 0
    }

    private func prepare() {
        if tapPlayer == nil {
            tapPlayer = makePlayer(named: "tap", volume: 0.85)
        }
        if successPlayer == nil {
            successPlayer = makePlayer(named: "success", volume: 0.8)
        }
        if errorPlayer == nil {
            errorPlayer = makePlayer(named: "error", volume: 0.8)
        }
        if musicPlayer == nil {
            musicPlayer = makePlayer(named: "game_music", volume: 0.32)
            musicPlayer?.numberOfLoops = -1
        }
        tapPlayer?.prepareToPlay()
        successPlayer?.prepareToPlay()
        errorPlayer?.prepareToPlay()
        musicPlayer?.prepareToPlay()
    }

    private func configureSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
    }

    private func makePlayer(named name: String, volume: Float) -> AVAudioPlayer? {
        guard let url = audioURL(named: name) else { return nil }
        let player = try? AVAudioPlayer(contentsOf: url)
        player?.volume = volume
        return player
    }

    private func audioURL(named name: String) -> URL? {
        let extensions = ["mp3", "m4a", "aac", "wav", "caf"]
        let folders: [String?] = ["Audio", "Resources/Audio", nil]
        for ext in extensions {
            for folder in folders {
                if let folder, let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: folder) {
                    return url
                }
                if folder == nil, let url = Bundle.main.url(forResource: name, withExtension: ext) {
                    return url
                }
            }
        }
        return nil
    }
}
