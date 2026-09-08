import Combine
import CoreServices
import SwiftUI
import UIKit

@MainActor
final class StartViewModel: ObservableObject {
    private let preloader: any QuizPreloading
    private let scoreStore: any BestScoreStoring

    let modes: [GameMode] = [.movies, .rickAndMorty, .southPark, .bigMouth, .humanResources]

    @Published var bestResultText = ""
    @Published var isLoading = false
    @Published var loadingMode: GameMode?
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var session: QuizSessionViewModel?
    @Published var navigateToGame = false

    init(
        preloader: any QuizPreloading = ServiceLocator.shared.resolve(),
        scoreStore: any BestScoreStoring = ServiceLocator.shared.resolve()
    ) {
        self.preloader = preloader
        self.scoreStore = scoreStore
    }

    func onAppear() {
        preloader.startIfNeeded()
        refreshBestResult()
    }

    func refreshBestResult() {
        if let best = scoreStore.bestOverall() {
            bestResultText = "Рекорд: \(best.mode.title) — \(best.score)/\(best.total)"
        } else {
            bestResultText = ""
        }
    }

    func select(_ mode: GameMode) {
        guard !isLoading else { return }
        isLoading = true
        loadingMode = mode
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        Task {
            do {
                let game = QuizSessionViewModel(mode: mode)
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
