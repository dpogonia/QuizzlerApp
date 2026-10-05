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

// Раскладываем сервисы по именам, чтобы экраны не звали ServiceLocator сами.
@MainActor // Меняем UI только на главном потоке
final class AppEnvironment: ObservableObject { // ObservableObject чтобы положить в SwiftUI через .environmentObject, но без Published тк это не UI
    let locator: ServiceLocator
    // Ярлыки из register. Тип any Протокол значит "кто умеет вот это", класс снаружи не важен
    let preloader: any QuizPreloading // сплэш качает банки Rick / SP / Big Mouth
    let scoreStore: any BestScoreStoring // рекорды в настройках
    let timerSettings: any QuizTimerSettingsProviding // сложность 1–10 сек
    let quizService: any DynamicQuizServing // собрать вопрос и картинку в раунде
    let sessionStore: any QuizSessionPersisting // "Продолжить": session.json
    let themeSettings: any ThemeSettingsProviding // светлая / тёмная / системная тема
    let languageSettings: any LanguageSettingsProviding // ru / en
    let hapticSettings: any HapticSettingsProviding // вибрация вкл/выкл
    let soundSettings: any SoundSettingsProviding // звук вкл/выкл

    // QuizzlerApp → bootstrap() → AppEnvironment(locator:) → RootView получает environment → сплэш берёт preloader, меню — sessionStore и quizService.
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
