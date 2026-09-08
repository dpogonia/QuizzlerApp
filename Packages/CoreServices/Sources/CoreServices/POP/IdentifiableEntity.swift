import Foundation

/// POP + type constraints: расширения доступны только коллекциям с IdentifiableEntity.
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
