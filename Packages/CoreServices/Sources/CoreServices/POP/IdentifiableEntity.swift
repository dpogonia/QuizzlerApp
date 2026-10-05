//
//  IdentifiableEntity.swift
//  CoreServices
//
//  Created by Dmitrii Pogonia on 24.02.2026.
//

import Foundation

// У персонажа есть id. Коллекция умеет first(id:) / contains(id:) без копипасты по RM/SP/BM.
public protocol IdentifiableEntity {
    associatedtype ID: Hashable // Int у RM/SP, у BM это pageid
    var id: ID { get }
}

public extension Collection where Element: IdentifiableEntity {
    func first(id: Element.ID) -> Element? { // найти персонажа по id в массиве
        first { $0.id == id }
    }

    func contains(id: Element.ID) -> Bool {
        contains { $0.id == id }
    }
}
