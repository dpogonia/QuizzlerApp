//
//  Models.swift
//  Quizzler
//
//  Created by Dmitrii Pogonia on 05.03.2026.
//

import CoreServices
import Foundation
import UIKit

// MARK: - Game Mode
enum GameMode: String, CaseIterable {
    case movies
    case rickAndMorty
    case southPark
    case bigMouth
    case humanResources

    var title: String {
        switch self {
        case .movies: return "Ratings IMDb"
        case .rickAndMorty: return "Rick and Morty"
        case .southPark: return "South Park"
        case .bigMouth: return "Big Mouth"
        case .humanResources: return "Human Resources"
        }
    }

    var description: String {
        switch self {
        case .movies:
            return "Угадай рейтинг фильма"
        case .rickAndMorty:
            return "Wubba Lubba Dub-Dub"
        case .southPark:
            return "Oh my God, they killed Kenny"
        case .bigMouth:
            return "Гормоны и монстры"
        case .humanResources:
            return "Офис монстров"
        }
    }

    var symbolName: String {
        switch self {
        case .movies: return "film"
        case .rickAndMorty: return "atom"
        case .southPark: return "mountain.2"
        case .bigMouth: return "face.smiling"
        case .humanResources: return "person.2"
        }
    }

    var isAPIMode: Bool {
        self != .movies
    }
}

// MARK: - App Theme
enum AppTheme: String, CaseIterable {
    case light
    case dark
    case system

    var title: String {
        switch self {
        case .light:  return "Светлая"
        case .dark:   return "Тёмная"
        case .system: return "Системная"
        }
    }
}

struct QuizVM {
    let image: UIImage
    let question: String
    let questionIndicator: String
    let correctAnswer: Bool
}

struct QuizResultsVM {
    let title: String
    let text: String
    let buttonText: String
}

// MARK: - Questions (Local)
struct StaticQuizQuestion {
    let image: String
    let question: String
    let correctAnswer: Bool
}

let localMovieQuestions: [StaticQuizQuestion] = [
    StaticQuizQuestion(
        image: "The Godfather",
        question: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: true
    ),
    StaticQuizQuestion(
        image: "The Dark Knight",
        question: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: true
    ),
    StaticQuizQuestion(
        image: "Kill Bill",
        question: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: true
    ),
    StaticQuizQuestion(
        image: "The Avengers",
        question: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: true
    ),
    StaticQuizQuestion(
        image: "Deadpool",
        question: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: true
    ),
    StaticQuizQuestion(
        image: "The Green Knight",
        question: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: true
    ),
    StaticQuizQuestion(
        image: "Old",
        question: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: false
    ),
    StaticQuizQuestion(
        image: "The Ice Age Adventures of Buck Wild",
        question: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: false
    ),
    StaticQuizQuestion(
        image: "Tesla",
        question: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: false
    ),
    StaticQuizQuestion(
        image: "Vivarium",
        question: "Рейтинг этого фильма больше чем 6?",
        correctAnswer: false
    )
]

// MARK: - Dynamic questions (API-based)
struct DynamicQuizQuestion {
    let imageURL: String
    let questionText: String
    /// Если `true` — правильный ответ "Да", иначе "Нет".
    let correctAnswer: Bool
    /// Настоящее имя персонажа (для показа после ответа).
    let correctName: String
}

// MARK: - Rick and Morty API Models
struct RMAPIResponse: Codable {
    let info: RMAPIInfo
    let results: [RMCharacter]
}

struct RMAPIInfo: Codable {
    let pages: Int
}

struct RMCharacter: Codable, IdentifiableEntity {
    let id: Int
    let name: String
    let status: String
    let species: String
    let origin: RMLocationReference
    let image: String
}

struct RMLocationReference: Codable {
    let name: String
}

// MARK: - South Park API Models
struct SPAPIResponse: Codable {
    let data: [SPCharacter]
}

struct SPCharacter: Codable, IdentifiableEntity {
    let id: Int
    let name: String
    let sex: String?
    let religion: String?
}

