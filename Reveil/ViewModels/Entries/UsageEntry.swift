//
//  UsageEntry.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import SwiftUI

final class UsageEntry<T>: Entry where T: BasicNumeric {
    init(key: EntryKey, name: String, items: [UsageEntry.Item]) {
        id = UUID()
        self.key = key
        self.name = name
        self.items = items
    }

    struct Item: Identifiable, Codable, Equatable {
        let id: UUID
        let label: String
        let value: T
        let color: Color
        let description: String?

        init(label: String, value: T, color: Color, description: String? = nil) {
            id = UUID()
            self.label = label
            self.value = value
            self.color = color
            self.description = description
        }

        enum CodingKeys: CodingKey {
            case label
            case value
            case description
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            try self.init(label: container.decode(String.self, forKey: .label),
                          value: container.decode(T.self, forKey: .value),
                          color: Color.clear,
                          description: container.decodeIfPresent(String.self, forKey: .description))
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: UsageEntry<T>.Item.CodingKeys.self)
            try container.encode(label, forKey: UsageEntry.Item.CodingKeys.label)
            try container.encode(value, forKey: UsageEntry.Item.CodingKeys.value)
            try container.encodeIfPresent(description, forKey: UsageEntry.Item.CodingKeys.description)
        }
    }

    let id: UUID
    let key: EntryKey
    let name: String
    @Published var items: [Item]

    enum CodingKeys: CodingKey {
        case name
        case items
        case key
    }

    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(key: container.decode(EntryKey.self, forKey: .key),
                      name: container.decode(String.self, forKey: .name),
                      items: container.decode([Item].self, forKey: .items))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(items, forKey: .items)
        try container.encodeIfPresent(key, forKey: .key)
    }

    var firstDescription: String? { items.first?.description }
    var lastDescription: String? { items.last?.description }

    var totalValue: T { items.reduce(0) { $0 + $1.value } }

    func ratio(item: Item?) -> T? {
        guard let item else {
            return nil
        }
        return item.value / totalValue
    }

    var firstRatio: T? { ratio(item: items.first) }
    var lastRatio: T? { ratio(item: items.last) }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: UsageEntry, rhs: UsageEntry) -> Bool {
        lhs.id == rhs.id
    }
}
