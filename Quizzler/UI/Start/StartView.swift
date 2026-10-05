//
//  StartView.swift
//  Quizzler
//
//  Created by Dmitrii Pogonia on 10.06.2026.
//

import QuizServices
import QuizUI
import SwiftUI

// Меню режимов. Сам ViewModel не держит — собирает из шкафа и отдаёт StartScreen.
struct StartView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var feedback: FeedbackController

    var body: some View {
        StartScreen(
            viewModel: StartViewModel(
                preloader: environment.preloader,
                quizService: environment.quizService,
                scoreStore: environment.scoreStore,
                timerSettings: environment.timerSettings,
                sessionStore: environment.sessionStore,
                feedback: feedback
            )
        )
    }
}

private struct StartScreen: View { // StateObject здесь, чтобы меню не пересоздалось при перерисовке StartView
    @StateObject private var viewModel: StartViewModel
    @State private var showSettings = false
    @EnvironmentObject private var languageController: LanguageController
    @EnvironmentObject private var feedback: FeedbackController

    init(viewModel: StartViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                QuizHeroIcon(systemName: SFSymbol.popcorn, size: 88)
                    .frame(width: 104, height: 104)
                    .padding(.top, 24)

                VStack(spacing: QuizSpacing.stack) {
                    if let savedSession = viewModel.menu.savedSession { // карточка «Продолжить», если на диске есть снимок
                        ModeCardView(
                            symbolName: SFSymbol.play,
                            title: L10n.Start.continueGame,
                            subtitle: L10n.Start.continueSubtitle(
                                savedSession.mode.localizedTitle,
                                QuizFormatters.scorePair(
                                    correct: savedSession.currentQuestionIndex + 1,
                                    total: savedSession.maxQuestions
                                )
                            ),
                            isDimmed: viewModel.menu.isLoading,
                            showsSpinner: viewModel.menu.loadingMode == savedSession.mode
                        ) {
                            viewModel.menu.continueSavedSession()
                        }
                    }

                    ForEach(viewModel.menu.modes, id: \.self) { mode in // четыре режима + шестерёнка ниже
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
                        feedback.playTap()
                        showSettings = true
                    }
                }
                .padding(.horizontal, QuizSpacing.screen)
                .padding(.top, 24)
                .allowsHitTesting(!viewModel.menu.isLoading)

                QuizLoadingStatus(text: L10n.Start.loading)
                    .opacity(viewModel.menu.isLoading ? 1 : 0)
                    .padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(QuizColor.screenBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.onAppear() // докачать банки если надо и подтянуть карточку «Продолжить»
        }
        .onChange(of: viewModel.menu.navigateToGame) { _, isPresented in
            if !isPresented {
                Task { await viewModel.menu.refreshSavedSession() } // вернулись из игры — снимок мог появиться или стереться
            }
        }
        .navigationDestination(isPresented: $showSettings) {
            SettingsView()
        }
        .navigationDestination(isPresented: Binding(
            get: { viewModel.menu.navigateToGame },
            set: { viewModel.menu.navigateToGame = $0 }
        )) {
            if let session = viewModel.menu.session { // сессию собрал ModeMenuViewModel.start
                GameView(viewModel: session)
            }
        }
        .alert(L10n.Start.errorTitle, isPresented: Binding(
            get: { viewModel.menu.showError },
            set: { viewModel.menu.showError = $0 }
        )) {
            Button(L10n.Start.ok, role: .cancel) {
                feedback.playTap()
            }
        } message: {
            Text(viewModel.menu.errorMessage ?? "")
        }
        .alert(L10n.Start.resumeTitle, isPresented: Binding( // ткнули режим, у которого уже есть сохранённый раунд
            get: { viewModel.menu.showResumePrompt },
            set: { viewModel.menu.showResumePrompt = $0 }
        )) {
            Button(L10n.Start.resumeContinue) {
                viewModel.menu.confirmResumeSavedSession()
            }
            Button(L10n.Start.resumeNew) {
                viewModel.menu.confirmStartNewSession()
            }
            Button(L10n.Start.cancel, role: .cancel) {
                feedback.playTap()
            }
        } message: {
            Text(L10n.Start.resumeMessage)
        }
    }
}

private extension GameMode { // иконки карточек, тексты — в QuizLocalization
    var symbolName: String {
        switch self {
        case .rickAndMorty: return SFSymbol.atom
        case .southPark: return SFSymbol.mountain
        case .bigMouth: return SFSymbol.smiling
        case .humanResources: return SFSymbol.people
        }
    }
}
