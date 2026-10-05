//
//  DynamicQuizService.swift
//  QuizServices
//
//  Created by Dmitrii Pogonia on 22.03.2026.
//

import Foundation
import UIKit

public protocol DynamicQuizServing { // вопрос раунда: персонаж из движка + скачанная картинка
    func prefetchCharactersIfNeeded(for mode: GameMode, into engine: QuizLogicProviding) async throws
    func makeDynamicQuestion(using engine: QuizLogicProviding) async -> (DynamicQuizQuestion, UIImage)?
}

public final class DynamicQuizService: DynamicQuizServing {
    private let network: any QuizNetworking
    private let preloader: any QuizPreloading

    public init(
        network: any QuizNetworking,
        preloader: any QuizPreloading
    ) {
        self.network = network
        self.preloader = preloader
    }

    public func prefetchCharactersIfNeeded(for mode: GameMode, into engine: QuizLogicProviding) async throws { // свежая страница API, если нет — то что предзагрузчик уже держит
        switch mode {
        case .rickAndMorty:
            do {
                let targetPage = Int.random(in: 1...42)
                let characters = try await network.fetchRMCharacters(page: targetPage)
                engine.inject(rm: characters)
            } catch {
                engine.inject(rm: try await preloader.rmCharacters()) // офлайн / ошибка страницы — колода со сплэша
            }
        case .southPark:
            do {
                let targetPage = Int.random(in: 1...10)
                let characters = try await network.fetchSPCharacters(page: targetPage)
                engine.inject(sp: characters)
            } catch {
                engine.inject(sp: try await preloader.spCharacters())
            }
        case .bigMouth:
            let characters = try await preloader.bmCharacters()
            engine.inject(bm: characters)
        case .humanResources:
            let characters = try await preloader.bmCharacters()
            engine.inject(hr: characters) // тот же список Fandom, движок ставит режим HR
        }
    }

    public func makeDynamicQuestion(using engine: QuizLogicProviding) async -> (DynamicQuizQuestion, UIImage)? {
        var dynamicQuestion: DynamicQuizQuestion?
        var loadedImage: UIImage?

        for _ in 0..<12 { // до 12 попыток: движок дал имя, картинка не скачалась — берём другого
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
