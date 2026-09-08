import CoreServices
import Foundation
import UIKit

public protocol QuizPreloading: AnyObject {
    func startIfNeeded()
    func rmCharacters() async throws -> [RMCharacter]
    func spCharacters() async throws -> [SPCharacter]
    func bmCharacters() async throws -> [BMCharacter]
}

public final class QuizPreloader: QuizPreloading, @unchecked Sendable {
    private let network: any QuizNetworking

    private var rmTask: Task<[RMCharacter], Error>?
    private var spTask: Task<[SPCharacter], Error>?
    private var bmTask: Task<[BMCharacter], Error>?

    public init(network: any QuizNetworking = ServiceLocator.shared.resolve()) {
        self.network = network
    }

    public func startIfNeeded() {
        if rmTask == nil {
            rmTask = Task { [network] in
                try await Self.loadRMCharactersForGame(network: network)
            }
        }
        if spTask == nil {
            spTask = Task { [network] in
                try await Self.loadSPCharactersForGame(network: network)
            }
        }
        if bmTask == nil {
            bmTask = Task { [network] in
                try await Self.loadBMCharactersForGame(network: network)
            }
        }
    }

    public func rmCharacters() async throws -> [RMCharacter] {
        if let task = rmTask {
            return try await task.value
        }
        let task = Task { [network] in
            try await Self.loadRMCharactersForGame(network: network)
        }
        rmTask = task
        return try await task.value
    }

    public func spCharacters() async throws -> [SPCharacter] {
        if let task = spTask {
            return try await task.value
        }
        let task = Task { [network] in
            try await Self.loadSPCharactersForGame(network: network)
        }
        spTask = task
        return try await task.value
    }

    public func bmCharacters() async throws -> [BMCharacter] {
        if let task = bmTask {
            return try await task.value
        }
        let task = Task { [network] in
            try await Self.loadBMCharactersForGame(network: network)
        }
        bmTask = task
        return try await task.value
    }

    private static func loadRMCharactersForGame(network: any QuizNetworking) async throws -> [RMCharacter] {
        let rmPages = Array(1...42)
        var allRMCharacters: [RMCharacter] = []
        try await withThrowingTaskGroup(of: [RMCharacter].self) { group in
            for page in rmPages {
                group.addTask {
                    try await network.fetchRMCharacters(page: page)
                }
            }
            for try await chars in group {
                allRMCharacters.append(contentsOf: chars)
            }
        }
        guard !allRMCharacters.isEmpty else { throw URLError(.badServerResponse) }

        let shuffledRM = allRMCharacters.shuffled()
        let candidateRM = Array(shuffledRM.prefix(80))
        var readyRM: [RMCharacter] = []
        await withTaskGroup(of: RMCharacter?.self) { group in
            for character in candidateRM {
                group.addTask {
                    if let _ = try? await network.fetchImage(from: character.image) {
                        return character
                    }
                    return nil
                }
            }
            for await result in group {
                if let character = result {
                    readyRM.append(character)
                }
            }
        }
        return readyRM.count >= 20 ? readyRM : allRMCharacters
    }

    private static func loadSPCharactersForGame(network: any QuizNetworking) async throws -> [SPCharacter] {
        let pages = Array(1...10)
        var allCharacters: [SPCharacter] = []
        try await withThrowingTaskGroup(of: [SPCharacter].self) { group in
            for page in pages {
                group.addTask {
                    try await network.fetchSPCharacters(page: page)
                }
            }
            for try await chars in group {
                allCharacters.append(contentsOf: chars)
            }
        }
        guard !allCharacters.isEmpty else { throw URLError(.badServerResponse) }

        let shuffledSP = allCharacters.shuffled()
        let candidateSP = Array(shuffledSP.prefix(80))
        var readySP: [SPCharacter] = []
        await withTaskGroup(of: SPCharacter?.self) { group in
            for character in candidateSP {
                group.addTask {
                    let urlString = "spwiki:\(character.name)"
                    if let _ = try? await network.fetchImage(from: urlString) {
                        return character
                    }
                    return nil
                }
            }
            for await result in group {
                if let character = result {
                    readySP.append(character)
                }
            }
        }
        return readySP.count >= 20 ? readySP : allCharacters
    }

    private static func loadBMCharactersForGame(network: any QuizNetworking) async throws -> [BMCharacter] {
        let allCharacters = try await network.fetchBMCharacters()
        guard !allCharacters.isEmpty else { throw URLError(.badServerResponse) }

        let shuffled = allCharacters.shuffled()
        let candidate = Array(shuffled.prefix(200))
        var ready: [BMCharacter] = []
        await withTaskGroup(of: BMCharacter?.self) { group in
            for character in candidate {
                group.addTask {
                    let urlString = "bmwiki:\(character.name)"
                    if let _ = try? await network.fetchImage(from: urlString) {
                        return character
                    }
                    return nil
                }
            }
            for await result in group {
                if let character = result {
                    ready.append(character)
                }
            }
        }
        return ready
    }
}
