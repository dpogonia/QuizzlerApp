import SwiftUI

@main
struct QuizzlerApp: App {
    @StateObject private var themeController: ThemeController

    init() {
        AppAssembly.bootstrap()
        _themeController = StateObject(wrappedValue: ThemeController())
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(themeController.colorScheme)
                .environmentObject(themeController)
        }
    }
}
