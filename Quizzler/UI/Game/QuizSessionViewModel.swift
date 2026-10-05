//
//  QuizSessionViewModel.swift
//  Quizzler
//
//  Created by Dmitrii Pogonia on 22.05.2026.
//

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
    private let sessionStore: any QuizSessionPersisting
    private let feedback: any FeedbackPlaying

    let store: GameStore
    let activeMode: GameMode

    var question: QuestionStore { store.question }
    var timer: TimerStore { store.timer }
    var score: ScoreStore { store.score }

    private var currentCorrectAnswer = false
    private var currentCorrectName = ""
    private var currentImageURL: String?
    private var pendingSnapshot: QuizSessionSnapshot?
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
        timerSettings: any QuizTimerSettingsProviding,
        sessionStore: any QuizSessionPersisting,
        feedback: any FeedbackPlaying
    ) {
        self.activeMode = mode
        self.engine = engine
        self.quizService = quizService
        self.scoreRepository = scoreStore
        self.timerSettings = timerSettings
        self.sessionStore = sessionStore
        self.feedback = feedback
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

    func prepareRestore(_ snapshot: QuizSessionSnapshot) {
        pendingSnapshot = snapshot
        shouldFetchOnStart = false
    }

    func startIfNeeded() {
        guard !hasStarted else { return }
        if let pendingSnapshot {
            self.pendingSnapshot = nil
            Task { await restoreSession(from: pendingSnapshot) }
            return
        }
        startSession()
    }

    func startSession() {
        hasStarted = true
        pendingSnapshot = nil
        Task { await sessionStore.clear() }
        cancelSessionTasks()
        store.dispatch(.prepareSession(maxQuestions: 20))

        if shouldFetchOnStart {
            fetchAPIDataAndStart()
        } else {
            store.dispatch(.showMessage(L10n.Game.loadingQuestion))
            loadAndShowQuestion()
        }
    }

    func answerYes() {
        guard question.buttonsEnabled else { return }
        feedback.playTap()
        store.dispatch(.lockAnswers)
        invalidateTimer()
        showAnswerResult(isCorrect: currentCorrectAnswer == true)
    }

    func answerNo() {
        guard question.buttonsEnabled else { return }
        feedback.playTap()
        store.dispatch(.lockAnswers)
        invalidateTimer()
        showAnswerResult(isCorrect: currentCorrectAnswer == false)
    }

    func playAgain() {
        feedback.playTap()
        startSession()
    }

    func leaveToMenu() {
        feedback.playTap()
        cancelSessionTasks()
        Task {
            await persistSession()
            store.dispatch(.requestDismiss)
        }
    }

    func dismissResult() {
        store.dispatch(.hideResult)
    }

    func stop() {
        cancelSessionTasks()
    }

    func persistSession() async {
        guard hasStarted else { return }
        if score.showResult {
            await sessionStore.clear()
            return
        }

        var index = score.currentQuestionIndex
        var includeCurrentQuestion = question.buttonsEnabled && question.posterImage != nil

        if !question.buttonsEnabled, question.posterImage != nil, !question.isLoading {

            index += 1
            includeCurrentQuestion = false
        }

        guard index < score.maxQuestions else {
            await sessionStore.clear()
            return
        }

        let snapshot = QuizSessionSnapshot(
            mode: activeMode,
            currentQuestionIndex: index,
            correctAnswers: score.correctAnswers,
            maxQuestions: score.maxQuestions,
            remainingTime: includeCurrentQuestion
                ? timer.remainingTime
                : TimeInterval(timerSettings.currentDuration),
            currentCorrectAnswer: includeCurrentQuestion ? currentCorrectAnswer : false,
            currentCorrectName: includeCurrentQuestion ? currentCorrectName : "",
            questionText: includeCurrentQuestion ? question.questionText : "",
            imageURL: includeCurrentQuestion ? currentImageURL : nil,
            engine: engine.exportProgress()
        )
        let image = includeCurrentQuestion ? encodedPoster() : nil
        await sessionStore.save(snapshot, questionImage: image)
    }

    private func restoreSession(from snapshot: QuizSessionSnapshot) async {
        hasStarted = true
        shouldFetchOnStart = false
        engine.restoreProgress(snapshot.engine)
        currentCorrectAnswer = snapshot.currentCorrectAnswer
        currentCorrectName = snapshot.currentCorrectName
        currentImageURL = snapshot.imageURL

        store.dispatch(
            .restoreProgress(
                currentQuestionIndex: snapshot.currentQuestionIndex,
                correctAnswers: snapshot.correctAnswers,
                maxQuestions: snapshot.maxQuestions
            )
        )

        if let image = await restoredPoster() {
            store.dispatch(
                .presentQuestion(
                    image: image,
                    text: snapshot.questionText
                )
            )
            startQuestionTimer(remaining: snapshot.remainingTime)
        } else {
            loadAndShowQuestion()
        }
    }

    private func restoredPoster() async -> UIImage? {
        guard let data = await sessionStore.loadQuestionImage() else { return nil }
        return UIImage(data: data)
    }

    private func encodedPoster() -> Data? {
        guard let image = question.posterImage else { return nil }
        return image.jpegData(compressionQuality: 0.85) ?? image.pngData()
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
        store.dispatch(.beginQuestionLoad)

        loadTask?.cancel()
        loadTask = Task {
            var qText = ""
            var qAnswer = false
            var qImage = UIImage()

            guard let (finalQuestion, image) = await quizService.makeDynamicQuestion(using: engine) else {
                guard !Task.isCancelled else { return }
                store.dispatch(.resetPosterBorder)
                showNextQuestionOrResults()
                return
            }
            qText = L10n.Game.characterNameQuestion(finalQuestion.questionText)
            qAnswer = finalQuestion.correctAnswer
            currentCorrectName = finalQuestion.correctName
            currentImageURL = finalQuestion.imageURL
            qImage = image

            guard !Task.isCancelled else { return }

            currentCorrectAnswer = qAnswer
            store.dispatch(
                .presentQuestion(
                    image: qImage,
                    text: qText
                )
            )
            startQuestionTimer()
        }
    }

    private func startQuestionTimer(remaining: TimeInterval? = nil) {
        invalidateTimer()
        let duration = remaining ?? TimeInterval(timerSettings.currentDuration)
        guard duration > 0 else { return }

        store.dispatch(.startTimer(duration))
        updateUrgencyHaptic()

        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(50))
                guard let self else { return }
                self.store.dispatch(.timerTick)
                self.updateUrgencyHaptic()
                if self.timer.remainingTime <= 0 {
                    self.invalidateTimer()
                    self.handleTimeExpired()
                    return
                }
            }
        }
    }

    private func updateUrgencyHaptic() {
        if timer.remainingTime > 0, timer.remainingTime < 3 {
            feedback.startUrgency()
        } else {
            feedback.stopUrgency()
        }
    }

    private func invalidateTimer() {
        timerTask?.cancel()
        timerTask = nil
        feedback.stopUrgency()
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
        if isCorrect {
            feedback.playSuccess()
        } else {
            feedback.playError()
        }

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
            Task { await sessionStore.clear() }
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