// MARK: - Big Mouth / Human Resources API Models (Fandom)
struct BMCharacter: IdentifiableEntity {
    let pageid: Int
    let name: String
    var id: Int { pageid }
}

struct FandomCategoryResponse: Codable {
    let query: FandomCategoryQuery
    struct FandomCategoryQuery: Codable {
        let categorymembers: [FandomCategoryMember]
    }
    struct FandomCategoryMember: Codable {
        let pageid: Int
        let title: String
        let ns: Int?
    }
}

// MARK: - Dynamic Quiz Logic

protocol QuizLogicProviding {
    func inject(rm characters: [RMCharacter])
    func inject(sp characters: [SPCharacter])
    func inject(bm characters: [BMCharacter])
    func inject(hr characters: [BMCharacter])
    func generateChallenge() -> DynamicQuizQuestion?
}

final class QuizLogicEngine: QuizLogicProviding {
    private var rmCharacters: [RMCharacter] = []
    private var spCharacters: [SPCharacter] = []
    private var bmCharacters: [BMCharacter] = []
    private var activeMode: GameMode = .rickAndMorty
    private var usedQuestionNames: Set<String> = []
    private var usedRMCharacterIDs: Set<Int> = []
    private var usedSPCharacterIDs: Set<Int> = []
    private var usedBMCharacterIDs: Set<Int> = []

    func inject(rm characters: [RMCharacter]) {
        // Фильтруем персонажей Rick and Morty с "пустыми" картинками:
        // если один и тот же URL изображения встречается у многих персонажей,
        // считаем его плейсхолдером и не используем такие записи.
        let groupedByImage = Dictionary(grouping: characters, by: { $0.image })
        let filtered = groupedByImage.flatMap { (key: String, value: [RMCharacter]) -> [RMCharacter] in
            // Оставляем только уникальные изображения
            return value.count == 1 ? value : []
        }
        rmCharacters = filtered.isEmpty ? characters : filtered
        activeMode = .rickAndMorty
        usedQuestionNames.removeAll()
        usedRMCharacterIDs.removeAll()
    }

    func inject(sp characters: [SPCharacter]) {
        spCharacters = characters
        activeMode = .southPark
        usedQuestionNames.removeAll()
        usedSPCharacterIDs.removeAll()
    }

    func inject(bm characters: [BMCharacter]) {
        bmCharacters = characters
        activeMode = .bigMouth
        usedQuestionNames.removeAll()
        usedBMCharacterIDs.removeAll()
    }

    func inject(hr characters: [BMCharacter]) {
        bmCharacters = characters
        activeMode = .humanResources
        usedQuestionNames.removeAll()
        usedBMCharacterIDs.removeAll()
    }

    func generateChallenge() -> DynamicQuizQuestion? {
        switch activeMode {
        case .rickAndMorty:
            return generateRMChallenge()
        case .southPark:
            return generateSPChallenge()
        case .bigMouth, .humanResources:
            return generateBMChallenge()
        case .movies:
            return nil
        }
    }

    // MARK: - Rick and Morty Logic
    private func generateRMChallenge() -> DynamicQuizQuestion? {
        let availableSubjects = rmCharacters.filter { !usedRMCharacterIDs.contains($0.id) }
        guard availableSubjects.count > 1 else { return nil }

        let allNames = Set(availableSubjects.map { $0.name })
        let remainingNames = allNames.subtracting(usedQuestionNames)
        guard !remainingNames.isEmpty else { return nil }

        guard let subject = availableSubjects.randomElement() else { return nil }

        let correctNameAvailable = !usedQuestionNames.contains(subject.name)
        let wrongPool = allNames.subtracting([subject.name]).subtracting(usedQuestionNames)
        let wrongNameAvailable = !wrongPool.isEmpty

        guard correctNameAvailable || wrongNameAvailable else { return nil }

        let useCorrectName: Bool
        if correctNameAvailable && wrongNameAvailable {
            useCorrectName = Bool.random()
        } else {
            useCorrectName = correctNameAvailable
        }

        let candidateName: String
        if useCorrectName {
            candidateName = subject.name
        } else {
            guard let wrong = wrongPool.randomElement() else { return nil }
            candidateName = wrong
        }

        usedQuestionNames.insert(candidateName)
        usedRMCharacterIDs.insert(subject.id)
        let statementIsTrue = (candidateName == subject.name)
        let question = "Имя этого персонажа — \(candidateName.uppercased())?"

        return DynamicQuizQuestion(
            imageURL: subject.image,
            questionText: question,
            correctAnswer: statementIsTrue,
            correctName: subject.name
        )
    }

