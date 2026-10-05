//
//  Models.swift
//  QuizServices
//
//  Created by Dmitrii Pogonia on 05.03.2026.
//

import CoreServices
import Foundation
import UIKit

public enum GameMode: String, CaseIterable, Codable, Sendable {
    case rickAndMorty
    case southPark
    case bigMouth
    case humanResources

    public var title: String {
        switch self {
        case .rickAndMorty: return "Rick and Morty"
        case .southPark: return "South Park"
        case .bigMouth: return "Big Mouth"
        case .humanResources: return "Human Resources"
        }
    }

    public var description: String {
        switch self {
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
}

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

public struct DynamicQuizQuestion: Codable, Sendable {
    public let imageURL: String
    public let questionText: String

    public let correctAnswer: Bool

    public let correctName: String
}

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

public struct SPAPIResponse: Codable {
    public let data: [SPCharacter]
}

public struct SPCharacter: Codable, IdentifiableEntity, Sendable {
    public let id: Int
    public let name: String
    public let sex: String?
    public let religion: String?
}

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



        let groupedByImage = Dictionary(grouping: characters, by: { $0.image })
        let filtered = groupedByImage.flatMap { (key: String, value: [RMCharacter]) -> [RMCharacter] in

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

