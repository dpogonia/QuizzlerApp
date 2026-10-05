//
//  AppAssembly.swift
//  Quizzler
//
//  Created by Dmitrii Pogonia on 08.05.2026.
//

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

        let files = DiskFileStore(directory: .applicationSupportDirectory, folderName: "Quizzler")

        let imageFiles = DiskFileStore(directory: .cachesDirectory, folderName: "QuizzlerImages")


        locator.register((any NetworkServing).self, instance: network)
        locator.register((any JSONParsing).self, instance: parser)
        locator.register((any KeyValueStoring).self, instance: storage)


        let timerSettings = QuizTimerSettingsService(storage: storage)

        let scoreStore = BestScoreStore(storage: storage, timerSettings: timerSettings)

        let themeSettings = ThemeSettingsService(storage: storage)

        let languageSettings = LanguageSettingsService(storage: storage)

        let hapticSettings = HapticSettingsService(storage: storage)

        let soundSettings = SoundSettingsService(storage: storage)

        let api = APINetworkManager(network: network, parser: parser, imageStore: imageFiles)

        let bankCache = QuizBankCache(files: files, parser: parser)

        let preloader = QuizPreloader(network: api, bankCache: bankCache)

        let quizService = DynamicQuizService(network: api, preloader: preloader)

        let sessionStore = QuizSessionStore(files: files, parser: parser)



        locator.register((any QuizTimerSettingsProviding).self, instance: timerSettings)
        locator.register((any BestScoreStoring).self, instance: scoreStore)
        locator.register((any ThemeSettingsProviding).self, instance: themeSettings)
        locator.register((any LanguageSettingsProviding).self, instance: languageSettings)
        locator.register((any HapticSettingsProviding).self, instance: hapticSettings)
        locator.register((any SoundSettingsProviding).self, instance: soundSettings)
        locator.register((any QuizNetworking).self, instance: api)
        locator.register((any QuizPreloading).self, instance: preloader)
        locator.register((any DynamicQuizServing).self, instance: quizService)
        locator.register((any QuizSessionPersisting).self, instance: sessionStore)

        return locator
    }
}
