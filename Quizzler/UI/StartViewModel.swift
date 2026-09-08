import Combine
import QuizServices
import SwiftUI
import UIKit

@MainActor
final class StartHeaderViewModel: ObservableObject {
    private let scoreStore: any BestScoreStoring

    @Published var bestResultText = ""

    init(scoreStore: any BestScoreStoring) {
        self.scoreStore = scoreStore
    }

    func refresh() {
        if let best = scoreStore.bestOverall() {
            bestResultText = "Рекорд: \(best.mode.title) — \(best.score)/\(best.total)"
        } else {
            bestResultText = ""
        }
    }
}

@MainActor
final class ModeMenuViewModel: ObservableObject {
    private let preloader: any QuizPreloading
    private let quizService: any DynamicQuizServing
    private let scoreStore: any BestScoreStoring
    private let timerSettings: any QuizTimerSettingsProviding

    let modes: [GameMode] = [.movies, .rickAndMorty, .southPark, .bigMouth, .humanResources]

    @Published var isLoading = false
    @Published var loadingMode: GameMode?
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var session: QuizSessionViewModel?
    @Published var navigateToGame = false

    init(
        preloader: any QuizPreloading,
        quizService: any DynamicQuizServing,
        scoreStore: any BestScoreStoring,
        timerSettings: any QuizTimerSettingsProviding
    ) {
        self.preloader = preloader
        self.quizService = quizService
        self.scoreStore = scoreStore
        self.timerSettings = timerSettings
    }

    func startPreload() {
        preloader.startIfNeeded()
    }

    func select(_ mode: GameMode) {
        guard !isLoading else { return }
        isLoading = true
        loadingMode = mode
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        Task {
            do {
                let game = QuizSessionViewModel(
                    mode: mode,
                    quizService: quizService,
                    scoreStore: scoreStore,
                    timerSettings: timerSettings
                )
                switch mode {
                case .movies:
                    break
                case .rickAndMorty:
                    game.configureWithRMCharacters(try await preloader.rmCharacters())
                case .southPark:
                    game.configureWithSPCharacters(try await preloader.spCharacters())
                case .bigMouth:
                    game.configureWithBMCharacters(try await preloader.bmCharacters())
                case .humanResources:
                    game.configureWithHRCharacters(try await preloader.bmCharacters())
                }
                session = game
                navigateToGame = true
            } catch {
                errorMessage = "Не удалось загрузить данные. Попробуйте ещё раз.\n\(error.localizedDescription)"
                showError = true
            }
            isLoading = false
            loadingMode = nil
        }
    }
}

@MainActor
final class StartViewModel: ObservableObject {
    let header: StartHeaderViewModel
    let menu: ModeMenuViewModel

    private var cancellables = Set<AnyCancellable>()

    init(
        preloader: any QuizPreloading,
        quizService: any DynamicQuizServing,
        scoreStore: any BestScoreStoring,
        timerSettings: any QuizTimerSettingsProviding
    ) {
        self.header = StartHeaderViewModel(scoreStore: scoreStore)
        self.menu = ModeMenuViewModel(
            preloader: preloader,
            quizService: quizService,
            scoreStore: scoreStore,
            timerSettings: timerSettings
        )

        header.objectWillChange
            .merge(with: menu.objectWillChange)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func onAppear() {
        menu.startPreload()
        header.refresh()
    }
}
