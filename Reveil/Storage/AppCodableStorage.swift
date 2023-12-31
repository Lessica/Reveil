import SwiftUI

@MainActor
@propertyWrapper
struct AppCodableStorage<Value: PropertyListRepresentable>: DynamicProperty {
    private let triggerUpdate: ObservedObject<DefaultsWriter<Value>>
    private let writer: DefaultsWriter<Value>

    init(wrappedValue: Value, _ key: EntryKey, store: UserDefaults? = nil) {
        writer = DefaultsWriter<Value>.shared(defaultValue: wrappedValue, key: key.rawValue, defaults: store ?? .standard)
        triggerUpdate = .init(wrappedValue: writer)
    }

    var wrappedValue: Value {
        get { writer.state }
        nonmutating set { writer.state = newValue }
    }

    var projectedValue: Binding<Value> {
        Binding(
            get: { writer.state },
            set: { writer.state = $0 }
        )
    }
}
