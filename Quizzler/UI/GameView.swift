import QuizUI
import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: QuizSessionViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 8) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 28)

            VStack(spacing: 16) {
                PosterFrameView(
                    image: viewModel.question.posterImage,
                    fillContent: viewModel.question.usesPosterFill,
                    borderColor: viewModel.question.posterBorderColor,
                    isLoading: viewModel.question.isLoading
                )
                Text(viewModel.question.questionText)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(viewModel.question.questionColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity)
                    .frame(height: 72)
                HStack(spacing: 16) {
                    PrimaryAnswerButton(
                        title: "НЕТ",
                        isEnabled: viewModel.question.buttonsEnabled,
                        action: viewModel.answerNo
                    )
                    PrimaryAnswerButton(
                        title: "ДА",
                        isEnabled: viewModel.question.buttonsEnabled,
                        action: viewModel.answerYes
                    )
                }
                .frame(height: 60)
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemBackground))
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.startIfNeeded()
        }
        .onDisappear {
            viewModel.stop()
        }
        .onChange(of: viewModel.score.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
        .alert(viewModel.score.resultTitle, isPresented: Binding(
            get: { viewModel.score.showResult },
            set: { viewModel.score.showResult = $0 }
        )) {
            Button("Сыграть ещё раз") {
                viewModel.playAgain()
            }
            Button("К выбору игры", role: .cancel) {
                viewModel.leaveToMenu()
            }
        } message: {
            Text(viewModel.score.resultText)
        }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Button {
                viewModel.leaveToMenu()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)

            Text(viewModel.timer.timerText)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(viewModel.timer.timerColor)

            Spacer()

            Text(viewModel.score.counterText)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.primary)
        }
    }
}
