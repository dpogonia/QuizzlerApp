//
//  StartViewModel.swift
//  Quizzler
//
//  Created by Dmitrii Pogonia on 12.06.2026.
//

import Combine
import QuizServices
import SwiftUI

// Логика меню: банк, новая игра, «Продолжить», диалог resume. StartView только рисует.
@MainActor
final class ModeMenuViewModel: ObservableObject {
    private let preloader: any QuizPreloading
    private let quizService: any DynamicQuizServing
    private let scoreStore: any BestScoreStoring
    private let timerSettings: any QuizTimerSettingsProviding
    private let sessionStore: any QuizSessionPersisting
    private let feedback: any FeedbackPlaying

    let modes: [GameMode] = [.rickAndMorty, .southPark, .bigMouth, .humanResources]

    @Published var isLoading = false
    @Published var loadingMode: GameMode?
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var session: QuizSessionViewModel?
    @Published var navigateToGame = false
    @Published var savedSession: QuizSessionSnapshot?
    @Published var showResumePrompt = false
    @Published var resumePromptMode: GameMode?

    init(
        preloader: any QuizPreloading,
        quizService: any DynamicQuizServing,
        scoreStore: any BestScoreStoring,
        timerSettings: any QuizTimerSettingsProviding,
        sessionStore: any QuizSessionPersisting,
        feedback: any FeedbackPlaying
    ) {
        self.preloader = preloader
        self.quizService = quizService
        self.scoreStore = scoreStore
        self.timerSettings = timerSettings
        self.sessionStore = sessionStore
        self.feedback = feedback
    }

    func startPreload() async {
        await preloader.startIfNeeded()
    }

    func refreshSavedSession() async {
        savedSession = await sessionStore.load()
    }

    func continueSavedSession() {
        guard let snapshot = savedSession else { return }
        feedback.playTap()
        start(mode: snapshot.mode, snapshot: snapshot)
    }

    func select(_ mode: GameMode) {
        feedback.playTap()
        if let savedSession, savedSession.mode == mode { // тот же режим, что в снимке — спросим, не затирать ли
            resumePromptMode = mode
            showResumePrompt = true
            return
        }
        start(mode: mode, snapshot: nil)
    }

    func confirmResumeSavedSession() {
        continueSavedSession()
    }

    func confirmStartNewSession() {
        guard let mode = resumePromptMode else { return }
        feedback.playTap()
        start(mode: mode, snapshot: nil)
    }

    private func start(mode: GameMode, snapshot: QuizSessionSnapshot?) {
        guard !isLoading else { return } // пока крутится спиннер на карточке — второй тап игнор
        isLoading = true
        loadingMode = mode

        Task {
            do {
                let game = makeSession(mode: mode)
                if let snapshot {
                    game.prepareRestore(snapshot)
                } else {
                    switch mode {
                    case .rickAndMorty:
                        game.configureWithRMCharacters(try await preloader.rmCharacters())
                    case .southPark:
                        game.configureWithSPCharacters(try await preloader.spCharacters())
                    case .bigMouth:
                        game.configureWithBMCharacters(try await preloader.bmCharacters())
                    case .humanResources:
                        game.configureWithHRCharacters(try await preloader.bmCharacters()) // HR берёт тот же Fandom-банк, что Big Mouth
                    }
                }
                session = game
                navigateToGame = true
            } catch {
                errorMessage = L10n.Start.loadFailed(error.localizedDescription)
                showError = true
            }
            isLoading = false
            loadingMode = nil
        }
    }

    private func makeSession(mode: GameMode) -> QuizSessionViewModel {
        QuizSessionViewModel(
            mode: mode,
            engine: QuizLogicEngine(),
            quizService: quizService,
            scoreStore: scoreStore,
            timerSettings: timerSettings,
            sessionStore: sessionStore,
            feedback: feedback
        )
    }
}

@MainActor
final class StartViewModel: ObservableObject { // оболочка: SwiftUI подписан на неё, внутри живёт menu
    let menu: ModeMenuViewModel

    private var cancellables = Set<AnyCancellable>()

    init(
        preloader: any QuizPreloading,
        quizService: any DynamicQuizServing,
        scoreStore: any BestScoreStoring,
        timerSettings: any QuizTimerSettingsProviding,
        sessionStore: any QuizSessionPersisting,
        feedback: any FeedbackPlaying
    ) {
        self.menu = ModeMenuViewModel(
            preloader: preloader,
            quizService: quizService,
            scoreStore: scoreStore,
            timerSettings: timerSettings,
            sessionStore: sessionStore,
            feedback: feedback
        )

        menu.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func onAppear() {
        Task {
            await menu.startPreload()
            await menu.refreshSavedSession()
        }
    }
}
