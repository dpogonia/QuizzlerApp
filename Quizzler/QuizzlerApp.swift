import SwiftUI

@main
struct QuizzlerApp: App {
    @StateObject private var themeController: ThemeController
    @StateObject private var environment: AppEnvironment

    init() {
        let locator = AppAssembly.bootstrap()
        let environment = AppEnvironment(locator: locator)
        _environment = StateObject(wrappedValue: environment)
        _themeController = StateObject(wrappedValue: ThemeController(themeSettings: environment.themeSettings))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(themeController.colorScheme)
                .environmentObject(themeController)
                .environmentObject(environment)
        }
    }
}
