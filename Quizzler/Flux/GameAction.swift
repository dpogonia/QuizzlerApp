//
//  GameAction.swift
//  Quizzler
//
//  Created by Dmitrii Pogonia on 14.05.2026.
//

import SwiftUI
import UIKit

enum GameAction { // Список событий. Не класс, экземпляров нет. Это перечень того, что случилось в раунде.
    case prepareSession(maxQuestions: Int) // новый раунд, обычно 20 вопросов
    case showMessage(String) // просто текст под постером, например «загрузка»
    case beginSync // ждём персонажей с сервера
    case syncFailed(String) // сеть не дала банк, показать ошибку
    case beginQuestionLoad // чистим кадр, крутим спиннер
    case presentQuestion(image: UIImage, text: String) // живой вопрос: картинка + "это Морти?"
    case restoreProgress( // "Продолжить": вернуть номер, счёт, лимит
        currentQuestionIndex: Int,
        correctAnswers: Int,
        maxQuestions: Int
    )
    case lockAnswers // тап или ноль на таймере - залипание кнопок
    case revealAnswer(isCorrect: Bool, name: String?) // зелёная/красная рамка и имя персонажа
    case advanceQuestion // счётчик вопроса +1
    case finishRound(title: String, text: String) // алерт "раунд окончен"
    case resetPosterBorder // рамка снова белая
    case requestDismiss // закрыть игровой экран
    case hideResult // закрыли алерт результата
    case startTimer(TimeInterval) // завести секунды на вопрос
    case timerTick // минус 0.05 сек
}
