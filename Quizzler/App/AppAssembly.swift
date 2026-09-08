import CoreServices
import Foundation
import QuizServices

enum AppAssembly {
    static func bootstrap() {
        let locator = ServiceLocator.shared

        locator.register((any NetworkServing).self, instance: URLSessionNetworkService())
        locator.register((any JSONParsing).self, instance: JSONParser())
        locator.register((any KeyValueStoring).self, instance: UserDefaultsStorage())

        locator.register((any QuizTimerSettingsProviding).self, instance: QuizTimerSettingsService())
        locator.register((any BestScoreStoring).self, instance: BestScoreStore())
        locator.register((any ThemeSettingsProviding).self, instance: ThemeSettingsService())

        locator.register((any QuizNetworking).self, instance: APINetworkManager())
        locator.register((any QuizPreloading).self, instance: QuizPreloader())
        locator.register((any DynamicQuizServing).self, instance: DynamicQuizService())
    }
}