    // MARK: - South Park Logic
    private func generateSPChallenge() -> DynamicQuizQuestion? {
        let availableSubjects = spCharacters.filter { !usedSPCharacterIDs.contains($0.id) }
        guard availableSubjects.count > 1 else { return nil }

        let allNames = Set(availableSubjects.map { $0.name })
        let remainingNames = allNames.subtracting(usedQuestionNames)
        guard !remainingNames.isEmpty else { return nil }

        guard let subject = availableSubjects.randomElement() else { return nil }

        let correctNameAvailable = !usedQuestionNames.contains(subject.name)
        let wrongPool = allNames.subtracting([subject.name]).subtracting(usedQuestionNames)
        let wrongNameAvailable = !wrongPool.isEmpty

        guard correctNameAvailable || wrongNameAvailable else { return nil }

        let useCorrectName: Bool
        if correctNameAvailable && wrongNameAvailable {
            useCorrectName = Bool.random()
        } else {
            useCorrectName = correctNameAvailable
        }

        let candidateName: String
        if useCorrectName {
            candidateName = subject.name
        } else {
            guard let wrong = wrongPool.randomElement() else { return nil }
            candidateName = wrong
        }

        usedQuestionNames.insert(candidateName)
        usedSPCharacterIDs.insert(subject.id)
        let statementIsTrue = (candidateName == subject.name)
        let question = "Имя этого персонажа — \(candidateName.uppercased())?"

        return DynamicQuizQuestion(
            imageURL: "spwiki:\(subject.name)",
            questionText: question,
            correctAnswer: statementIsTrue,
            correctName: subject.name
        )
    }

    // MARK: - Big Mouth / Human Resources Logic
    private func generateBMChallenge() -> DynamicQuizQuestion? {
        let availableSubjects = bmCharacters.filter { !usedBMCharacterIDs.contains($0.pageid) }
        guard availableSubjects.count > 1 else { return nil }

        let allNames = Set(availableSubjects.map { $0.name })
        let remainingNames = allNames.subtracting(usedQuestionNames)
        guard !remainingNames.isEmpty else { return nil }

        guard let subject = availableSubjects.randomElement() else { return nil }

        let correctNameAvailable = !usedQuestionNames.contains(subject.name)
        let wrongPool = allNames.subtracting([subject.name]).subtracting(usedQuestionNames)
        let wrongNameAvailable = !wrongPool.isEmpty

        guard correctNameAvailable || wrongNameAvailable else { return nil }

        let useCorrectName: Bool
        if correctNameAvailable && wrongNameAvailable {
            useCorrectName = Bool.random()
        } else {
            useCorrectName = correctNameAvailable
        }

        let candidateName: String
        if useCorrectName {
            candidateName = subject.name
        } else {
            guard let wrong = wrongPool.randomElement() else { return nil }
            candidateName = wrong
        }

        usedQuestionNames.insert(candidateName)
        usedBMCharacterIDs.insert(subject.pageid)
        let statementIsTrue = (candidateName == subject.name)
        let question = "Имя этого персонажа — \(candidateName.uppercased())?"

        return DynamicQuizQuestion(
            imageURL: "bmwiki:\(subject.name)",
            questionText: question,
            correctAnswer: statementIsTrue,
            correctName: subject.name
        )
    }

}

