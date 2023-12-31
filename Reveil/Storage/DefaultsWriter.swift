import Combine
import Foundation

/// DefaultsWiriter syncs a Codable object tree to UserDefaults
/// - Writes any Codable object to user defaults **as an object tree**, not a String or coded Data.
/// - Observes any external changes to its UserDefaults key
/// After I wrote this, I realized it's pretty similar to [Mike Ash's "Type-Safe User Defaults"](https://github.com/mikeash/TSUD)
///
final class DefaultsWriter<Value: PropertyListRepresentable>: ObservableObject {
    public let key: String
    public let defaults: UserDefaults

    /// Var to get around issue with init and callback fn
    private var defaultsObserver: UserDefaults.UserDefaultsStringKeyObservation!
    private let defaultValue: Value
    private var pausedObservation: Bool = false

    /// Experimental API… I had some situations outside of SwiftUI where I need to get the value AFTER the change
    public let objectDidChange: AnyPublisher<Value, Never>
    private let _objectDidChange: PassthroughSubject<Value, Never>

    public var state: Value {
        willSet {
            objectWillChange.send()
        }
        didSet {
            if let encoded = try? state.propertyListValue {
                /// We don't want to observe the redundant notification that will come from UserDefaults
                pausedObservation = true
                defaults.set(encoded, forKey: key)
                pausedObservation = false
            }
            _objectDidChange.send(state)
        }
    }

    public init(defaultValue: Value, key: String, defaults: UserDefaults? = nil) {
        let defaults = defaults ?? .standard
        self.key = key
        state = Self.read(from: defaults, key: key) ?? defaultValue
        self.defaults = defaults
        self.defaultValue = defaultValue
        defaultsObserver = nil
        _objectDidChange = PassthroughSubject<Value, Never>()
        objectDidChange = _objectDidChange.eraseToAnyPublisher()

        /// When defaults change externally, update our value
        /// We cannot use the newer defaults.observe() because we have a keyPath String not a KeyPath<Defaults, Any>
        /// This means we don't force you to declare your keypath in a UserDefaults extension
        defaultsObserver = defaults.observe(key: key) { [weak self] newValue in
            guard let self, pausedObservation == false else { return }
            observeDefaultsUpdate(newValue)
        }
    }

    /// Take in a new object value from UserDefaults, updating our state
    func observeDefaultsUpdate(_ newValue: Any?) {
        if newValue is NSNull {
            state = defaultValue
        } else if let newValue {
            do {
                let newState = try Value(propertyList: newValue)
                state = newState
            } catch {
                print("DefaultsWriter could not deserialize update from UserDefaults observation. Not updating. \(error)")
            }
        } else {
            state = defaultValue
        }
    }

    static func read(from defaults: UserDefaults, key: String) -> Value? {
        if let o = defaults.object(forKey: key) {
            try? Value(propertyList: o)
        } else {
            nil
        }
    }
}

@MainActor
var sharedDefaultsWriters: [WhichDefaultsAndKey: Any] = [:]

struct WhichDefaultsAndKey: Hashable {
    let defaults: UserDefaults
    let key: String
}

extension DefaultsWriter {
    @MainActor
    public static func shared(defaultValue: PropertyListRepresentable, key: String, defaults: UserDefaults) -> Self {
        let kdPr = WhichDefaultsAndKey(defaults: defaults, key: key)
        if let existing = sharedDefaultsWriters[kdPr] {
            guard let typed = existing as? Self else {
                fatalError("Type \(Value.self) must remain consistent for key \(key). Existing: \(existing)")
            }
            return typed
        }
        let neue = Self(defaultValue: defaultValue as! Value, key: key, defaults: defaults)
        sharedDefaultsWriters[kdPr] = neue
        return neue
    }
}
