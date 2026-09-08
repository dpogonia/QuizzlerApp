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
                poster
                question
                buttons
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 0)
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
        .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
        .alert(viewModel.resultTitle, isPresented: $viewModel.showResult) {
            Button("Сыграть ещё раз") {
                viewModel.playAgain()
            }
            Button("К выбору игры", role: .cancel) {
                viewModel.leaveToMenu()
            }
        } message: {
            Text(viewModel.resultText)
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

            Text(viewModel.timerText)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(viewModel.timerColor)

            Spacer()

            Text(viewModel.counterText)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.primary)
        }
    }

    private var poster: some View {
        ZStack {
            Color.black
            if let image = viewModel.posterImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: viewModel.usesPosterFill ? .fill : .fit)
            }
            if viewModel.isLoading {
                ProgressView()
                    .controlSize(.large)
                    .tint(Color.primary)
            }
        }
        .aspectRatio(2 / 3, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(viewModel.posterBorderColor, lineWidth: 16)
        }
    }

    private var question: some View {
        Text(viewModel.questionText)
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(viewModel.questionColor)
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .truncationMode(.tail)
            .frame(maxWidth: .infinity)
            .frame(height: 72)
    }

    private var buttons: some View {
        HStack(spacing: 16) {
            answerButton(title: "НЕТ", action: viewModel.answerNo)
            answerButton(title: "ДА", action: viewModel.answerYes)
        }
        .frame(height: 60)
        .padding(.bottom, 8)
    }

    private func answerButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color(.systemBackground))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.primary)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.primary, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .opacity(viewModel.buttonsEnabled ? 1 : 0.5)
        .disabled(!viewModel.buttonsEnabled)
    }
}
