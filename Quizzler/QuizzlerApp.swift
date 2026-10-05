//
//  QuizzlerApp.swift
//  Quizzler
//
//  Created by Dmitrii Pogonia on 03.02.2026.
//

import SwiftUI

@main
struct QuizzlerApp: App {
    @StateObject private var themeController: ThemeController
    @StateObject private var languageController: LanguageController
    @StateObject private var feedbackController: FeedbackController
    @StateObject private var environment: AppEnvironment

    init() {
        let locator = AppAssembly.bootstrap()
        let environment = AppEnvironment(locator: locator)

        _environment = StateObject(wrappedValue: environment)
        _themeController = StateObject(wrappedValue: ThemeController(themeSettings: environment.themeSettings))
        _languageController = StateObject(wrappedValue: LanguageController(languageSettings: environment.languageSettings))
        _feedbackController = StateObject(
            wrappedValue: FeedbackController(
                haptics: HapticController(settings: environment.hapticSettings),
                sounds: SoundController(settings: environment.soundSettings)
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(themeController.colorScheme)
                .environment(\.locale, languageController.locale)
                .environmentObject(themeController)
                .environmentObject(languageController)
                .environmentObject(feedbackController)
                .environmentObject(environment)
        }
    }
}
