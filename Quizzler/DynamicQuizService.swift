import CoreServices
import Foundation
import UIKit

protocol DynamicQuizServing {
    func prefetchCharactersIfNeeded(for mode: GameMode, into engine: QuizLogicProviding) async throws
    func makeDynamicQuestion(using engine: QuizLogicProviding) async -> (DynamicQuizQuestion, UIImage)?
}

/// Отвечает за API-часть динамических викторин,
/// чтобы ViewController не работал напрямую с сетью.
final class DynamicQuizService: DynamicQuizServing {
    private let network: any QuizNetworking
    private let preloader: any QuizPreloading

    init(
        network: any QuizNetworking = ServiceLocator.shared.resolve(),
        preloader: any QuizPreloading = ServiceLocator.shared.resolve()
    ) {
        self.network = network
        self.preloader = preloader
    }

    func prefetchCharactersIfNeeded(for mode: GameMode, into engine: QuizLogicProviding) async throws {
        switch mode {
        case .rickAndMorty:
            let targetPage = Int.random(in: 1...42)
            let characters = try await network.fetchRMCharacters(page: targetPage)
            engine.inject(rm: characters)
        case .southPark:
            let targetPage = Int.random(in: 1...10)
            let characters = try await network.fetchSPCharacters(page: targetPage)
            engine.inject(sp: characters)
        case .bigMouth:
            let characters = try await preloader.bmCharacters()
            engine.inject(bm: characters)
        case .humanResources:
            let characters = try await preloader.bmCharacters()
            engine.inject(hr: characters)
        case .movies:
            break
        }
    }

    func makeDynamicQuestion(using engine: QuizLogicProviding) async -> (DynamicQuizQuestion, UIImage)? {
        var dynamicQuestion: DynamicQuizQuestion?
        var loadedImage: UIImage?

        for _ in 0..<12 {
            guard let candidate = engine.generateChallenge() else { break }
            if let image = try? await network.fetchImage(from: candidate.imageURL) {
                dynamicQuestion = candidate
                loadedImage = image
                break
            }
        }

        guard let finalQuestion = dynamicQuestion, let image = loadedImage else {
            return nil
        }

        return (finalQuestion, image)
    }
}
