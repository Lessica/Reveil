//
//  TrafficEntryIO.swift
//  Reveil
//
//  Created by Lessica on 2023/10/22.
//

import Foundation

final class TrafficEntryIO: Entry {
    private let overrideName: String?

    init(child: any Entry, download: TrafficEntry<Int64>, upload: TrafficEntry<Int64>, overrideName: String? = nil) {
        id = UUID()
        self.child = child
        self.download = download
        self.upload = upload
        self.overrideName = overrideName
    }

    @Published var child: any Entry
    var basicChild: BasicEntry? { child as? BasicEntry }
    var usageChild: UsageEntry<Double>? { child as? UsageEntry<Double> }

    @Published var download: TrafficEntry<Int64>
    @Published var upload: TrafficEntry<Int64>
    var pair: [TrafficEntry<Int64>] { [download, upload] }

    let id: UUID
    var key: EntryKey { child.key }
    var name: String { overrideName ?? child.name }

    enum CodingKeys: CodingKey {
        case child
        case download
        case upload
        case overrideName
    }

    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var childEntry: any Entry
        if let basicEntry = try? container.decode(BasicEntry.self, forKey: .child) {
            childEntry = basicEntry
        } else if let usageEntry = try? container.decode(UsageEntry<Double>.self, forKey: .child) {
            childEntry = usageEntry
        } else {
            throw DecodingError.dataCorruptedError(forKey: CodingKeys.child, in: container,
                                                   debugDescription: "The only child is neither a basic entry or an usage entry.")
        }
        try self.init(child: childEntry,
                      download: container.decode(TrafficEntry<Int64>.self, forKey: .download),
                      upload: container.decode(TrafficEntry<Int64>.self, forKey: .upload),
                      overrideName: container.decodeIfPresent(String.self, forKey: .overrideName))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(child, forKey: .child)
        try container.encode(download, forKey: .download)
        try container.encode(upload, forKey: .upload)
        try container.encodeIfPresent(overrideName, forKey: .overrideName)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: TrafficEntryIO, rhs: TrafficEntryIO) -> Bool {
        lhs.id == rhs.id
    }
}
