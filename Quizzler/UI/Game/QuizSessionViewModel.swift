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

// вью модель основного игрового экрана
@MainActor
final class QuizSessionViewModel: ObservableObject {
    private let engine: QuizLogicProviding // кого уже спрашивали, из какого банка брать следующего
    private let quizService: any DynamicQuizServing // вопрос + картинка
    private let scoreRepository: any BestScoreStoring // рекорд в настройки
    private let timerSettings: any QuizTimerSettingsProviding // 5/10/15 сек
    private let sessionStore: any QuizSessionPersisting // session.json + jpeg кадра
    private let feedback: any FeedbackPlaying // тап / успех / ошибка / вибрация на последних секундах

    let store: GameStore // состояние раунда меняется только через store.dispatch(...), а не прямым присваиванием question.posterImage из ViewModel.
    let activeMode: GameMode

    var question: QuestionStore { store.question } // ярлыки, чтобы View писал viewModel.question, а не viewModel.store.question
    var timer: TimerStore { store.timer }
    var score: ScoreStore { store.score }

    private var currentCorrectAnswer = false // правда ли на этом кадре «да»
    private var currentCorrectName = "" // имя, которое покажем после ответа
    private var currentImageURL: String? // урл кадра, в снимок сессии
    private var pendingSnapshot: QuizSessionSnapshot? // если зашли через «Продолжить» — ждём onAppear
    private var shouldFetchOnStart = true // false, если меню уже впрыснуло банк (configureWith…)
    private var timerTask: Task<Void, Never>? // тики каждые 50 мс
    private var loadTask: Task<Void, Never>? // качаем вопрос
    private var revealTask: Task<Void, Never>? // пауза 1.5 сек на зелёной/красной рамке
    private var hasStarted = false
    private var cancellables = Set<AnyCancellable>() // подписка: стор тронут тогда ViewModel тоже objectWillChange, иначе @ObservedObject не увидит question/timer/score. @ObservedObject на GameView слушает только QuizSessionViewModel.objectWillChange. Не GameStore и не QuestionStore. Постер живёт в store.question.posterImage. Это другой ObservableObject. ViewModel его не хранит как @Published: store — обычный let, question — вычисляемое свойство. Когда dispatch меняет картинку, ViewModel сама не дёргается. Для SwiftUI сессия «не изменилась» — экран не перерисуется.
    
    /*
     Цепочка такая:

     QuestionStore / TimerStore / ScoreStore меняют @Published
     в GameStore подписки пробрасывают это в GameStore.objectWillChange
     этот sink пробрасывает дальше: self?.objectWillChange.send() у ViewModel
     @ObservedObject видит ViewModel → body читает уже новый viewModel.question.posterImage
     Без пункта 3 стор обновится, ViewModel молчит, GameView смотрит на старый кадр.

     cancellables — чтобы .sink не умер сразу: подписку кладут в Set, пока жива ViewModel.

     Итого: вложенный стор сам по себе @ObservedObject не будит. Нужно руками сказать: «стор тронули — считай, что тронули и меня».
     */

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

        // Без .store(in:) объект подписки (AnyCancellable) сразу выкинется, sink отменится. cancellables держит его живым. publisher шлёт, sink ловит.
        store.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    // меню уже скачало банк — не ходим в сеть ещё раз на старте раунда
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

    func prepareRestore(_ snapshot: QuizSessionSnapshot) { // «Продолжить»: снимок кладём, старт будет в onAppear
        pendingSnapshot = snapshot
        shouldFetchOnStart = false
    }

    func startIfNeeded() { // GameView.onAppear. второй раз (вернулись из фона) не перезапускаем раунд
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
        Task { await sessionStore.clear() } // новая игра затирает старый снимок
        cancelSessionTasks()
        store.dispatch(.prepareSession(maxQuestions: 20))

        if shouldFetchOnStart {
            fetchAPIDataAndStart() // банка в движке ещё нет
        } else {
            store.dispatch(.showMessage(L10n.Game.loadingQuestion))
            loadAndShowQuestion()
        }
    }

    func answerYes() {
        guard question.buttonsEnabled else { return } // двойной тап пока идёт reveal — игнор
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
            store.dispatch(.requestDismiss) // GameView смотрит shouldDismiss и делает dismiss()
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
        if score.showResult { // раунд доиграли — файл «Продолжить» не нужен
            await sessionStore.clear()
            return
        }

        var index = score.currentQuestionIndex
        var includeCurrentQuestion = question.buttonsEnabled && question.posterImage != nil // ещё отвечаем — сохраняем этот кадр

        if !question.buttonsEnabled, question.posterImage != nil, !question.isLoading {
            // уже показали верно/неверно, через секунду будет следующий — в снимок кладём уже следующий номер, без картинки
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

    private func restoreSession(from snapshot: QuizSessionSnapshot) async { // двигатель, счёт, картинка с диска, таймер сколько оставалось
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
            loadAndShowQuestion() // jpeg не нашли — просто новый вопрос, прогресс движка уже восстановлен
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

    private func fetchAPIDataAndStart() { // редкий путь: открыли игру без предзагрузки банка
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

    private func loadAndShowQuestion() { // beginQuestionLoad чистит старый постер, иначе на мгновение висит прошлый кадр
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
                showNextQuestionOrResults() // банк кончился / ошибка картинки — идём дальше или к результатам
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

    private func startQuestionTimer(remaining: TimeInterval? = nil) { // remaining — если restore, иначе длительность из настроек
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

    private func updateUrgencyHaptic() { // последние 3 секунды — тихая вибрация
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

    private func handleTimeExpired() { // время вышло = как неверный ответ
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
            try? await Task.sleep(for: .seconds(1.5)) // рамка повисит, потом следующий вопрос
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
