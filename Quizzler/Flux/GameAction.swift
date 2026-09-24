import SwiftUI
import UIKit

enum GameAction {
    case prepareSession(maxQuestions: Int, usesPosterFill: Bool)
    case showMessage(String)
    case beginSync
    case syncFailed(String)
    case beginQuestionLoad(showSpinner: Bool)
    case presentQuestion(image: UIImage, text: String, usesPosterFill: Bool)
    case restoreProgress(
        currentQuestionIndex: Int,
        correctAnswers: Int,
        maxQuestions: Int,
        usesPosterFill: Bool
    )
    case lockAnswers
    case revealAnswer(isCorrect: Bool, name: String?, emphasized: Bool)
    case advanceQuestion
    case finishRound(title: String, text: String)
    case resetPosterBorder
    case requestDismiss
    case hideResult
    case startTimer(TimeInterval)
    case timerTick
}
