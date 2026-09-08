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
            QuizHeroIcon(systemName: SFSymbol.popcorn, size: 88)
                .frame(width: 104, height: 104)
                .padding(.top, 24)

            Text(viewModel.header.bestResultText)
                .font(QuizFont.bestScore)
                .foregroundStyle(QuizColor.secondaryText)
                .frame(maxWidth: .infinity, minHeight: 22, alignment: .leading)
                .padding(.horizontal, QuizSpacing.screen)
                .padding(.top, QuizSpacing.compact)

            VStack(spacing: QuizSpacing.stack) {
                ForEach(viewModel.menu.modes, id: \.self) { mode in
                    ModeCardView(
                        symbolName: mode.symbolName,
                        title: mode.localizedTitle,
                        subtitle: mode.localizedSubtitle,
                        isDimmed: viewModel.menu.isLoading,
                        showsSpinner: viewModel.menu.loadingMode == mode
                    ) {
                        viewModel.menu.select(mode)
                    }
                }

                ModeCardView(
                    symbolName: SFSymbol.gear,
                    title: L10n.Start.settings,
                    subtitle: L10n.Start.settingsSubtitle,
                    isDimmed: viewModel.menu.isLoading
                ) {
                    showSettings = true
                }
            }
            .padding(.horizontal, QuizSpacing.screen)
            .padding(.top, 24)
            .allowsHitTesting(!viewModel.menu.isLoading)

            QuizLoadingStatus(text: L10n.Start.loading)
                .opacity(viewModel.menu.isLoading ? 1 : 0)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(QuizColor.screenBackground)
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
        .alert(L10n.Start.errorTitle, isPresented: Binding(
            get: { viewModel.menu.showError },
            set: { viewModel.menu.showError = $0 }
        )) {
            Button(L10n.Start.ok, role: .cancel) {}
        } message: {
            Text(viewModel.menu.errorMessage ?? "")
        }
    }
}

private extension GameMode {
    var symbolName: String {
        switch self {
        case .movies: return SFSymbol.film
        case .rickAndMorty: return SFSymbol.atom
        case .southPark: return SFSymbol.mountain
        case .bigMouth: return SFSymbol.smiling
        case .humanResources: return SFSymbol.people
        }
    }
}
