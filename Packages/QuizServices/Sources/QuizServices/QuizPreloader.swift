import Foundation

public protocol QuizPreloading: AnyObject, Sendable {
    func startIfNeeded() async
    func latestError() async -> Error?
    func retryFailedLoads() async
    func rmCharacters() async throws -> [RMCharacter]
    func spCharacters() async throws -> [SPCharacter]
    func bmCharacters() async throws -> [BMCharacter]
}

public actor QuizPreloader: QuizPreloading {
    private enum Limits {
        static let pageConcurrency = 4
        static let imageConcurrency = 8
    }

    private let network: any QuizNetworking
    private let bankCache: any QuizBankCaching

    private var rmTask: Task<[RMCharacter], Error>?
    private var spTask: Task<[SPCharacter], Error>?
    private var bmTask: Task<[BMCharacter], Error>?
    private var rmFailed = false
    private var spFailed = false
    private var bmFailed = false
    private var storedError: Error?

    public init(network: any QuizNetworking, bankCache: any QuizBankCaching) {
        self.network = network
        self.bankCache = bankCache
    }

    public func latestError() -> Error? {
        storedError
    }

    public func retryFailedLoads() {
        if rmFailed {
            rmTask = nil
            rmFailed = false
        }
        if spFailed {
            spTask = nil
            spFailed = false
        }
        if bmFailed {
            bmTask = nil
            bmFailed = false
        }
        storedError = nil
        startIfNeeded()
    }

    public func startIfNeeded() {
        if rmTask == nil {
            rmTask = Task {
                do {
                    return try await self.loadRMCharactersForGame()
                } catch {
                    await self.rememberFailure(error, bank: .rm)
                    throw error
                }
            }
        }
        if spTask == nil {
            spTask = Task {
                do {
                    return try await self.loadSPCharactersForGame()
                } catch {
                    await self.rememberFailure(error, bank: .sp)
                    throw error
                }
            }
        }
        if bmTask == nil {
            bmTask = Task {
                do {
                    return try await self.loadBMCharactersForGame()
                } catch {
                    await self.rememberFailure(error, bank: .bm)
                    throw error
                }
            }
        }
    }

    public func rmCharacters() async throws -> [RMCharacter] {
        if let task = rmTask {
            return try await task.value
        }
        let task = Task {
            try await self.loadRMCharactersForGame()
        }
        rmTask = task
        return try await task.value
    }

    public func spCharacters() async throws -> [SPCharacter] {
        if let task = spTask {
            return try await task.value
        }
        let task = Task {
            try await self.loadSPCharactersForGame()
        }
        spTask = task
        return try await task.value
    }

    public func bmCharacters() async throws -> [BMCharacter] {
        if let task = bmTask {
            return try await task.value
        }
        let task = Task {
            try await self.loadBMCharactersForGame()
        }
        bmTask = task
        return try await task.value
    }

    private enum Bank {
        case rm
        case sp
        case bm
    }

    private func rememberFailure(_ error: Error, bank: Bank) {
        storedError = error
        switch bank {
        case .rm: rmFailed = true
        case .sp: spFailed = true
        case .bm: bmFailed = true
        }
    }

    private func loadRMCharactersForGame() async throws -> [RMCharacter] {
        do {
            let characters = try await fetchRMCharactersFromNetwork()
            await bankCache.saveRM(characters)
            return characters
        } catch {
            if let cached = await bankCache.loadRM(), !cached.isEmpty {
                return cached
            }
            throw error
        }
    }

    private func fetchRMCharactersFromNetwork() async throws -> [RMCharacter] {
        let network = self.network
        let allRMCharacters = try await fetchPages(Array(1...42)) { page in
            try await network.fetchRMCharacters(page: page)
        }
        guard !allRMCharacters.isEmpty else { throw URLError(.badServerResponse) }

        let candidateRM = Array(allRMCharacters.shuffled().prefix(80))
        let readyRM = await filterReady(candidateRM) { character in
            character.image
        }
        return readyRM.count >= 20 ? readyRM : allRMCharacters
    }

    private func loadSPCharactersForGame() async throws -> [SPCharacter] {
        do {
            let characters = try await fetchSPCharactersFromNetwork()
            await bankCache.saveSP(characters)
            return characters
        } catch {
            if let cached = await bankCache.loadSP(), !cached.isEmpty {
                return cached
            }
            throw error
        }
    }

    private func fetchSPCharactersFromNetwork() async throws -> [SPCharacter] {
        let network = self.network
        let allCharacters = try await fetchPages(Array(1...10)) { page in
            try await network.fetchSPCharacters(page: page)
        }
        guard !allCharacters.isEmpty else { throw URLError(.badServerResponse) }

        let candidateSP = Array(allCharacters.shuffled().prefix(80))
        let readySP = await filterReady(candidateSP) { character in
            "spwiki:\(character.name)"
        }
        return readySP.count >= 20 ? readySP : allCharacters
    }

    private func loadBMCharactersForGame() async throws -> [BMCharacter] {
        do {
            let characters = try await fetchBMCharactersFromNetwork()
            await bankCache.saveBM(characters)
            return characters
        } catch {
            if let cached = await bankCache.loadBM(), !cached.isEmpty {
                return cached
            }
            throw error
        }
    }

    private func fetchBMCharactersFromNetwork() async throws -> [BMCharacter] {
        let allCharacters = try await network.fetchBMCharacters()
        guard !allCharacters.isEmpty else { throw URLError(.badServerResponse) }

        let candidate = Array(allCharacters.shuffled().prefix(200))
        return await filterReady(candidate) { character in
            "bmwiki:\(character.name)"
        }
    }

    private func fetchPages<Character: Sendable>(
        _ pages: [Int],
        maxConcurrent: Int = Limits.pageConcurrency,
        fetch: @escaping @Sendable (Int) async throws -> [Character]
    ) async throws -> [Character] {
        try await withThrowingTaskGroup(of: [Character].self) { group in
            var iterator = pages.makeIterator()
            var allCharacters: [Character] = []

            func enqueueNext() {
                guard let page = iterator.next() else { return }
                group.addTask {
                    try await fetch(page)
                }
            }

            for _ in 0..<min(maxConcurrent, pages.count) {
                enqueueNext()
            }

            while let pageCharacters = try await group.next() {
                allCharacters.append(contentsOf: pageCharacters)
                enqueueNext()
            }

            return allCharacters
        }
    }

    private func filterReady<Character: Sendable>(
        _ characters: [Character],
        maxConcurrent: Int = Limits.imageConcurrency,
        imageResource: @escaping @Sendable (Character) -> String
    ) async -> [Character] {
        let network = self.network
        return await withTaskGroup(of: Character?.self) { group in
            var iterator = characters.makeIterator()
            var ready: [Character] = []

            func enqueueNext() {
                guard let character = iterator.next() else { return }
                group.addTask {
                    if let _ = try? await network.fetchImage(from: imageResource(character)) {
                        return character
                    }
                    return nil
                }
            }

            for _ in 0..<min(maxConcurrent, characters.count) {
                enqueueNext()
            }

            while let result = await group.next() {
                if let character = result {
                    ready.append(character)
                }
                enqueueNext()
            }

            return ready
        }
    }
}
