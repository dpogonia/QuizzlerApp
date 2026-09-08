import Foundation

public final class UserDefaultsStorage: KeyValueStoring, @unchecked Sendable {
    private let defaults: UserDefaults
    private let lock = NSLock()

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func set(_ value: Int, forKey key: String) {
        lock.lock()
        defer { lock.unlock() }
        defaults.set(value, forKey: key)
    }

    public func integer(forKey key: String) -> Int {
        lock.lock()
        defer { lock.unlock() }
        return defaults.integer(forKey: key)
    }

    public func set(_ value: String?, forKey key: String) {
        lock.lock()
        defer { lock.unlock() }
        defaults.set(value, forKey: key)
    }

    public func string(forKey key: String) -> String? {
        lock.lock()
        defer { lock.unlock() }
        return defaults.string(forKey: key)
    }

    public func set(_ data: Data, forKey key: String) {
        lock.lock()
        defer { lock.unlock() }
        defaults.set(data, forKey: key)
    }

    public func data(forKey key: String) -> Data? {
        lock.lock()
        defer { lock.unlock() }
        return defaults.data(forKey: key)
    }
}
