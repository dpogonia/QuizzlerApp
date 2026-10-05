//
//  GameStore.swift
//  Quizzler
//
//  Created by Dmitrii Pogonia on 14.05.2026.
//

import Combine
import QuizUI
import SwiftUI
import UIKit

// Action = что случилось. Store = как из этого получается картинка на экране

@MainActor
final class QuestionStore: ObservableObject { // то, что в середине экрана
    @Published fileprivate(set) var posterImage: UIImage? // картинка или nil
    @Published fileprivate(set) var questionText = "" // вопрос или имя после ответа
    @Published fileprivate(set) var questionColor: Color = QuizColor.primaryText
    @Published fileprivate(set) var posterBorderColor: Color = QuizColor.posterBorder // белая / зелёная / красная рамка
    @Published fileprivate(set) var isLoading = false // спиннер
    @Published fileprivate(set) var buttonsEnabled = false // можно ли жать Да/Нет
}

@MainActor
final class TimerStore: ObservableObject { // текст 00:00, цвет, сколько секунд осталось
    @Published fileprivate(set) var timerText = ""
    @Published fileprivate(set) var timerColor: Color = QuizColor.primaryText
    @Published fileprivate(set) var remainingTime: TimeInterval = 0
}

@MainActor
final class ScoreStore: ObservableObject { // 3/20, индекс, сколько верных, лимит 20, алерт результата, флаг "закрой экран"
    @Published fileprivate(set) var counterText = "0/0" // fileprivate(set) - снаружи можно только читать. Пишет только функция dispatch в этом файле
    @Published fileprivate(set) var currentQuestionIndex = 0
    @Published fileprivate(set) var correctAnswers = 0
    @Published fileprivate(set) var maxQuestions = 20
    @Published fileprivate(set) var showResult = false
    @Published fileprivate(set) var resultTitle = ""
    @Published fileprivate(set) var resultText = ""
    @Published fileprivate(set) var shouldDismiss = false
}

@MainActor
final class GameStore: ObservableObject { // единственное место, где события из GameAction меняют экран
    let question: QuestionStore
    let timer: TimerStore
    let score: ScoreStore

    private var cancellables = Set<AnyCancellable>() // cancellables — коробка, где лежат живые подписки Combine. В bindNestedStores делается так: «когда question / timer / score собрались обновиться — дёрни GameStore». Результат .sink { ... } — это объект-подписка типа AnyCancellable. Если его нигде не сохранить, Swift сразу его выкинет, подписка оборвётся, экран перестанет узнавать, что постер изменился. .store(in: &cancellables) кладёт подписку в Set. Пока жив GameStore, жив и набор — слушатели работают. Когда GameStore уничтожается (вышли из игры), набор тоже умирает, подписки отменяются сами. Отсюда имя: cancellable = «можно отменить». Это не список action и не кэш картинок. Только «не забудь слушать вложенные сторы, пока идёт раунд».

    init(question: QuestionStore, timer: TimerStore, score: ScoreStore) { // кладёт три стора и вызывает bindNestedStores()
        self.question = question
        self.timer = timer
        self.score = score
        bindNestedStores()
    }

    convenience init() {
        self.init(question: QuestionStore(), timer: TimerStore(), score: ScoreStore())
    }

    // единственный вход в картинку раунда: не View, не сервисы, только этот store и его dispatch
    func dispatch(_ action: GameAction) { // switch: пришёл action → правим поля
        switch action {
        case .prepareSession(let maxQuestions): // всё обнулить, счётчик 0/20
            question.posterImage = nil
            question.questionText = ""
            question.questionColor = QuizColor.primaryText
            question.posterBorderColor = QuizColor.posterBorder
            question.isLoading = false
            question.buttonsEnabled = false
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

        case .showMessage(let text): // только текст
            question.questionText = text

        case .beginSync: // кнопки выкл, спиннер, «синхронизация»
            question.buttonsEnabled = false
            question.isLoading = true
            question.posterImage = nil
            question.questionText = L10n.Game.syncing
            score.counterText = QuizFormatters.scorePair(correct: 0, total: score.maxQuestions)

        case .syncFailed(let message): // спиннер стоп, текст ошибки
            question.isLoading = false
            question.posterBorderColor = QuizColor.posterBorder
            question.questionText = message

        case .beginQuestionLoad: // пустой кадр, спиннер, старое имя не висит.
            question.buttonsEnabled = false
            question.isLoading = true
            question.posterImage = nil
            question.posterBorderColor = QuizColor.posterBorder
            question.questionText = ""
            question.questionColor = QuizColor.primaryText

        case .presentQuestion(let image, let text): // картинка и вопрос, кнопки вкл, в шапке номер index + 1
            question.posterImage = image
            question.questionColor = QuizColor.primaryText
            question.questionText = text
            question.isLoading = false
            question.buttonsEnabled = true
            score.counterText = QuizFormatters.scorePair(
                correct: score.currentQuestionIndex + 1,
                total: score.maxQuestions
            )

        case .restoreProgress(let currentQuestionIndex, let correctAnswers, let maxQuestions): // подставить сохранённый прогресс, кнопки пока выкл (картинку потом дорисует ViewModel)
            question.questionColor = QuizColor.primaryText
            question.posterBorderColor = QuizColor.posterBorder
            question.isLoading = false
            question.buttonsEnabled = false
            score.currentQuestionIndex = currentQuestionIndex
            score.correctAnswers = correctAnswers
            score.maxQuestions = maxQuestions
            score.showResult = false
            score.resultTitle = ""
            score.resultText = ""
            score.shouldDismiss = false
            score.counterText = QuizFormatters.scorePair(
                correct: currentQuestionIndex + 1,
                total: maxQuestions
            )

        case .lockAnswers: // только кнопки выкл.
            question.buttonsEnabled = false

        case .revealAnswer(let isCorrect, let name): // если верно, correctAnswers += 1; рамка и имя зелёные или красные
            if isCorrect {
                score.correctAnswers += 1
            }
            question.posterBorderColor = isCorrect ? QuizColor.success : QuizColor.danger
            if let name, !name.isEmpty {
                question.questionColor = isCorrect ? QuizColor.success : QuizColor.danger
                question.questionText = name.uppercased()
            }

        case .advanceQuestion: // индекс +1
            score.currentQuestionIndex += 1

        case .finishRound(let title, let text): // показать алерт.
            question.isLoading = false
            question.posterBorderColor = QuizColor.posterBorder
            score.resultTitle = title
            score.resultText = text
            score.showResult = true

        case .resetPosterBorder: // белая рамка
            question.isLoading = false
            question.posterBorderColor = QuizColor.posterBorder

        case .requestDismiss: // shouldDismiss = true, GameView делает dismiss()
            score.shouldDismiss = true

        case .hideResult: // спрятать алерт
            score.showResult = false

        case .startTimer(let duration): // записать секунды и обновить текст
            timer.remainingTime = duration
            applyTimerDisplay()

        case .timerTick: // вычесть 0.05, не уйти ниже нуля
            timer.remainingTime = max(timer.remainingTime - 0.05, 0)
            applyTimerDisplay()
        }
    }

    private func applyTimerDisplay() { // из секунд делает SS:CC (секунды и сотые). На нуле красный, меньше 3 сек — жёлтый
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

    private func bindNestedStores() { // у вложенного стора свой objectWillChange. GameView подписан на GameStore. Поэтому три сигнала склеивают и шлют наверх: иначе постер обновился бы, а экран мог не перерисоваться.
        question.objectWillChange
            .merge(with: timer.objectWillChange)
            .merge(with: score.objectWillChange)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}
