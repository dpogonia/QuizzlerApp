import QuizServices
import SwiftUI

struct SplashView: View {
    @EnvironmentObject private var environment: AppEnvironment
    var onFinish: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Image(systemName: "popcorn.fill")
                .font(.system(size: 125, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 140, height: 140)
        }
        .onAppear {
            environment.preloader.startIfNeeded()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                onFinish()
            }
        }
    }
}
