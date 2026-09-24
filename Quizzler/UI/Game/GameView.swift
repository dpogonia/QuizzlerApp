import QuizUI
import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: QuizSessionViewModel
    @EnvironmentObject private var feedback: FeedbackController
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(spacing: QuizSpacing.stack) {
            GameHeaderView(viewModel: viewModel)
                .frame(height: 32)
                .layoutPriority(1)

            PosterFrameView(
                image: viewModel.question.posterImage,
                fillContent: viewModel.question.usesPosterFill,
                borderColor: viewModel.question.posterBorderColor,
                isLoading: viewModel.question.isLoading
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .layoutPriority(0)

            Text(viewModel.question.questionText)
                .font(viewModel.question.usesEmphasizedQuestion ? QuizFont.ratingReveal : QuizFont.question)
                .foregroundStyle(viewModel.question.questionColor)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity)
                .frame(height: 72)
                .layoutPriority(1)

            HStack(spacing: QuizSpacing.stack) {
                PrimaryAnswerButton(
                    title: L10n.Game.no,
                    isEnabled: viewModel.question.buttonsEnabled,
                    action: viewModel.answerNo
                )
                PrimaryAnswerButton(
                    title: L10n.Game.yes,
                    isEnabled: viewModel.question.buttonsEnabled,
                    action: viewModel.answerYes
                )
            }
            .frame(height: 60)
            .layoutPriority(1)
        }
        .padding(.horizontal, QuizSpacing.screen)
        .padding(.top, QuizSpacing.compact)
        .padding(.bottom, QuizSpacing.compact)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(QuizColor.screenBackground)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.startIfNeeded()
            feedback.startGameMusic()
        }
        .onDisappear {
            feedback.stopGameMusic()
            viewModel.stop()
            Task { await viewModel.persistSession() }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                feedback.startGameMusic()
            } else {
                feedback.pauseGameMusic()
            }
            if phase == .inactive || phase == .background {
                Task { await viewModel.persistSession() }
            }
        }
        .onChange(of: viewModel.score.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
        .alert(viewModel.score.resultTitle, isPresented: Binding(
            get: { viewModel.score.showResult },
            set: { isPresented in
                if !isPresented {
                    viewModel.dismissResult()
                }
            }
        )) {
            Button(L10n.Game.playAgain) {
                viewModel.playAgain()
            }
            Button(L10n.Game.backToMenu, role: .cancel) {
                viewModel.leaveToMenu()
            }
        } message: {
            Text(viewModel.score.resultText)
        }
    }
}

private struct GameHeaderView: View {
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
                .foregroundStyle(viewModel.timer.timerColor)
                .monospacedDigit()
                .frame(width: 92, alignment: .leading)

            Spacer(minLength: 0)

            Text(viewModel.score.counterText)
                .font(QuizFont.header)
                .foregroundStyle(QuizColor.primaryText)
                .monospacedDigit()
                .frame(width: 72, alignment: .trailing)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 32)
    }
}
