//
//  IdentifiableEntity.swift
//  CoreServices
//
//  Created by Dmitrii Pogonia on 24.02.2026.
//

import Foundation

public protocol IdentifiableEntity {
    associatedtype ID: Hashable
    var id: ID { get }
}

public extension Collection where Element: IdentifiableEntity {
    func first(id: Element.ID) -> Element? {
        first { $0.id == id }
    }

    func contains(id: Element.ID) -> Bool {
        contains { $0.id == id }
    }
}
