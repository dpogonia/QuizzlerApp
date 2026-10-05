//
//  GameView.swift
//  Quizzler
//
//  Created by Dmitrii Pogonia on 26.05.2026.
//

import QuizUI
import SwiftUI

// Экран раунда: шапка, постер, вопрос, Да/Нет. Сам в API не ходит — читает QuizSessionViewModel (question / timer / score).
struct GameView: View {
    @ObservedObject var viewModel: QuizSessionViewModel // не создаём сами: меню передало уже собранную сессию. ObservedObject = просто слушаем, владелец снаружи
    @EnvironmentObject private var feedback: FeedbackController // музыка и тапы, тот же объект что положили в QuizzlerApp
    @Environment(\.dismiss) private var dismiss // закрыть этот экран и вернуться в меню
    @Environment(\.scenePhase) private var scenePhase // active / inactive / background — свернули приложение или нет

    var body: some View {
        VStack(spacing: QuizSpacing.stack) {
            GameHeaderView(viewModel: viewModel) // назад, таймер, 3/20
                .frame(height: 32)

            PosterFrameView( // рамка из QuizUI. картинка / цвет бордера / спиннер — из QuestionStore
                image: viewModel.question.posterImage,
                borderColor: viewModel.question.posterBorderColor,
                isLoading: viewModel.question.isLoading
            )
            .aspectRatio(2 / 3, contentMode: .fit)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Text(viewModel.question.questionText) // сначала «это Morty?», после ответа — имя зелёным/красным
                .font(QuizFont.question)
                .foregroundStyle(viewModel.question.questionColor)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity)
                .frame(height: 72)

            HStack(spacing: QuizSpacing.stack) {
                PrimaryAnswerButton(
                    title: L10n.Game.no,
                    isEnabled: viewModel.question.buttonsEnabled, // пока грузится или уже ответили — кнопки серые
                    action: viewModel.answerNo
                )
                PrimaryAnswerButton(
                    title: L10n.Game.yes,
                    isEnabled: viewModel.question.buttonsEnabled,
                    action: viewModel.answerYes
                )
            }
            .frame(height: 60)
        }
        .padding(.horizontal, QuizSpacing.screen)
        .padding(.top, QuizSpacing.compact)
        .padding(.bottom, QuizSpacing.compact)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(QuizColor.screenBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true) // системную стрелку прячем
        .onAppear {
            viewModel.startIfNeeded() // один раз: новая игра или restore с диска
            feedback.startGameMusic()
        }
        .onDisappear {
            feedback.stopGameMusic()
            viewModel.stop() // таймер и загрузки стоп
            Task { await viewModel.persistSession() } // снимок на диск, карточка «Продолжить»
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                feedback.startGameMusic()
            } else {
                feedback.pauseGameMusic() // в фон — музыку только пауза
            }
            if phase == .inactive || phase == .background {
                Task { await viewModel.persistSession() } // свернули - тоже пишем сессию, мало ли убьют процесс
            }
        }
        .onChange(of: viewModel.score.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                dismiss() // закрываем GameView
            }
        }
        .alert(viewModel.score.resultTitle, isPresented: Binding( // алерт «раунд окончен».
            get: { viewModel.score.showResult },
            set: { isPresented in
                if !isPresented {
                    viewModel.dismissResult()
                }
            }
        )) {
            Button(L10n.Game.playAgain) {
                viewModel.playAgain() // тот же режим заново играть
            }
            Button(L10n.Game.backToMenu, role: .cancel) {
                viewModel.leaveToMenu()
            }
        } message: {
            Text(viewModel.score.resultText)
        }
    }
}

private struct GameHeaderView: View { // только этот файл, снаружи не нужен
    @ObservedObject var viewModel: QuizSessionViewModel

    var body: some View {
        HStack(spacing: QuizSpacing.compact) {
            Button {
                viewModel.leaveToMenu()
            } label: {
                Image(systemName: SFSymbol.back)
                    .font(QuizFont.backSymbol)
                    .foregroundStyle(QuizColor.primaryText)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)

            Text(viewModel.timer.timerText)
                .font(QuizFont.header)
                .foregroundStyle(viewModel.timer.timerColor) // на последних секундах желтеет/краснеет в TimerStore
                .monospacedDigit()
                .frame(width: 92, alignment: .leading)

            Spacer(minLength: 0)

            Text(viewModel.score.counterText) // 3/20
                .font(QuizFont.header)
                .foregroundStyle(QuizColor.primaryText)
                .monospacedDigit()
                .frame(width: 72, alignment: .trailing)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 32)
    }
}
