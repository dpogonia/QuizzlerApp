//
//  SplashView.swift
//  Quizzler
//
//  Created by Dmitrii Pogonia on 04.06.2026.
//

import QuizServices
import QuizUI
import SwiftUI

struct SplashView: View {

    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var feedback: FeedbackController
    var onFinish: () -> Void

    @State private var showPartialError = false
    @State private var showBlocked = false
    @State private var errorText = ""

    var body: some View {
        ZStack {
            QuizColor.splashBackground.ignoresSafeArea()
            VStack(spacing: QuizSpacing.stack) {
                QuizHeroIcon(systemName: SFSymbol.popcorn, size: 125, color: QuizColor.splashIcon)
                    .frame(width: 140, height: 140)
                if showBlocked {
                    Text(errorText)
                        .font(QuizFont.body)
                        .foregroundStyle(QuizColor.splashIcon)
                        .multilineTextAlignment(.center)
                    Button(L10n.Splash.retry) {
                        feedback.playTap()
                        Task { await retry() }
                    }
                    .font(QuizFont.answer)
                    .foregroundStyle(QuizColor.splashBackground)
                    .padding(.horizontal, QuizSpacing.screen)
                    .padding(.vertical, QuizSpacing.compact)
                    .background(QuizColor.splashIcon)
                    .clipShape(RoundedRectangle(cornerRadius: QuizRadius.answer, style: .continuous))
                }
            }
            .padding(.horizontal, QuizSpacing.screen)
        }
        .task {
            await runLaunchSequence()
        }
        .alert(L10n.Start.errorTitle, isPresented: $showPartialError) {
            Button(L10n.Splash.retry) {
                feedback.playTap()
                Task { await retry() }
            }
            Button(L10n.Splash.continue, role: .cancel) {
                feedback.playTap()
                onFinish()
            }
        } message: {
            Text(errorText)
        }
    }

    private func retry() async {
        await environment.preloader.retryFailedLoads()
        await runLaunchSequence()
    }

    private func runLaunchSequence() async {
        showBlocked = false
        showPartialError = false
        await environment.preloader.startIfNeeded()
        try? await Task.sleep(for: .seconds(3))
        guard let error = await environment.preloader.latestError() else {
            onFinish()
            return
        }
        errorText = L10n.Splash.preloadError(error.localizedDescription)
        if await environment.preloader.allBanksUnavailable() {
            showBlocked = true
            return
        }
        showPartialError = true
    }
}
