import Combine
import CoreServices
import QuizServices
import SwiftUI

@MainActor
final class AppEnvironment: ObservableObject {
    let locator: ServiceLocator
    let preloader: any QuizPreloading
    let scoreStore: any BestScoreStoring
    let timerSettings: any QuizTimerSettingsProviding
    let quizService: any DynamicQuizServing
    let themeSettings: any ThemeSettingsProviding

    init(locator: ServiceLocator = .shared) {
        self.locator = locator
        self.preloader = locator.resolve()
        self.scoreStore = locator.resolve()
        self.timerSettings = locator.resolve()
        self.quizService = locator.resolve()
        self.themeSettings = locator.resolve()
    }
}
