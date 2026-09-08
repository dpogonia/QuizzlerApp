import Combine
import CoreServices
import SwiftUI
import UIKit

@MainActor
final class QuizSessionViewModel: ObservableObject {
    private let engine: QuizLogicProviding
    private let quizService: any DynamicQuizServing
    private let scoreStore: any BestScoreStoring
    private let timerSettings: any QuizTimerSettingsProviding

    let activeMode: GameMode

    @Published var posterImage: UIImage?
    @Published var questionText = ""
    @Published var questionColor: Color = .primary
    @Published var counterText = "0/0"
    @Published var timerText = "Вопрос:"
    @Published var timerColor: Color = .primary
    @Published var posterBorderColor: Color = .white
    @Published var isLoading = false
    @Published var buttonsEnabled = false
    @Published var usesPosterFill = false
    @Published var showResult = false
    @Published var resultTitle = ""
    @Published var resultText = ""
    @Published var shouldDismiss = false

    private var maxQuestions = 20
    private var currentCorrectAnswer = false
    private var currentCorrectName = ""
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var shouldFetchOnStart = true
    private var remainingTime: TimeInterval = 0
    private var timerTask: Task<Void, Never>?
    private var loadTask: Task<Void, Never>?
    private var hasStarted = false

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
        self.scoreStore = scoreStore
        self.timerSettings = timerSettings
        self.usesPosterFill = mode == .movies
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
        currentQuestionIndex = 0
        correctAnswers = 0
        posterBorderColor = .white
        questionText = ""
        questionColor = .primary
        showResult = false

        switch activeMode {
        case .movies:
            maxQuestions = localMovieQuestions.count
            counterText = "0/\(maxQuestions)"
            loadAndShowQuestion()
        case .rickAndMorty, .southPark, .bigMouth, .humanResources:
            maxQuestions = 20
            counterText = "0/\(maxQuestions)"
            if shouldFetchOnStart {
                fetchAPIDataAndStart()
            } else {
                questionText = "Загрузка вопроса…"
                loadAndShowQuestion()
            }
        }
    }

    func answerYes() {
        guard buttonsEnabled else { return }
        buttonsEnabled = false
        invalidateTimer()
        showAnswerResult(isCorrect: currentCorrectAnswer == true)
    }

    func answerNo() {
        guard buttonsEnabled else { return }
        buttonsEnabled = false
        invalidateTimer()
        showAnswerResult(isCorrect: currentCorrectAnswer == false)
    }

    func playAgain() {
        startSession()
    }

    func leaveToMenu() {
        invalidateTimer()
        loadTask?.cancel()
        shouldDismiss = true
    }

    func stop() {
        invalidateTimer()
        loadTask?.cancel()
    }

    private func fetchAPIDataAndStart() {
        invalidateTimer()
        buttonsEnabled = false
        isLoading = true
        posterImage = nil
        questionText = "Синхронизация с сервером…"
        counterText = "0/\(maxQuestions)"

        loadTask?.cancel()
        loadTask = Task {
            do {
                try await quizService.prefetchCharactersIfNeeded(for: activeMode, into: engine)
                guard !Task.isCancelled else { return }
                loadAndShowQuestion()
            } catch {
                guard !Task.isCancelled else { return }
                isLoading = false
                posterBorderColor = .white
                questionText = "Ошибка загрузки данных: \(error.localizedDescription)"
            }
        }
    }

    private func loadAndShowQuestion() {
        invalidateTimer()
        buttonsEnabled = false
        let shouldShowSpinner = !activeMode.isAPIMode || shouldFetchOnStart
        if shouldShowSpinner {
            isLoading = true
            posterImage = nil
            posterBorderColor = .white
        }

        loadTask?.cancel()
        loadTask = Task {
            var qText = ""
            var qAnswer = false
            var qImage = UIImage()

            switch activeMode {
            case .movies:
                let localQ = localMovieQuestions[currentQuestionIndex]
                qText = localQ.question
                qAnswer = localQ.correctAnswer
                qImage = UIImage(named: localQ.image) ?? UIImage()
                currentCorrectName = ""
            case .rickAndMorty, .southPark, .bigMouth, .humanResources:
                guard let (finalQuestion, image) = await quizService.makeDynamicQuestion(using: engine) else {
                    guard !Task.isCancelled else { return }
                    isLoading = false
                    posterBorderColor = .white
                    showNextQuestionOrResults()
                    return
                }
                qText = finalQuestion.questionText
                qAnswer = finalQuestion.correctAnswer
                currentCorrectName = finalQuestion.correctName
                qImage = image
            }

            guard !Task.isCancelled else { return }

            usesPosterFill = activeMode == .movies
            currentCorrectAnswer = qAnswer
            posterImage = qImage
            counterText = "\(currentQuestionIndex + 1)/\(maxQuestions)"
            questionColor = .primary
            questionText = qText
            isLoading = false
            buttonsEnabled = true
            startQuestionTimer()
        }
    }

    private func startQuestionTimer() {
        invalidateTimer()
        let duration = timerSettings.currentDuration
        guard duration > 0 else { return }

        remainingTime = TimeInterval(duration)
        updateTimerLabel()

        timerTask = Task { [weak self] in
            while let self, !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 50_000_000)
                guard !Task.isCancelled else { return }
                self.remainingTime -= 0.05
                if self.remainingTime <= 0 {
                    self.remainingTime = 0
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
        let clamped = max(remainingTime, 0)
        let totalCentiseconds = Int((clamped * 100).rounded(.down))
        let seconds = totalCentiseconds / 100
        let centiseconds = totalCentiseconds % 100
        timerText = String(format: "%02d:%02d", seconds, centiseconds)

        if seconds == 0 && centiseconds == 0 {
            timerColor = Color(.systemRed)
        } else if seconds < 3 {
            timerColor = Color(.systemYellow)
        } else {
            timerColor = .primary
        }
    }

    private func handleTimeExpired() {
        buttonsEnabled = false
        showAnswerResult(isCorrect: false)
    }

    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(isCorrect ? .success : .error)

        posterBorderColor = isCorrect ? Color(.systemGreen) : Color(.systemRed)

        if !currentCorrectName.isEmpty {
            questionColor = isCorrect ? Color(.systemGreen) : Color(.systemRed)
            questionText = currentCorrectName.uppercased()
        }

        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            guard !Task.isCancelled else { return }
            showNextQuestionOrResults()
        }
    }

    private func showNextQuestionOrResults() {
        invalidateTimer()
        currentQuestionIndex += 1

        if currentQuestionIndex >= maxQuestions {
            scoreStore.updateBestScore(correct: correctAnswers, total: maxQuestions, for: activeMode)
            resultTitle = "Этот раунд окончен!"
            resultText = "Ваш результат: \(correctAnswers)/\(maxQuestions)"
            posterBorderColor = .white
            showResult = true
        } else {
            posterBorderColor = .white
            loadAndShowQuestion()
        }
    }
}
