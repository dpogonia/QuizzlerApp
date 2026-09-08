import CoreServices
import SwiftUI

struct SplashView: View {
    var onFinish: () -> Void

    private let preloader: any QuizPreloading

    init(
        preloader: any QuizPreloading = ServiceLocator.shared.resolve(),
        onFinish: @escaping () -> Void
    ) {
        self.preloader = preloader
        self.onFinish = onFinish
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Image(systemName: "popcorn.fill")
                .font(.system(size: 125, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 140, height: 140)
        }
        .onAppear {
            preloader.startIfNeeded()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                onFinish()
            }
        }
    }
}
