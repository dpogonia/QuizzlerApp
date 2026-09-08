import Combine
import QuizUI
import SwiftUI
import UIKit

@MainActor
final class QuestionStore: ObservableObject {
    @Published fileprivate(set) var posterImage: UIImage?
    @Published fileprivate(set) var questionText = ""
    @Published fileprivate(set) var questionColor: Color = QuizColor.primaryText
    @Published fileprivate(set) var posterBorderColor: Color = QuizColor.posterBorder
    @Published fileprivate(set) var isLoading = false
    @Published fileprivate(set) var buttonsEnabled = false
    @Published fileprivate(set) var usesPosterFill = false
}

@MainActor
final class TimerStore: ObservableObject {
    @Published fileprivate(set) var timerText = ""
    @Published fileprivate(set) var timerColor: Color = QuizColor.primaryText
    @Published fileprivate(set) var remainingTime: TimeInterval = 0
}

@MainActor
final class ScoreStore: ObservableObject {
    @Published fileprivate(set) var counterText = "0/0"
    @Published fileprivate(set) var currentQuestionIndex = 0
    @Published fileprivate(set) var correctAnswers = 0
    @Published fileprivate(set) var maxQuestions = 20
    @Published fileprivate(set) var showResult = false
    @Published fileprivate(set) var resultTitle = ""
    @Published fileprivate(set) var resultText = ""
    @Published fileprivate(set) var shouldDismiss = false
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

    func dispatch(_ action: GameAction) {
        switch action {
        case .prepareSession(let maxQuestions, let usesPosterFill):
            question.posterImage = nil
            question.questionText = ""
            question.questionColor = QuizColor.primaryText
            question.posterBorderColor = QuizColor.posterBorder
            question.isLoading = false
            question.buttonsEnabled = false
            question.usesPosterFill = usesPosterFill
            score.currentQuestionIndex = 0
            score.correctAnswers = 0
            score.maxQuestions = maxQuestions
            score.showResult = false
            score.resultTitle = ""
            score.resultText = ""
            score.shouldDismiss = false
            score.counterText = QuizFormatters.scorePair(correct: 0, total: maxQuestions)
            timer.remainingTime = 0
            timer.timerText = ""
            timer.timerColor = QuizColor.primaryText

        case .showMessage(let text):
            question.questionText = text

        case .beginSync:
            question.buttonsEnabled = false
            question.isLoading = true
            question.posterImage = nil
            question.questionText = L10n.Game.syncing
            score.counterText = QuizFormatters.scorePair(correct: 0, total: score.maxQuestions)

        case .syncFailed(let message):
            question.isLoading = false
            question.posterBorderColor = QuizColor.posterBorder
            question.questionText = message

        case .beginQuestionLoad(let showSpinner):
            question.buttonsEnabled = false
            if showSpinner {
                question.isLoading = true
                question.posterImage = nil
                question.posterBorderColor = QuizColor.posterBorder
            }

        case .presentQuestion(let image, let text, let usesPosterFill):
            question.usesPosterFill = usesPosterFill
            question.posterImage = image
            question.questionColor = QuizColor.primaryText
            question.questionText = text
            question.isLoading = false
            question.buttonsEnabled = true
            score.counterText = QuizFormatters.scorePair(
                correct: score.currentQuestionIndex + 1,
                total: score.maxQuestions
            )

        case .lockAnswers:
            question.buttonsEnabled = false

        case .revealAnswer(let isCorrect, let name):
            if isCorrect {
                score.correctAnswers += 1
            }
            question.posterBorderColor = isCorrect ? QuizColor.success : QuizColor.danger
            if let name, !name.isEmpty {
                question.questionColor = isCorrect ? QuizColor.success : QuizColor.danger
                question.questionText = name.uppercased()
            }

        case .advanceQuestion:
            score.currentQuestionIndex += 1

        case .finishRound(let title, let text):
            question.isLoading = false
            question.posterBorderColor = QuizColor.posterBorder
            score.resultTitle = title
            score.resultText = text
            score.showResult = true

        case .resetPosterBorder:
            question.isLoading = false
            question.posterBorderColor = QuizColor.posterBorder

        case .requestDismiss:
            score.shouldDismiss = true

        case .hideResult:
            score.showResult = false

        case .startTimer(let duration):
            timer.remainingTime = duration
            applyTimerDisplay()

        case .timerTick:
            timer.remainingTime = max(timer.remainingTime - 0.05, 0)
            applyTimerDisplay()
        }
    }

    private func applyTimerDisplay() {
        let clamped = max(timer.remainingTime, 0)
        let totalCentiseconds = Int((clamped * 100).rounded(.down))
        let seconds = totalCentiseconds / 100
        let centiseconds = totalCentiseconds % 100
        timer.timerText = String(format: "%02d:%02d", seconds, centiseconds)

        if seconds == 0 && centiseconds == 0 {
            timer.timerColor = QuizColor.danger
        } else if seconds < 3 {
            timer.timerColor = QuizColor.warning
        } else {
            timer.timerColor = QuizColor.primaryText
        }
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
