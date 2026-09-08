import Combine
import QuizServices
import QuizUI
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
    private var revealTask: Task<Void, Never>?
    private var hasStarted = false
    private var cancellables = Set<AnyCancellable>()

    init(
        mode: GameMode,
        engine: QuizLogicProviding,
        quizService: any DynamicQuizServing,
        scoreStore: any BestScoreStoring,
        timerSettings: any QuizTimerSettingsProviding
    ) {
        self.activeMode = mode
        self.engine = engine
        self.quizService = quizService
        self.scoreRepository = scoreStore
        self.timerSettings = timerSettings
        self.store = GameStore()

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
        cancelSessionTasks()
        let maxQuestions = activeMode == .movies ? localMovieQuestions.count : 20
        store.dispatch(
            .prepareSession(
                maxQuestions: maxQuestions,
                usesPosterFill: activeMode == .movies
            )
        )

        switch activeMode {
        case .movies:
            loadAndShowQuestion()
        case .rickAndMorty, .southPark, .bigMouth, .humanResources:
            if shouldFetchOnStart {
                fetchAPIDataAndStart()
            } else {
                store.dispatch(.showMessage(L10n.Game.loadingQuestion))
                loadAndShowQuestion()
            }
        }
    }

    func answerYes() {
        guard question.buttonsEnabled else { return }
        store.dispatch(.lockAnswers)
        invalidateTimer()
        showAnswerResult(isCorrect: currentCorrectAnswer == true)
    }

    func answerNo() {
        guard question.buttonsEnabled else { return }
        store.dispatch(.lockAnswers)
        invalidateTimer()
        showAnswerResult(isCorrect: currentCorrectAnswer == false)
    }

    func playAgain() {
        startSession()
    }

    func leaveToMenu() {
        cancelSessionTasks()
        store.dispatch(.requestDismiss)
    }

    func dismissResult() {
        store.dispatch(.hideResult)
    }

    func stop() {
        cancelSessionTasks()
    }

    private func fetchAPIDataAndStart() {
        invalidateTimer()
        store.dispatch(.beginSync)

        loadTask?.cancel()
        loadTask = Task {
            do {
                try await quizService.prefetchCharactersIfNeeded(for: activeMode, into: engine)
                guard !Task.isCancelled else { return }
                loadAndShowQuestion()
            } catch {
                guard !Task.isCancelled else { return }
                store.dispatch(.syncFailed(L10n.Game.loadError(error.localizedDescription)))
            }
        }
    }

    private func loadAndShowQuestion() {
        invalidateTimer()
        let shouldShowSpinner = !activeMode.isAPIMode || shouldFetchOnStart
        store.dispatch(.beginQuestionLoad(showSpinner: shouldShowSpinner))

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
                    store.dispatch(.resetPosterBorder)
                    showNextQuestionOrResults()
                    return
                }
                qText = L10n.Game.characterNameQuestion(finalQuestion.questionText)
                qAnswer = finalQuestion.correctAnswer
                currentCorrectName = finalQuestion.correctName
                qImage = image
            }

            guard !Task.isCancelled else { return }

            currentCorrectAnswer = qAnswer
            store.dispatch(
                .presentQuestion(
                    image: qImage,
                    text: qText,
                    usesPosterFill: activeMode == .movies
                )
            )
            startQuestionTimer()
        }
    }

    private func startQuestionTimer() {
        invalidateTimer()
        let duration = timerSettings.currentDuration
        guard duration > 0 else { return }

        store.dispatch(.startTimer(TimeInterval(duration)))

        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(50))
                guard let self else { return }
                self.store.dispatch(.timerTick)
                if self.timer.remainingTime <= 0 {
                    self.invalidateTimer()
                    self.handleTimeExpired()
                    return
                }
            }
        }
    }

    private func invalidateTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    private func cancelSessionTasks() {
        invalidateTimer()
        loadTask?.cancel()
        revealTask?.cancel()
        loadTask = nil
        revealTask = nil
    }

    private func handleTimeExpired() {
        store.dispatch(.lockAnswers)
        showAnswerResult(isCorrect: false)
    }

    private func showAnswerResult(isCorrect: Bool) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(isCorrect ? .success : .error)

        store.dispatch(
            .revealAnswer(
                isCorrect: isCorrect,
                name: currentCorrectName.isEmpty ? nil : currentCorrectName
            )
        )

        revealTask?.cancel()
        revealTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(1.5))
            guard let self, !Task.isCancelled else { return }
            self.showNextQuestionOrResults()
        }
    }

    private func showNextQuestionOrResults() {
        invalidateTimer()
        store.dispatch(.advanceQuestion)

        if score.currentQuestionIndex >= score.maxQuestions {
            scoreRepository.updateBestScore(
                correct: score.correctAnswers,
                total: score.maxQuestions,
                for: activeMode
            )
            store.dispatch(
                .finishRound(
                    title: L10n.Game.roundOver,
                    text: L10n.Game.yourResult(
                        QuizFormatters.scorePair(correct: score.correctAnswers, total: score.maxQuestions)
                    )
                )
            )
        } else {
            store.dispatch(.resetPosterBorder)
            loadAndShowQuestion()
        }
    }
}
