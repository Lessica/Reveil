//
//  DiskSpace.swift
//  Reveil
//
//  Created by Lessica on 2023/10/6.
//

import SwiftUI

final class DiskSpace: Module {
    static let shared = DiskSpace()
    private let id = UUID()

    let moduleName = NSLocalizedString("DISK_SPACE", comment: "Disk Space")

    private let diskUsage = DiskUsage.shared

    private let gBufferFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowedUnits = [.useMB, .useGB]
        return formatter
    }()

    private var usageItems: [UsageEntry<Double>.Item] {
        [
            UsageEntry.Item(label: "Used", value: Double(diskUsage.usedDiskSpaceInBytes) / System.Unit.gigabyte.rawValue, color: Color.accentColor, description: String(format: NSLocalizedString("USED_DESCRIPTION", comment: "Used: %@"), gBufferFormatter.string(fromByteCount: diskUsage.usedDiskSpaceInBytes))),
            UsageEntry.Item(label: "Free", value: Double(diskUsage.freeDiskSpaceInBytes) / System.Unit.gigabyte.rawValue, color: Color.clear, description: String(format: NSLocalizedString("FREE_DESCRIPTION", comment: "Free: %@"), gBufferFormatter.string(fromByteCount: diskUsage.freeDiskSpaceInBytes))),
        ]
    }

    lazy var usageEntry: UsageEntry<Double>? = usageEntry(key: .DiskSpace)

    lazy var basicEntries: [BasicEntry] = {
        reloadData()
        return updatableEntryKeys.compactMap { basicEntry(key: $0) }
    }()

    func reloadData() {
        diskUsage.reloadData()
    }

    func updateEntries() {
        reloadData()
        usageEntry?.items = usageItems
        basicEntries.forEach { updateBasicEntry($0) }
    }

    let updatableEntryKeys: [EntryKey] = [
        .DiskSpace,
        .DiskTotal,
        .DiskUsed,
        .DiskFree,
    ]

    func basicEntry(key: EntryKey, style: ValueStyle = .detailed) -> BasicEntry? {
        switch key {
        case .DiskTotal:
            return BasicEntry(
                key: .DiskTotal,
                name: style == .dashboard ? NSLocalizedString("DISK_TOTAL_LONG", comment: "Disk Total") : NSLocalizedString("DISK_TOTAL", comment: "Total"),
                value: gBufferFormatter.string(fromByteCount: diskUsage.totalDiskSpaceInBytes)
            )
        case .DiskUsed:
            return BasicEntry(
                key: .DiskUsed,
                name: style == .dashboard ? NSLocalizedString("DISK_USED_LONG", comment: "Disk Used") : NSLocalizedString("DISK_USED", comment: "Used"),
                value: gBufferFormatter.string(fromByteCount: diskUsage.usedDiskSpaceInBytes)
            )
        case .DiskFree:
            return BasicEntry(
                key: .DiskFree,
                name: style == .dashboard ? NSLocalizedString("DISK_FREE_LONG", comment: "Disk Free") : NSLocalizedString("DISK_FREE", comment: "Free"),
                value: gBufferFormatter.string(fromByteCount: diskUsage.freeDiskSpaceInBytes)
            )
        default:
            break
        }
        return nil
    }

    func updateBasicEntry(_ entry: BasicEntry, style _: ValueStyle = .detailed) {
        switch entry.key {
        case .DiskTotal:
            entry.value = gBufferFormatter.string(fromByteCount: diskUsage.totalDiskSpaceInBytes)
        case .DiskUsed:
            entry.value = gBufferFormatter.string(fromByteCount: diskUsage.usedDiskSpaceInBytes)
        case .DiskFree:
            entry.value = gBufferFormatter.string(fromByteCount: diskUsage.freeDiskSpaceInBytes)
        default:
            break
        }
    }

    func usageEntry(key: EntryKey, style: ValueStyle = .detailed) -> UsageEntry<Double>? {
        switch key {
        case .DiskSpace:
            return UsageEntry(key: .DiskSpace, name: style == .dashboard ? NSLocalizedString("DISK_USED_LONG", comment: "Disk Used") : moduleName, items: usageItems)
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
