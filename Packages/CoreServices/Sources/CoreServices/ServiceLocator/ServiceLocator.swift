//
//  ServiceLocator.swift
//  CoreServices
//
//  Created by Dmitrii Pogonia on 26.02.2026.
//

import Foundation

public final class ServiceLocator: @unchecked Sendable {
    public static let shared = ServiceLocator()

    private var factories: [ObjectIdentifier: () -> Any] = [:]
    private let lock = NSLock()

    public init() {}

    public func register<Service>(_ type: Service.Type = Service.self, instance: Service) {
        register(type) { instance }
    }

    public func register<Service>(_ type: Service.Type = Service.self, factory: @escaping () -> Service) {
        lock.lock()
        defer { lock.unlock() }
        factories[ObjectIdentifier(type)] = factory
    }

    public func resolve<Service>(_ type: Service.Type = Service.self) -> Service {
        lock.lock()
        let factory = factories[ObjectIdentifier(type)]
        lock.unlock()

        guard let factory, let service = factory() as? Service else {
            fatalError("Service \(type) is not registered in ServiceLocator")
        }
        return service
    }
}
