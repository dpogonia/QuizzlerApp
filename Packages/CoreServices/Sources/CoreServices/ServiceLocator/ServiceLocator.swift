//
//  ServiceLocator.swift
//  CoreServices
//
//  Created by Dmitrii Pogonia on 26.02.2026.
//

import Foundation

// Шкаф: тип протокола → готовый объект. AppAssembly.register, экраны берут через AppEnvironment (resolve).
public final class ServiceLocator: @unchecked Sendable {
    public static let shared = ServiceLocator() // один на процесс, bootstrap кладёт сюда сервисы

    private var factories: [ObjectIdentifier: () -> Any] = [:] // ключ — тип (NetworkServing.self), значение — «выдай объект»
    private let lock = NSLock() // register/resolve могут с разных мест, словарь не thread-safe сам

    public init() {}

    public func register<Service>(_ type: Service.Type = Service.self, instance: Service) { // «запомни: по этому протоколу выдавай вот этот объект»
        register(type) { instance } // замыкание всегда возвращает тот же экземпляр, не новую копию
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
            fatalError("Service \(type) is not registered in ServiceLocator") // забыли register в AppAssembly
        }
        return service
    }
}
