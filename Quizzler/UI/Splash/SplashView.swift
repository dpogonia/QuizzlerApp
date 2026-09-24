import QuizServices
import QuizUI
import SwiftUI

struct SplashView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var feedback: FeedbackController
    var onFinish: () -> Void

    @State private var showError = false
    @State private var errorText = ""

    var body: some View {
        ZStack {
            QuizColor.splashBackground.ignoresSafeArea()
            QuizHeroIcon(systemName: SFSymbol.popcorn, size: 125, color: QuizColor.splashIcon)
                .frame(width: 140, height: 140)
        }
        .task {
            await runLaunchSequence()
        }
        .alert(L10n.Start.errorTitle, isPresented: $showError) {
            Button(L10n.Splash.retry) {
                feedback.playTap()
                Task {
                    await environment.preloader.retryFailedLoads()
                    await runLaunchSequence()
                }
            }
            Button(L10n.Splash.continue, role: .cancel) {
                feedback.playTap()
                onFinish()
            }
        } message: {
            Text(errorText)
        }
    }

    private func runLaunchSequence() async {
        await environment.preloader.startIfNeeded()
        try? await Task.sleep(for: .seconds(3))
        if let error = await environment.preloader.latestError() {
            errorText = L10n.Splash.preloadError(error.localizedDescription)
            showError = true
            return
        }
        onFinish()
    }
}
