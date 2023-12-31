//
//  NetworkUsage.swift
//  Reveil
//
//  Created by Lessica on 2023/10/10.
//

import SwiftUI

final class NetworkUsage: Module {
    static let shared = NetworkUsage()

    private init() {
        netStats = NetworkTraffic.shared.getStatistics()
    }

    let moduleName = NSLocalizedString("NETWORK_USAGE", comment: "Network Usage")

    private var usageItems: [UsageEntry<Double>.Item] {
        NetworkPrefix.categoryCases.compactMap { pfx in
            guard let trafficBytes = netStats.allBytes(prefix: pfx) else {
                return nil
            }
            return UsageEntry.Item(
                label: pfx.description,
                value: Double(trafficBytes),
                color: pfx.color ?? Color.clear
            )
        }
    }

    lazy var usageEntry: UsageEntry<Double>? = usageEntry(key: .NetworkUsage)

    private var netStats: NetworkStatistics

    lazy var basicEntries: [BasicEntry] = {
        reloadData()
        return updatableEntryKeys.compactMap { basicEntry(key: $0) }
    }()

    func reloadData() {
        netStats = NetworkTraffic.shared.getStatistics()
    }

    func updateEntries() {
        reloadData()
        usageEntry?.items = usageItems
        basicEntries.forEach { updateBasicEntry($0) }
    }

    lazy var updatableEntryKeys: [EntryKey] = [.NetworkUsage] + NetworkPrefix.categoryCases.compactMap { .NetworkCategoryUsage(prefix: $0.rawValue) }

    func basicEntry(key: EntryKey, style: ValueStyle = .detailed) -> BasicEntry? {
        switch key {
        case let .NetworkCategoryUsage(prefix):
            if let pfx = NetworkPrefix(rawValue: prefix) {
                return BasicEntry(
                    key: key,
                    name: pfx.description,
                    value: netStats.entryValue(prefix: pfx, style: style),
                    color: pfx.color ?? Color(PlatformColor.secondarySystemFillAlias)
                )
            }
        default:
            break
        }
        return nil
    }

    func updateBasicEntry(_ entry: BasicEntry, style: ValueStyle = .detailed) {
        switch entry.key {
        case let .NetworkCategoryUsage(prefix):
            if let pfx = NetworkPrefix(keyName: prefix) {
                entry.value = netStats.entryValue(prefix: pfx, style: style)
            }
        default:
            break
        }
    }

    func usageEntry(key: EntryKey, style _: ValueStyle = .detailed) -> UsageEntry<Double>? {
        switch key {
        case .NetworkUsage:
            return UsageEntry(key: .NetworkUsage, name: moduleName, items: usageItems)
        default:
            break
        }
        return nil
    }

    func updateUsageEntry(_ entry: UsageEntry<Double>, style _: ValueStyle) {
        entry.items = usageItems
    }

    func trafficEntryIO(key _: EntryKey, style _: ValueStyle) -> TrafficEntryIO? { nil }

    func updateTrafficEntryIO(_: TrafficEntryIO, style _: ValueStyle) {}
}
