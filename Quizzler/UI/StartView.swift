import QuizServices
import QuizUI
import SwiftUI

struct StartView: View {
    @EnvironmentObject private var environment: AppEnvironment

    var body: some View {
        StartScreen(
            viewModel: StartViewModel(
                preloader: environment.preloader,
                quizService: environment.quizService,
                scoreStore: environment.scoreStore,
                timerSettings: environment.timerSettings
            )
        )
    }
}

private struct StartScreen: View {
    @StateObject private var viewModel: StartViewModel
    @State private var showSettings = false

    init(viewModel: StartViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "popcorn.fill")
                .font(.system(size: 88, weight: .bold))
                .foregroundStyle(Color.primary)
                .frame(width: 104, height: 104)
                .padding(.top, 24)

            Text(viewModel.header.bestResultText)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 8)

            VStack(spacing: 16) {
                ForEach(viewModel.menu.modes, id: \.self) { mode in
                    ModeCardView(
                        symbolName: mode.symbolName,
                        title: mode.title,
                        subtitle: mode.description,
                        isDimmed: viewModel.menu.isLoading,
                        showsSpinner: viewModel.menu.loadingMode == mode
                    ) {
                        viewModel.menu.select(mode)
                    }
                }

                ModeCardView(
                    symbolName: "gearshape",
                    title: "Settings",
                    subtitle: "Рекорды, таймер, тема",
                    isDimmed: viewModel.menu.isLoading
                ) {
                    showSettings = true
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .allowsHitTesting(!viewModel.menu.isLoading)

            if viewModel.menu.isLoading {
                ProgressView()
                    .padding(.top, 24)
                Text("Loading...")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.secondary)
                    .padding(.top, 8)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.onAppear()
        }
        .navigationDestination(isPresented: $showSettings) {
            SettingsView()
        }
        .navigationDestination(isPresented: Binding(
            get: { viewModel.menu.navigateToGame },
            set: { viewModel.menu.navigateToGame = $0 }
        )) {
            if let session = viewModel.menu.session {
                GameView(viewModel: session)
            }
        }
        .alert("Ошибка", isPresented: Binding(
            get: { viewModel.menu.showError },
            set: { viewModel.menu.showError = $0 }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.menu.errorMessage ?? "")
        }
    }
}
