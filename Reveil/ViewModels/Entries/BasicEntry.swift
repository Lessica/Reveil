//
//  BasicEntry.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import SwiftUI

struct BasicEntryIO: Codable {
    let download: BasicEntry
    let upload: BasicEntry
    var pair: [BasicEntry] { [download, upload] }
}

final class BasicEntry: Entry {
    init(key: EntryKey, name: String, value: String = "", color: Color? = nil, children: [BasicEntry]? = nil) {
        id = UUID()
        self.key = key
        self.name = name
        self.value = value
        self.color = color
        self.children = children
    }

    convenience init(customLabel: String, allowedToCopy: Bool = false) {
        self.init(key: allowedToCopy ? .AllowedToCopy(name: customLabel) : .Custom(name: customLabel), name: customLabel)
    }

    convenience init(sectionName: String) {
        self.init(key: .Section(name: sectionName), name: sectionName)
    }

    static let emptySection = BasicEntry(sectionName: "")

    let id: UUID
    let key: EntryKey
    let name: String
    @Published var value: String
    let color: Color?
    let children: [BasicEntry]?

    enum CodingKeys: CodingKey {
        case name
        case value
        case key
        case children
    }

    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(key: container.decode(EntryKey.self, forKey: .key),
                      name: container.decode(String.self, forKey: .name),
                      value: container.decode(String.self, forKey: .value),
                      children: container.decodeIfPresent([BasicEntry].self, forKey: .children))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(value, forKey: .value)
        try container.encodeIfPresent(key, forKey: .key)
        try container.encodeIfPresent(children, forKey: .children)
    }

    static let unknownValue = NSLocalizedString("UNKNOWN", comment: "Unknown")

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: BasicEntry, rhs: BasicEntry) -> Bool {
        lhs.id == rhs.id
    }
}
