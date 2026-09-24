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
public enum GameMode: String, CaseIterable, Codable, Sendable {
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

public enum AppLanguage: String, CaseIterable, Sendable {
    case russian = "ru"
    case english = "en"

    public var locale: Locale {
        Locale(identifier: rawValue)
    }

    public static var systemDefault: AppLanguage {
        if Locale.current.language.languageCode?.identifier == "ru" {
            return .russian
        }
        return .english
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
public struct StaticQuizQuestion: Codable, Sendable {
    public let image: String
    public let imdbRating: Double
}

public struct MovieRatingPrompt: Codable, Sendable {
    public let image: String
    public let threshold: Int
    public let asksIfHigher: Bool
    public let correctAnswer: Bool
}

extension StaticQuizQuestion {
    public func makeRatingPrompt() -> MovieRatingPrompt {
        let lowerThreshold: Int
        let upperThreshold: Int
        if abs(imdbRating - imdbRating.rounded()) < 0.05 {
            let exact = Int(imdbRating.rounded())
            lowerThreshold = exact - 1
            upperThreshold = exact + 1
        } else {
            lowerThreshold = Int(imdbRating.rounded(.down))
            upperThreshold = Int(imdbRating.rounded(.up))
        }

        var thresholds = [lowerThreshold, upperThreshold].filter { (1...9).contains($0) }
        if thresholds.isEmpty {
            thresholds = [min(9, max(1, Int(imdbRating.rounded())))]
        }
        let threshold = thresholds.randomElement() ?? 9
        let asksIfHigher = Bool.random()
        let correctAnswer = asksIfHigher
            ? imdbRating > Double(threshold)
            : imdbRating < Double(threshold)
        return MovieRatingPrompt(
            image: image,
            threshold: threshold,
            asksIfHigher: asksIfHigher,
            correctAnswer: correctAnswer
        )
    }
}

public let localMovieQuestions: [StaticQuizQuestion] = [
    StaticQuizQuestion(image: "The Godfather", imdbRating: 9.2),
    StaticQuizQuestion(image: "The Dark Knight", imdbRating: 9.0),
    StaticQuizQuestion(image: "Kill Bill", imdbRating: 8.2),
    StaticQuizQuestion(image: "The Avengers", imdbRating: 8.0),
    StaticQuizQuestion(image: "Deadpool", imdbRating: 8.0),
    StaticQuizQuestion(image: "The Green Knight", imdbRating: 6.6),
    StaticQuizQuestion(image: "Old", imdbRating: 5.8),
    StaticQuizQuestion(image: "The Ice Age Adventures of Buck Wild", imdbRating: 4.6),
    StaticQuizQuestion(image: "Tesla", imdbRating: 5.1),
    StaticQuizQuestion(image: "Vivarium", imdbRating: 5.8),
    StaticQuizQuestion(image: "The Shawshank Redemption", imdbRating: 9.3),
    StaticQuizQuestion(image: "Pulp Fiction", imdbRating: 8.8),
    StaticQuizQuestion(image: "Inception", imdbRating: 8.8),
    StaticQuizQuestion(image: "Interstellar", imdbRating: 8.7),
    StaticQuizQuestion(image: "Parasite", imdbRating: 8.5),
    StaticQuizQuestion(image: "Dune", imdbRating: 8.0),
    StaticQuizQuestion(image: "Get Out", imdbRating: 7.8),
    StaticQuizQuestion(image: "Barbie", imdbRating: 6.8),
    StaticQuizQuestion(image: "Morbius", imdbRating: 5.1),
    StaticQuizQuestion(image: "Cats", imdbRating: 2.8),
    StaticQuizQuestion(image: "The Godfather Part II", imdbRating: 9.0),
    StaticQuizQuestion(image: "12 Angry Men", imdbRating: 9.0),
    StaticQuizQuestion(image: "Schindlers List", imdbRating: 9.0),
    StaticQuizQuestion(image: "Return of the King", imdbRating: 9.0),
    StaticQuizQuestion(image: "Fight Club", imdbRating: 8.8),
    StaticQuizQuestion(image: "Forrest Gump", imdbRating: 8.8),
    StaticQuizQuestion(image: "The Matrix", imdbRating: 8.7),
    StaticQuizQuestion(image: "Goodfellas", imdbRating: 8.7),
    StaticQuizQuestion(image: "The Silence of the Lambs", imdbRating: 8.6),
    StaticQuizQuestion(image: "Se7en", imdbRating: 8.6),
    StaticQuizQuestion(image: "Spirited Away", imdbRating: 8.6),
    StaticQuizQuestion(image: "Gladiator", imdbRating: 8.5),
    StaticQuizQuestion(image: "Whiplash", imdbRating: 8.5),
    StaticQuizQuestion(image: "The Prestige", imdbRating: 8.5),
    StaticQuizQuestion(image: "Django Unchained", imdbRating: 8.5),
    StaticQuizQuestion(image: "The Lion King", imdbRating: 8.5),
    StaticQuizQuestion(image: "Across the Spider-Verse", imdbRating: 8.5),
    StaticQuizQuestion(image: "Coco", imdbRating: 8.4),
    StaticQuizQuestion(image: "Joker", imdbRating: 8.3),
    StaticQuizQuestion(image: "Oppenheimer", imdbRating: 8.2),
    StaticQuizQuestion(image: "Top Gun Maverick", imdbRating: 8.2),
    StaticQuizQuestion(image: "The Grand Budapest Hotel", imdbRating: 8.1),
    StaticQuizQuestion(image: "Mad Max Fury Road", imdbRating: 8.1),
    StaticQuizQuestion(image: "Titanic", imdbRating: 8.0),
    StaticQuizQuestion(image: "La La Land", imdbRating: 8.0),
    StaticQuizQuestion(image: "Blade Runner 2049", imdbRating: 8.0),
    StaticQuizQuestion(image: "Her", imdbRating: 8.0),
    StaticQuizQuestion(image: "Avatar", imdbRating: 7.9),
    StaticQuizQuestion(image: "Knives Out", imdbRating: 7.9),
    StaticQuizQuestion(image: "Arrival", imdbRating: 7.9),
    StaticQuizQuestion(image: "Jojo Rabbit", imdbRating: 7.9),
    StaticQuizQuestion(image: "The Social Network", imdbRating: 7.8),
    StaticQuizQuestion(image: "The Batman", imdbRating: 7.8),
    StaticQuizQuestion(image: "Everything Everywhere All at Once", imdbRating: 7.7),
    StaticQuizQuestion(image: "John Wick", imdbRating: 7.5),
    StaticQuizQuestion(image: "The Flash", imdbRating: 6.6),
    StaticQuizQuestion(image: "Batman v Superman", imdbRating: 6.4),
    StaticQuizQuestion(image: "Suicide Squad", imdbRating: 5.9),
    StaticQuizQuestion(image: "Twilight", imdbRating: 5.4),
    StaticQuizQuestion(image: "Jupiter Ascending", imdbRating: 5.3),
    StaticQuizQuestion(image: "Transformers The Last Knight", imdbRating: 5.2),
    StaticQuizQuestion(image: "Joker Folie a Deux", imdbRating: 5.2),
    StaticQuizQuestion(image: "The Happening", imdbRating: 5.0),
    StaticQuizQuestion(image: "After Earth", imdbRating: 4.8),
    StaticQuizQuestion(image: "Borderlands", imdbRating: 4.7),
    StaticQuizQuestion(image: "Fantastic Four", imdbRating: 4.3),
    StaticQuizQuestion(image: "Fifty Shades of Grey", imdbRating: 4.2),
    StaticQuizQuestion(image: "Madame Web", imdbRating: 4.1),
    StaticQuizQuestion(image: "The Last Airbender", imdbRating: 3.9),
    StaticQuizQuestion(image: "The Emoji Movie", imdbRating: 3.5),
    StaticQuizQuestion(image: "Saving Private Ryan", imdbRating: 8.6),
    StaticQuizQuestion(image: "The Departed", imdbRating: 8.5),
    StaticQuizQuestion(image: "Terminator 2", imdbRating: 8.6),
    StaticQuizQuestion(image: "Alien", imdbRating: 8.5),
    StaticQuizQuestion(image: "Back to the Future", imdbRating: 8.5),
    StaticQuizQuestion(image: "Raiders of the Lost Ark", imdbRating: 8.4),
    StaticQuizQuestion(image: "Toy Story", imdbRating: 8.3),
    StaticQuizQuestion(image: "WALL-E", imdbRating: 8.4),
    StaticQuizQuestion(image: "The Usual Suspects", imdbRating: 8.5),
    StaticQuizQuestion(image: "City of God", imdbRating: 8.6),
    StaticQuizQuestion(image: "Amelie", imdbRating: 8.3),
    StaticQuizQuestion(image: "No Country for Old Men", imdbRating: 8.2),
    StaticQuizQuestion(image: "Casablanca", imdbRating: 8.5),
    StaticQuizQuestion(image: "Guardians of the Galaxy", imdbRating: 8.0),
    StaticQuizQuestion(image: "Iron Man", imdbRating: 7.9),
    StaticQuizQuestion(image: "Logan", imdbRating: 8.1),
    StaticQuizQuestion(image: "The Wolf of Wall Street", imdbRating: 8.2),
    StaticQuizQuestion(image: "The Big Lebowski", imdbRating: 8.1),
    StaticQuizQuestion(image: "Jurassic Park", imdbRating: 8.2),
    StaticQuizQuestion(image: "Die Hard", imdbRating: 8.2),
    StaticQuizQuestion(image: "Shrek", imdbRating: 7.9),
    StaticQuizQuestion(image: "Finding Nemo", imdbRating: 8.2),
    StaticQuizQuestion(image: "Up", imdbRating: 8.3),
    StaticQuizQuestion(image: "Inside Out", imdbRating: 8.1),
    StaticQuizQuestion(image: "Catwoman", imdbRating: 3.4),
    StaticQuizQuestion(image: "Batman and Robin", imdbRating: 3.8),
    StaticQuizQuestion(image: "Battlefield Earth", imdbRating: 2.5),
    StaticQuizQuestion(image: "Movie 43", imdbRating: 4.4),
    StaticQuizQuestion(image: "Jack and Jill", imdbRating: 3.3),
    StaticQuizQuestion(image: "Disaster Movie", imdbRating: 1.9)
]

public let movieRoundQuestionCount = 20

public func makeMovieRound(count: Int = movieRoundQuestionCount) -> [StaticQuizQuestion] {
    Array(localMovieQuestions.shuffled().prefix(min(count, localMovieQuestions.count)))
}

public func movieQuestion(named image: String) -> StaticQuizQuestion? {
    localMovieQuestions.first { $0.image == image }
}

// MARK: - Dynamic questions (API-based)
public struct DynamicQuizQuestion: Codable, Sendable {
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
public struct BMCharacter: Codable, IdentifiableEntity, Sendable {
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
    func exportProgress() -> QuizEngineProgress
    func restoreProgress(_ progress: QuizEngineProgress)
}

public struct QuizEngineProgress: Codable, Sendable {
    public var usedQuestionNames: [String]
    public var usedCharacterIDs: [Int]
    public var rmCharacters: [RMCharacter]
    public var spCharacters: [SPCharacter]
    public var bmCharacters: [BMCharacter]
    public var mode: GameMode

    public init(
        usedQuestionNames: [String],
        usedCharacterIDs: [Int],
        rmCharacters: [RMCharacter],
        spCharacters: [SPCharacter],
        bmCharacters: [BMCharacter],
        mode: GameMode
    ) {
        self.usedQuestionNames = usedQuestionNames
        self.usedCharacterIDs = usedCharacterIDs
        self.rmCharacters = rmCharacters
        self.spCharacters = spCharacters
        self.bmCharacters = bmCharacters
        self.mode = mode
    }
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

    public func exportProgress() -> QuizEngineProgress {
        QuizEngineProgress(
            usedQuestionNames: Array(usedQuestionNames),
            usedCharacterIDs: usedIDs(for: activeMode),
            rmCharacters: rmCharacters,
            spCharacters: spCharacters,
            bmCharacters: bmCharacters,
            mode: activeMode
        )
    }

    public func restoreProgress(_ progress: QuizEngineProgress) {
        rmCharacters = progress.rmCharacters
        spCharacters = progress.spCharacters
        bmCharacters = progress.bmCharacters
        activeMode = progress.mode
        usedQuestionNames = Set(progress.usedQuestionNames)
        let ids = Set(progress.usedCharacterIDs)
        usedRMCharacterIDs = []
        usedSPCharacterIDs = []
        usedBMCharacterIDs = []
        switch progress.mode {
        case .rickAndMorty:
            usedRMCharacterIDs = ids
        case .southPark:
            usedSPCharacterIDs = ids
        case .bigMouth, .humanResources:
            usedBMCharacterIDs = ids
        case .movies:
            break
        }
    }

    private func usedIDs(for mode: GameMode) -> [Int] {
        switch mode {
        case .rickAndMorty:
            return Array(usedRMCharacterIDs)
        case .southPark:
            return Array(usedSPCharacterIDs)
        case .bigMouth, .humanResources:
            return Array(usedBMCharacterIDs)
        case .movies:
            return []
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

