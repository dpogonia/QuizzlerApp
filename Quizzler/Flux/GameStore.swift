import Combine
import SwiftUI
import UIKit

@MainActor
final class QuestionStore: ObservableObject {
    @Published var posterImage: UIImage?
    @Published var questionText = ""
    @Published var questionColor: Color = .primary
    @Published var posterBorderColor: Color = .white
    @Published var isLoading = false
    @Published var buttonsEnabled = false
    @Published var usesPosterFill = false
}

@MainActor
final class TimerStore: ObservableObject {
    @Published var timerText = ""
    @Published var timerColor: Color = .primary
    @Published var remainingTime: TimeInterval = 0
}

@MainActor
final class ScoreStore: ObservableObject {
    @Published var counterText = "0/0"
    @Published var currentQuestionIndex = 0
    @Published var correctAnswers = 0
    @Published var maxQuestions = 20
    @Published var showResult = false
    @Published var resultTitle = ""
    @Published var resultText = ""
    @Published var shouldDismiss = false
}

@MainActor
final class GameStore: ObservableObject {
    let question: QuestionStore
    let timer: TimerStore
    let score: ScoreStore

    private var cancellables = Set<AnyCancellable>()

    init(question: QuestionStore, timer: TimerStore, score: ScoreStore) {
        self.question = question
        self.timer = timer
        self.score = score
        bindNestedStores()
    }

    convenience init() {
        self.init(question: QuestionStore(), timer: TimerStore(), score: ScoreStore())
    }

    private func bindNestedStores() {
        question.objectWillChange
            .merge(with: timer.objectWillChange)
            .merge(with: score.objectWillChange)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}
