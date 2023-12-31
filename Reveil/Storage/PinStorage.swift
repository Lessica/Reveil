//
//  PinStorage.swift
//  Reveil
//
//  Created by Lessica on 2023/10/14.
//

import Foundation

private let plistDecoder = PropertyListDecoder()

final class PinStorage: ObservableObject {
    private static let suiteName = "\(Bundle.main.bundleIdentifier!).\(String(describing: PinStorage.self))"

    static let shared = PinStorage()

    private init() {
        pinnedEntryKeys = []
        reloadData()
        registerNotifications()
        try? registerDefaults()
    }

    lazy var userDefaults: UserDefaults? = UserDefaults(suiteName: PinStorage.suiteName)

    private var persistentDomain: [String: Any]? {
        userDefaults?.persistentDomain(forName: Self.suiteName)
    }

    @Published var pinnedEntryKeys: [EntryKey]

    func isPinned(forKey key: EntryKey) -> Bool {
        return pinnedEntryKeys.contains(key)
    }

    func reloadData() {
        guard let dictRepr = persistentDomain else {
            return
        }

        pinnedEntryKeys.removeAll(keepingCapacity: true)

        let entryKeys = dictRepr
            .compactMap { (key: String, value: Any) -> (String, Pin)? in
                guard let protectedValue = value as? [String: Any],
                      let pin = try? Pin(propertyList: protectedValue)
                else {
                    return nil
                }
                return (key, pin)
            }
            .filter(\.1.isPinned)
            .sorted(by: { $0.1.lastChange < $1.1.lastChange })
            .compactMap { EntryKey(rawValue: $0.0) }

        pinnedEntryKeys.append(contentsOf: entryKeys)
    }

    func registerDefaults() throws {
        guard let userDefaults,
              let defaultURL = Bundle.main.url(forResource: String(describing: PinStorage.self), withExtension: "plist")
        else {
            return
        }

        guard persistentDomain == nil
        else {
            return
        }

        let defaultData = try Data(contentsOf: defaultURL)
        guard let defaultDictionary = try PropertyListSerialization.propertyList(from: defaultData, format: nil) as? [String: Any]
        else {
            return
        }

        userDefaults.setPersistentDomain(defaultDictionary, forName: Self.suiteName)
    }

    func resetDefaults() {
        guard let userDefaults
        else {
            return
        }

        userDefaults.removePersistentDomain(forName: Self.suiteName)
    }

    private var observer: Any?

    func registerNotifications() {
        guard let userDefaults
        else {
            return
        }

        observer = NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: userDefaults, queue: .main) { [weak self] _ in
            self?.reloadData()
        }
    }

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
