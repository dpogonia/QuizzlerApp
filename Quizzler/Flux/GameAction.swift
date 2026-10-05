//
//  GameAction.swift
//  Quizzler
//
//  Created by Dmitrii Pogonia on 14.05.2026.
//

import SwiftUI
import UIKit

enum GameAction {
    case prepareSession(maxQuestions: Int)
    case showMessage(String)
    case beginSync
    case syncFailed(String)
    case beginQuestionLoad
    case presentQuestion(image: UIImage, text: String)
    case restoreProgress(
        currentQuestionIndex: Int,
        correctAnswers: Int,
        maxQuestions: Int
    )
    case lockAnswers
    case revealAnswer(isCorrect: Bool, name: String?)
    case advanceQuestion
    case finishRound(title: String, text: String)
    case resetPosterBorder
    case requestDismiss
    case hideResult
    case startTimer(TimeInterval)
    case timerTick
}
