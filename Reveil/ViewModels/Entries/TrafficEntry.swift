//
//  TrafficEntry.swift
//  Reveil
//
//  Created by Lessica on 2023/10/12.
//

import Combine
import DequeModule
import SwiftUI

typealias ActivityEntry = TrafficEntry<Double>

final class TrafficEntry<T>: Entry where T: BasicNumeric {
    private let maximumValueCount: Int
    private let overrideName: String?

    init(child: any Entry, values: [T] = [], maximumValueCount: Int = 1000, overrideName: String? = nil) {
        id = UUID()
        self.child = child
        self.maximumValueCount = maximumValueCount
        self.values = Deque(minimumCapacity: maximumValueCount)
        self.overrideName = overrideName
        self.values.append(contentsOf: values)
        if let usageChild = child as? UsageEntry<T> {
            childObserver = usageChild.$items.sink(receiveValue: { [weak self] items in
                self?.push(value: items.dropLast().reduce(0) { $0 + $1.value })
            })
        }
    }

    @Published var child: any Entry
    @Published var values: Deque<T>

    private var childObserver: AnyCancellable?
    var basicChild: BasicEntry? { child as? BasicEntry }
    var usageChild: UsageEntry<Double>? { child as? UsageEntry<Double> }

    let id: UUID
    var key: EntryKey { child.key }
    var name: String { overrideName ?? child.name }

    enum CodingKeys: CodingKey {
        case child
        case values
        case maximumValueCount
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
        try self.init(
            child: childEntry,
            values: container.decode([T].self, forKey: .values),
            maximumValueCount: container.decodeIfPresent(Int.self, forKey: .maximumValueCount) ?? 1000,
            overrideName: container.decodeIfPresent(String.self, forKey: .overrideName)
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(child, forKey: .child)
        try container.encode(values, forKey: .values)
        try container.encode(maximumValueCount, forKey: .maximumValueCount)
        try container.encodeIfPresent(overrideName, forKey: .overrideName)
    }

    func push(value: T) {
        if values.count > maximumValueCount {
            _ = values.popFirst()
        }
        values.append(value)
    }

    func invalidate() {
        let prevValues = values.map { -abs($0) }
        values.removeAll(keepingCapacity: true)
        values.append(contentsOf: prevValues)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: TrafficEntry, rhs: TrafficEntry) -> Bool {
        lhs.id == rhs.id
    }

    deinit {
        childObserver?.cancel()
    }
}
