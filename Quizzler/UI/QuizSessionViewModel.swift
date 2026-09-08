import Combine
import CoreServices
import QuizServices
import SwiftUI
import UIKit

@MainActor
final class QuizSessionViewModel: ObservableObject {
    private let engine: QuizLogicProviding
    private let quizService: any DynamicQuizServing
    private let scoreRepository: any BestScoreStoring
    private let timerSettings: any QuizTimerSettingsProviding

    let store: GameStore
    let activeMode: GameMode

    var question: QuestionStore { store.question }
    var timer: TimerStore { store.timer }
    var score: ScoreStore { store.score }

    private var currentCorrectAnswer = false
    private var currentCorrectName = ""
    private var shouldFetchOnStart = true
    private var timerTask: Task<Void, Never>?
    private var loadTask: Task<Void, Never>?
    private var hasStarted = false
    private var cancellables = Set<AnyCancellable>()

    init(
        mode: GameMode,
        engine: QuizLogicProviding? = nil,
        quizService: any DynamicQuizServing = ServiceLocator.shared.resolve(),
        scoreStore: any BestScoreStoring = ServiceLocator.shared.resolve(),
        timerSettings: any QuizTimerSettingsProviding = ServiceLocator.shared.resolve()
    ) {
        self.activeMode = mode
        self.engine = engine ?? QuizLogicEngine()
        self.quizService = quizService
        self.scoreRepository = scoreStore
        self.timerSettings = timerSettings
        self.store = GameStore()
        self.store.question.usesPosterFill = mode == .movies

        store.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func configureWithRMCharacters(_ characters: [RMCharacter]) {
        engine.inject(rm: characters)
        shouldFetchOnStart = false
    }

    func configureWithSPCharacters(_ characters: [SPCharacter]) {
        engine.inject(sp: characters)
        shouldFetchOnStart = false
    }

    func configureWithBMCharacters(_ characters: [BMCharacter]) {
        engine.inject(bm: characters)
        shouldFetchOnStart = false
    }

    func configureWithHRCharacters(_ characters: [BMCharacter]) {
        engine.inject(hr: characters)
        shouldFetchOnStart = false
    }

    func startIfNeeded() {
        guard !hasStarted else { return }
        startSession()
    }

    func startSession() {
        hasStarted = true
        invalidateTimer()
        score.currentQuestionIndex = 0
        score.correctAnswers = 0
        question.posterBorderColor = .white
        question.questionText = ""
        question.questionColor = .primary
        score.showResult = false

        switch activeMode {
        case .movies:
            score.maxQuestions = localMovieQuestions.count
            score.counterText = QuizFormatters.scorePair(correct: 0, total: score.maxQuestions)
            loadAndShowQuestion()
        case .rickAndMorty, .southPark, .bigMouth, .humanResources:
            score.maxQuestions = 20
            score.counterText = QuizFormatters.scorePair(correct: 0, total: score.maxQuestions)
            if shouldFetchOnStart {
                fetchAPIDataAndStart()
            } else {
                question.questionText = L10n.Game.loadingQuestion
                loadAndShowQuestion()
            }
        }
    }

    func answerYes() {
        guard question.buttonsEnabled else { return }
        question.buttonsEnabled = false
        invalidateTimer()
        showAnswerResult(isCorrect: currentCorrectAnswer == true)
    }

    func answerNo() {
        guard question.buttonsEnabled else { return }
        question.buttonsEnabled = false
        invalidateTimer()
        showAnswerResult(isCorrect: currentCorrectAnswer == false)
    }

    func playAgain() {
        startSession()
    }

    func leaveToMenu() {
        invalidateTimer()
        loadTask?.cancel()
        score.shouldDismiss = true
    }

    func stop() {
        invalidateTimer()
        loadTask?.cancel()
    }

    private func fetchAPIDataAndStart() {
        invalidateTimer()
        question.buttonsEnabled = false
        question.isLoading = true
        question.posterImage = nil
        question.questionText = L10n.Game.syncing
        score.counterText = QuizFormatters.scorePair(correct: 0, total: score.maxQuestions)

        loadTask?.cancel()
        loadTask = Task {
            do {
                try await quizService.prefetchCharactersIfNeeded(for: activeMode, into: engine)
                guard !Task.isCancelled else { return }
                loadAndShowQuestion()
            } catch {
                guard !Task.isCancelled else { return }
                question.isLoading = false
                question.posterBorderColor = .white
                question.questionText = L10n.Game.loadError(error.localizedDescription)
            }
        }
    }

    private func loadAndShowQuestion() {
        invalidateTimer()
        question.buttonsEnabled = false
        let shouldShowSpinner = !activeMode.isAPIMode || shouldFetchOnStart
        if shouldShowSpinner {
            question.isLoading = true
            question.posterImage = nil
            question.posterBorderColor = .white
        }

        loadTask?.cancel()
        loadTask = Task {
            var qText = ""
            var qAnswer = false
            var qImage = UIImage()

            switch activeMode {
            case .movies:
                let localQ = localMovieQuestions[score.currentQuestionIndex]
                qText = L10n.Game.movieRatingQuestion
                qAnswer = localQ.correctAnswer
                qImage = UIImage(named: localQ.image) ?? UIImage()
                currentCorrectName = ""
            case .rickAndMorty, .southPark, .bigMouth, .humanResources:
                guard let (finalQuestion, image) = await quizService.makeDynamicQuestion(using: engine) else {
                    guard !Task.isCancelled else { return }
                    question.isLoading = false
                    question.posterBorderColor = .white
                    showNextQuestionOrResults()
                    return
                }
                qText = L10n.Game.characterNameQuestion(finalQuestion.questionText)
                qAnswer = finalQuestion.correctAnswer
                currentCorrectName = finalQuestion.correctName
                qImage = image
            }

            guard !Task.isCancelled else { return }

            question.usesPosterFill = activeMode == .movies
            currentCorrectAnswer = qAnswer
            question.posterImage = qImage
            score.counterText = QuizFormatters.scorePair(
                correct: score.currentQuestionIndex + 1,
                total: score.maxQuestions
            )
            question.questionColor = .primary
            question.questionText = qText
            question.isLoading = false
            question.buttonsEnabled = true
            startQuestionTimer()
        }
    }

    private func startQuestionTimer() {
        invalidateTimer()
        let duration = timerSettings.currentDuration
        guard duration > 0 else { return }

        timer.remainingTime = TimeInterval(duration)
        updateTimerLabel()

        timerTask = Task { [weak self] in
            while let self, !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 50_000_000)
                guard !Task.isCancelled else { return }
                self.timer.remainingTime -= 0.05
                if self.timer.remainingTime <= 0 {
                    self.timer.remainingTime = 0
                    self.updateTimerLabel()
                    self.invalidateTimer()
                    self.handleTimeExpired()
                    return
                }
                self.updateTimerLabel()
            }
        }
    }

    private func invalidateTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    private func updateTimerLabel() {
        let clamped = max(timer.remainingTime, 0)
        let totalCentiseconds = Int((clamped * 100).rounded(.down))
        let seconds = totalCentiseconds / 100
        let centiseconds = totalCentiseconds % 100
        timer.timerText = String(format: "%02d:%02d", seconds, centiseconds)

        if seconds == 0 && centiseconds == 0 {
            timer.timerColor = Color(.systemRed)
        } else if seconds < 3 {
            timer.timerColor = Color(.systemYellow)
        } else {
            timer.timerColor = .primary
        }
    }

    private func handleTimeExpired() {
        question.buttonsEnabled = false
        showAnswerResult(isCorrect: false)
    }

    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            score.correctAnswers += 1
        }

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(isCorrect ? .success : .error)

        question.posterBorderColor = isCorrect ? Color(.systemGreen) : Color(.systemRed)

        if !currentCorrectName.isEmpty {
            question.questionColor = isCorrect ? Color(.systemGreen) : Color(.systemRed)
            question.questionText = currentCorrectName.uppercased()
        }

        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            guard !Task.isCancelled else { return }
            showNextQuestionOrResults()
        }
    }

    private func showNextQuestionOrResults() {
        invalidateTimer()
        score.currentQuestionIndex += 1

        if score.currentQuestionIndex >= score.maxQuestions {
            scoreRepository.updateBestScore(
                correct: score.correctAnswers,
                total: score.maxQuestions,
                for: activeMode
            )
            score.resultTitle = L10n.Game.roundOver
            score.resultText = L10n.Game.yourResult(
                QuizFormatters.scorePair(correct: score.correctAnswers, total: score.maxQuestions)
            )
            question.posterBorderColor = .white
            score.showResult = true
        } else {
            question.posterBorderColor = .white
            loadAndShowQuestion()
        }
    }
}
