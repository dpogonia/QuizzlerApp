//
//  QuizzlerApp.swift
//  Quizzler
//
//  Created by Dmitrii Pogonia on 03.02.2026.
//

import SwiftUI

@main // вход в приложение
struct QuizzlerApp: App {
    // QuizzlerApp — @StateObject (создал при init). Экраны — @EnvironmentObject (подписались). объекты, которые живут всё время, пока приложение открыто. SwiftUI их не пересоздаёт при каждой перерисовке body
    @StateObject private var themeController: ThemeController
    @StateObject private var languageController: LanguageController
    @StateObject private var feedbackController: FeedbackController
    @StateObject private var environment: AppEnvironment

    init() { // сборка до первого кадра
        let locator = AppAssembly.bootstrap() // Service Locator: парсер, сеть, кэш, квиз, настройки.
        let environment = AppEnvironment(locator: locator) // удобный доступ к тем же сервисам
        // В init нельзя просто написать self.environment = ... так как объект ещё не готов. Кладём значение в обёртку. То же для темы, языка, feedback. Порядок важен: сначала environment, потом контроллеры — они берут environment.themeSettings
        _environment = StateObject(wrappedValue: environment)
        _themeController = StateObject(wrappedValue: ThemeController(themeSettings: environment.themeSettings)) // тема
        _languageController = StateObject(wrappedValue: LanguageController(languageSettings: environment.languageSettings)) // язык
        _feedbackController = StateObject( // вибрации и звуки. FeedbackController внутри создаёт HapticController и SoundController
            wrappedValue: FeedbackController(
                haptics: HapticController(settings: environment.hapticSettings),
                sounds: SoundController(settings: environment.soundSettings)
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(themeController.colorScheme) // тема
                .environment(\.locale, languageController.locale) // системная локаль
            // кладем environmentObjects в рут вью
            // те же объекты, что создали в init, становятся доступны через @EnvironmentObject на Splash / Start / Game / Settings.
                .environmentObject(themeController)
                .environmentObject(languageController)
                .environmentObject(feedbackController)
                .environmentObject(environment)
        }
    }
}
