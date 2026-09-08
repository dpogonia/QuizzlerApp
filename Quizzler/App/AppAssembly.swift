import CoreServices
import Foundation
import QuizServices

enum AppAssembly {
    @discardableResult
    static func bootstrap() -> ServiceLocator {
        let locator = ServiceLocator.shared

        let network = URLSessionNetworkService()
        let parser = JSONParser()
        let storage = UserDefaultsStorage()

        locator.register((any NetworkServing).self, instance: network)
        locator.register((any JSONParsing).self, instance: parser)
        locator.register((any KeyValueStoring).self, instance: storage)

        let timerSettings = QuizTimerSettingsService(storage: storage)
        let scoreStore = BestScoreStore(storage: storage, timerSettings: timerSettings)
        let themeSettings = ThemeSettingsService(storage: storage)
        let api = APINetworkManager(network: network, parser: parser)
        let preloader = QuizPreloader(network: api)
        let quizService = DynamicQuizService(network: api, preloader: preloader)

        locator.register((any QuizTimerSettingsProviding).self, instance: timerSettings)
        locator.register((any BestScoreStoring).self, instance: scoreStore)
        locator.register((any ThemeSettingsProviding).self, instance: themeSettings)
        locator.register((any QuizNetworking).self, instance: api)
        locator.register((any QuizPreloading).self, instance: preloader)
        locator.register((any DynamicQuizServing).self, instance: quizService)

        return locator
    }
}
