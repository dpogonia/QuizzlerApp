//
//  AppAssembly.swift
//  Quizzler
//
//  Created by Dmitrii Pogonia on 08.05.2026.
//

import CoreServices
import Foundation
import QuizServices

// Создаем один раз при старте все сервисы.
enum AppAssembly {
    @discardableResult
    static func bootstrap() -> ServiceLocator {
        
        // Клиент не создаёт зависимость сам и не получает её в init снаружи, он спрашивает локатор: дай сеть/кэш/настройки
        // Это обычный словарь в памяти: «какой тип нужен» → «вот готовый объект».
        // При старте приложения AppAssembly кладёт туда вещи: нужен качальщик сети → кладём URLSessionNetworkService, нужен переводчик JSON → кладём JSONParser, нужны настройки → кладём UserDefaultsStorage
        let locator = ServiceLocator.shared

        // Сеть
        let network = URLSessionNetworkService()
        // Парсер для имен и картинок
        let parser = JSONParser()
        // Сюда пишем то, что должно пережить перезапуск: сложность, рекорды, тема, язык, звук, вибрации
        let storage = UserDefaultsStorage()
        // Важные файлы
        let files = DiskFileStore(directory: .applicationSupportDirectory, folderName: "Quizzler")
        // Картинки
        let imageFiles = DiskFileStore(directory: .cachesDirectory, folderName: "QuizzlerImages")

        // ярлык «кто умеет качать байты» (NetworkServing) → этот конкретный URLSessionNetworkService. без register locator про него не знает. register = «запомни: по этому протоколу выдавай вот этот объект»
        locator.register((any NetworkServing).self, instance: network)
        locator.register((any JSONParsing).self, instance: parser)
        locator.register((any KeyValueStoring).self, instance: storage)

        // Таймер
        let timerSettings = QuizTimerSettingsService(storage: storage)
        // Рекорды
        let scoreStore = BestScoreStore(storage: storage, timerSettings: timerSettings)
        // Тема
        let themeSettings = ThemeSettingsService(storage: storage)
        // Язык
        let languageSettings = LanguageSettingsService(storage: storage)
        // Вибрация
        let hapticSettings = HapticSettingsService(storage: storage)
        // Звук
        let soundSettings = SoundSettingsService(storage: storage)
        // АПИ для игр
        let api = APINetworkManager(network: network, parser: parser, imageStore: imageFiles)
        // копии списков персонажей на диске, чтобы играть без сети после первого удачного сплэша
        let bankCache = QuizBankCache(files: files, parser: parser)
        // Пока идет сплэш скрин, параллельно качаются три "колоды": Rick, South Park, Big Mouth
        let preloader = QuizPreloader(network: api, bankCache: bankCache)
        // Это уже раунд. Когда открыл игру, он наполняет движок персонажами (свежая случайная страница API или то, что предзагрузчик уже держит)
        let quizService = DynamicQuizService(network: api, preloader: preloader)
        // карточка "Продолжить". в Application Support лежат session.json (режим, номер вопроса, счёт, таймер, кого уже спрашивали) и JPEG текущего кадра. Вышел в меню или свернул приложение - запись. Доиграл до конца - файл стирают.
        let sessionStore = QuizSessionStore(files: files, parser: parser)
        
        // Сплэш наполняет preloader/bankCache → игра берёт quizService → уход с экрана пишет sessionStore.

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
