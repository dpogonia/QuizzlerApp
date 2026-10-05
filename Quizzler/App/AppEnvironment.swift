//
//  AppEnvironment.swift
//  Quizzler
//
//  Created by Dmitrii Pogonia on 10.05.2026.
//

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
    let sessionStore: any QuizSessionPersisting
    let themeSettings: any ThemeSettingsProviding
    let languageSettings: any LanguageSettingsProviding
    let hapticSettings: any HapticSettingsProviding
    let soundSettings: any SoundSettingsProviding

    init(locator: ServiceLocator) {
        self.locator = locator
        self.preloader = locator.resolve()
        self.scoreStore = locator.resolve()
        self.timerSettings = locator.resolve()
        self.quizService = locator.resolve()
        self.sessionStore = locator.resolve()
        self.themeSettings = locator.resolve()
        self.languageSettings = locator.resolve()
        self.hapticSettings = locator.resolve()
        self.soundSettings = locator.resolve()
    }
}
