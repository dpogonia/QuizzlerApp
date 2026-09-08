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
public enum GameMode: String, CaseIterable, Sendable {
    case movies
    case rickAndMorty
    case southPark
    case bigMouth
    case humanResources

    public var title: String {
        switch self {
        case .movies: return "Ratings IMDb"
        case .rickAndMorty: return "Rick and Morty"
        case .southPark: return "South Park"
        case .bigMouth: return "Big Mouth"
        case .humanResources: return "Human Resources"
        }
    }

    public var description: String {
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

    public var isAPIMode: Bool {
        self != .movies
    }
}

// MARK: - App Theme
public enum AppTheme: String, CaseIterable, Sendable {
    case light
    case dark
    case system

    public var title: String {
        switch self {
        case .light:  return "Светлая"
        case .dark:   return "Тёмная"
        case .system: return "Системная"
        }
    }
}

public struct QuizVM {
    public let image: UIImage
    public let question: String
    public let questionIndicator: String
    public let correctAnswer: Bool
}

public struct QuizResultsVM {
    public let title: String
    public let text: String
    public let buttonText: String
}

// MARK: - Questions (Local)
public struct StaticQuizQuestion: Sendable {
    public let image: String
    public let question: String
    public let correctAnswer: Bool
}

public let localMovieQuestions: [StaticQuizQuestion] = [
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
public struct DynamicQuizQuestion: Sendable {
    public let imageURL: String
    public let questionText: String
    /// Если `true` — правильный ответ "Да", иначе "Нет".
    public let correctAnswer: Bool
    /// Настоящее имя персонажа (для показа после ответа).
    public let correctName: String
}

// MARK: - Rick and Morty API Models
public struct RMAPIResponse: Codable {
    public let info: RMAPIInfo
    public let results: [RMCharacter]
}

public struct RMAPIInfo: Codable {
    public let pages: Int
}

public struct RMCharacter: Codable, IdentifiableEntity, Sendable {
    public let id: Int
    public let name: String
    public let status: String
    public let species: String
    public let origin: RMLocationReference
    public let image: String
}

public struct RMLocationReference: Codable, Sendable {
    public let name: String
}

// MARK: - South Park API Models
public struct SPAPIResponse: Codable {
    public let data: [SPCharacter]
}

public struct SPCharacter: Codable, IdentifiableEntity, Sendable {
    public let id: Int
    public let name: String
    public let sex: String?
    public let religion: String?
}

// MARK: - Big Mouth / Human Resources API Models (Fandom)
public struct BMCharacter: IdentifiableEntity, Sendable {
    public let pageid: Int
    public let name: String
    public var id: Int { pageid }
}

public protocol QuizCharacter: IdentifiableEntity, Sendable {
    var characterName: String { get }
    var imageResource: String { get }
}

extension RMCharacter: QuizCharacter {
    public var characterName: String { name }
    public var imageResource: String { image }
}

extension SPCharacter: QuizCharacter {
    public var characterName: String { name }
    public var imageResource: String { "spwiki:\(name)" }
}

extension BMCharacter: QuizCharacter {
    public var characterName: String { name }
    public var imageResource: String { "bmwiki:\(name)" }
}

public struct FandomCategoryResponse: Codable {
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

public protocol QuizLogicProviding {
    func inject(rm characters: [RMCharacter])
    func inject(sp characters: [SPCharacter])
    func inject(bm characters: [BMCharacter])
    func inject(hr characters: [BMCharacter])
    func generateChallenge() -> DynamicQuizQuestion?
}

public final class QuizLogicEngine: QuizLogicProviding {
    private var rmCharacters: [RMCharacter] = []
    private var spCharacters: [SPCharacter] = []
    private var bmCharacters: [BMCharacter] = []
    private var activeMode: GameMode = .rickAndMorty
    private var usedQuestionNames: Set<String> = []
    private var usedRMCharacterIDs: Set<Int> = []
    private var usedSPCharacterIDs: Set<Int> = []
    private var usedBMCharacterIDs: Set<Int> = []

    public init() {}

    public func inject(rm characters: [RMCharacter]) {
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

    public func inject(sp characters: [SPCharacter]) {
        spCharacters = characters
        activeMode = .southPark
        usedQuestionNames.removeAll()
        usedSPCharacterIDs.removeAll()
    }

    public func inject(bm characters: [BMCharacter]) {
        bmCharacters = characters
        activeMode = .bigMouth
        usedQuestionNames.removeAll()
        usedBMCharacterIDs.removeAll()
    }

    public func inject(hr characters: [BMCharacter]) {
        bmCharacters = characters
        activeMode = .humanResources
        usedQuestionNames.removeAll()
        usedBMCharacterIDs.removeAll()
    }

    public func generateChallenge() -> DynamicQuizQuestion? {
        switch activeMode {
        case .rickAndMorty:
            return generateChallenge(from: rmCharacters, usedIDs: &usedRMCharacterIDs)
        case .southPark:
            return generateChallenge(from: spCharacters, usedIDs: &usedSPCharacterIDs)
        case .bigMouth, .humanResources:
            return generateChallenge(from: bmCharacters, usedIDs: &usedBMCharacterIDs)
        case .movies:
            return nil
        }
    }

    private func generateChallenge<T: QuizCharacter>(
        from characters: [T],
        usedIDs: inout Set<T.ID>
    ) -> DynamicQuizQuestion? {
        let availableSubjects = characters.filter { !usedIDs.contains($0.id) }
        guard availableSubjects.count > 1 else { return nil }

        let allNames = Set(availableSubjects.map(\.characterName))
        let remainingNames = allNames.subtracting(usedQuestionNames)
        guard !remainingNames.isEmpty else { return nil }

        guard let subject = availableSubjects.randomElement() else { return nil }

        let correctNameAvailable = !usedQuestionNames.contains(subject.characterName)
        let wrongPool = allNames.subtracting([subject.characterName]).subtracting(usedQuestionNames)
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
            candidateName = subject.characterName
        } else {
            guard let wrong = wrongPool.randomElement() else { return nil }
            candidateName = wrong
        }

        usedQuestionNames.insert(candidateName)
        usedIDs.insert(subject.id)

        return DynamicQuizQuestion(
            imageURL: subject.imageResource,
            questionText: candidateName.uppercased(),
            correctAnswer: candidateName == subject.characterName,
            correctName: subject.characterName
        )
    }
}

