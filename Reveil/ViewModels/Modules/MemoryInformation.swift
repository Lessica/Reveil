//
//  MemoryInformation.swift
//  Reveil
//
//  Created by Lessica on 2023/10/5.
//

import SwiftUI

final class MemoryInformation: Module {
    static let shared = MemoryInformation()

    private init() {
        memoryInfo = Self.getMemoryInfo()
    }

    let moduleName = NSLocalizedString("MEMORY_INFORMATION", comment: "Memory Information")

    private let gBufferFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        return formatter
    }()

    private let gLargeNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        return formatter
    }()

    private var usageItems: [UsageEntry<Double>.Item] {
        let total = Double(memoryInfo.total)
        return [
            UsageEntry.Item(label: "MemoryWired",
                            value: Double(memoryInfo.wired) / total,
                            color: Color("MemoryWired")),
            UsageEntry.Item(label: "MemoryActive",
                            value: Double(memoryInfo.active) / total,
                            color: Color("MemoryActive")),
            UsageEntry.Item(label: "MemoryInactive",
                            value: Double(memoryInfo.inactive) / total,
                            color: Color("MemoryInactive")),
            UsageEntry.Item(label: "MemoryPurgeable",
                            value: Double(memoryInfo.purgeable) / total,
                            color: Color("MemoryPurgeable")),
            UsageEntry.Item(label: "MemoryOthers",
                            value: Double(memoryInfo.others) / total,
                            color: Color("MemoryOthers")),
            UsageEntry.Item(label: "MemoryFree",
                            value: Double(memoryInfo.free) / total,
                            color: Color.clear),
        ]
    }

    lazy var usageEntry: UsageEntry<Double>? = usageEntry(key: .MemoryInformation)

    private struct MemoryInfo {
        let wired: UInt64
        let active: UInt64
        let inactive: UInt64
        let purgeable: UInt64
        let others: UInt64
        let free: UInt64
        let total: UInt64
        let basicInfo: host_basic_info
        let vmStatistics: vm_statistics64
    }

    private var memoryInfo: MemoryInfo

    private static func getMemoryInfo() -> MemoryInfo {
        let basicInfo = System.hostBasicInfo()
        let memoryInfo = System.VMStatistics64()

        let wiredCount = UInt64(memoryInfo.wire_count) &* UInt64(System.PAGE_SIZE)
        let activeCount = UInt64(memoryInfo.active_count) &* UInt64(System.PAGE_SIZE)
        let inactiveCount = UInt64(memoryInfo.inactive_count) &* UInt64(System.PAGE_SIZE)
        let purgeableCount = UInt64(memoryInfo.purgeable_count) &* UInt64(System.PAGE_SIZE)
        let freeCount = UInt64(memoryInfo.free_count) &* UInt64(System.PAGE_SIZE)

        var usedCount: UInt64 = 0
        usedCount &+= wiredCount
        usedCount &+= activeCount
        usedCount &+= inactiveCount
        usedCount &+= purgeableCount
        usedCount &+= freeCount

        let othersCount: UInt64 = basicInfo.max_mem > usedCount ? basicInfo.max_mem - usedCount : 0

        return MemoryInfo(
            wired: wiredCount,
            active: activeCount,
            inactive: inactiveCount,
            purgeable: purgeableCount,
            others: othersCount,
            free: freeCount,
            total: basicInfo.max_mem,
            basicInfo: basicInfo,
            vmStatistics: memoryInfo
        )
    }

    enum MemoryDescriptionName: Codable {
        case wired
        case active
        case inactive
        case purgeable
        case others
        case free
    }

    private func getMemoryDescription(_ memoryInfo: MemoryInfo, name: MemoryDescriptionName, style: ValueStyle = .detailed) -> String {
        let count: UInt64
        switch name {
        case .wired:
            count = memoryInfo.wired
        case .active:
            count = memoryInfo.active
        case .inactive:
            count = memoryInfo.inactive
        case .purgeable:
            count = memoryInfo.purgeable
        case .others:
            count = memoryInfo.others
        case .free:
            count = memoryInfo.free
        }
        if count > UInt64(Int64.max) {
            return "+???"
        }
        if style == .dashboard {
            return gBufferFormatter.string(fromByteCount: Int64(count))
        }
        return String(format: "%@\n%.2f%%",
                      gBufferFormatter.string(fromByteCount: Int64(count)),
                      Double(count) / Double(memoryInfo.total) * 100.0)
    }

    lazy var basicEntries: [BasicEntry] = {
        reloadData()
        return updatableEntryKeys.compactMap { basicEntry(key: $0) }
    }()

    func reloadData() {
        memoryInfo = Self.getMemoryInfo()
    }

    func updateEntries() {
        reloadData()
        usageEntry?.items = usageItems
        basicEntries.forEach { updateBasicEntry($0) }
    }

    let updatableEntryKeys: [EntryKey] = [
        .MemoryInformation,
        .MemoryBytesWired,
        .MemoryBytesActive,
        .MemoryBytesInactive,
        .MemoryBytesPurgeable,
        .MemoryBytesOthers,
        .MemoryBytesFree,
        .MemoryPageReactivations,
        .MemoryPageIns,
        .MemoryPageOuts,
        .MemoryPageFaults,
        .MemoryPageCOWFaults,
        .MemoryPageLookups,
        .MemoryPageHits,
        .MemoryPagePurges,
        .MemoryBytesZeroFilled,
        .MemoryBytesSpeculative,
        .MemoryBytesDecompressed,
        .MemoryBytesCompressed,
        .MemoryBytesSwappedIn,
        .MemoryBytesSwappedOut,
        .MemoryBytesCompressor,
        .MemoryBytesThrottled,
        .MemoryBytesFileBacked,
        .MemoryBytesAnonymous,
        .MemoryBytesUncompressed,
        .MemorySize,
        .PhysicalMemory,
        .UserMemory,
        .KernelPageSize,
        .PageSize,
    ]

    func basicEntry(key: EntryKey, style: ValueStyle = .detailed) -> BasicEntry? {
        switch key {
        case .MemoryBytesWired:
            return BasicEntry(
                key: .MemoryBytesWired,
                name: style == .dashboard ? NSLocalizedString("MEMORY_WIRED_LONG", comment: "Wired Memory") : NSLocalizedString("MEMORY_WIRED", comment: "Wired"),
                value: getMemoryDescription(memoryInfo, name: .wired, style: style),
                color: Color("MemoryWired")
            )
        case .MemoryBytesActive:
            return BasicEntry(
                key: .MemoryBytesActive,
                name: style == .dashboard ? NSLocalizedString("MEMORY_ACTIVE_LONG", comment: "Active Memory") : NSLocalizedString("MEMORY_ACTIVE", comment: "Active"),
                value: getMemoryDescription(memoryInfo, name: .active, style: style),
                color: Color("MemoryActive")
            )
        case .MemoryBytesInactive:
            return BasicEntry(
                key: .MemoryBytesInactive,
                name: style == .dashboard ? NSLocalizedString("MEMORY_INACTIVE_LONG", comment: "Inactive Memory") : NSLocalizedString("MEMORY_INACTIVE", comment: "Inactive"),
                value: getMemoryDescription(memoryInfo, name: .inactive, style: style),
                color: Color("MemoryInactive")
            )
        case .MemoryBytesPurgeable:
            return BasicEntry(
                key: .MemoryBytesPurgeable,
                name: style == .dashboard ? NSLocalizedString("MEMORY_PURGEABLE_LONG", comment: "Purgeable Memory") : NSLocalizedString("MEMORY_PURGEABLE", comment: "Purgeable"),
                value: getMemoryDescription(memoryInfo, name: .purgeable, style: style),
                color: Color("MemoryPurgeable")
            )
        case .MemoryBytesOthers:
            return BasicEntry(
                key: .MemoryBytesOthers,
                name: style == .dashboard ? NSLocalizedString("MEMORY_OTHERS_LONG", comment: "Others Memory") : NSLocalizedString("MEMORY_OTHERS", comment: "Others"),
                value: getMemoryDescription(memoryInfo, name: .others, style: style),
                color: Color("MemoryOthers")
            )
        case .MemoryBytesFree:
            return BasicEntry(
                key: .MemoryBytesFree,
                name: style == .dashboard ? NSLocalizedString("MEMORY_FREE_LONG", comment: "Free Memory") : NSLocalizedString("MEMORY_FREE", comment: "Free"),
                value: getMemoryDescription(memoryInfo, name: .free, style: style),
                color: Color(PlatformColor.secondarySystemFillAlias)
            )
        case .MemoryPageReactivations:
            return BasicEntry(
                key: .MemoryPageReactivations,
                name: style == .dashboard ? NSLocalizedString("PAGE_REACTIVATIONS", comment: "Page Reactivations") : NSLocalizedString("REACTIVATIONS", comment: "Reactivations"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: Int64(memoryInfo.vmStatistics.reactivations))) ?? BasicEntry.unknownValue
            )
        case .MemoryPageIns:
            return BasicEntry(
                key: .MemoryPageIns,
                name: style == .dashboard ? NSLocalizedString("PAGE_INS_LONG", comment: "Page Ins") : NSLocalizedString("PAGE_INS", comment: "PageIns"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: Int64(memoryInfo.vmStatistics.pageins))) ?? BasicEntry.unknownValue
            )
        case .MemoryPageOuts:
            return BasicEntry(
                key: .MemoryPageOuts,
                name: style == .dashboard ? NSLocalizedString("PAGE_OUTS_LONG", comment: "Page Outs") : NSLocalizedString("PAGE_OUTS", comment: "PageOuts"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: Int64(memoryInfo.vmStatistics.pageouts))) ?? BasicEntry.unknownValue
            )
        case .MemoryPageFaults:
            return BasicEntry(
                key: .MemoryPageFaults,
                name: style == .dashboard ? NSLocalizedString("MEMORY_FAULTS", comment: "Memory Faults") : NSLocalizedString("FAULTS", comment: "Faults"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: Int64(memoryInfo.vmStatistics.faults))) ?? BasicEntry.unknownValue
            )
        case .MemoryPageCOWFaults:
            return BasicEntry(
                key: .MemoryPageCOWFaults,
                name: style == .dashboard ? NSLocalizedString("MEMORY_COW_FAULTS", comment: "Memory COW Faults") : NSLocalizedString("COW_FAULTS", comment: "COW Faults"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: Int64(memoryInfo.vmStatistics.cow_faults))) ?? BasicEntry.unknownValue
            )
        case .MemoryPageLookups:
            return BasicEntry(
                key: .MemoryPageLookups,
                name: style == .dashboard ? NSLocalizedString("MEMORY_LOOKUPS", comment: "Memory Lookups") : NSLocalizedString("LOOKUPS", comment: "Lookups"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: Int64(memoryInfo.vmStatistics.lookups))) ?? BasicEntry.unknownValue
            )
        case .MemoryPageHits:
            return BasicEntry(
                key: .MemoryPageHits,
                name: style == .dashboard ? NSLocalizedString("MEMORY_HITS", comment: "Memory Hits") : NSLocalizedString("HITS", comment: "Hits"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: Int64(memoryInfo.vmStatistics.hits))) ?? BasicEntry.unknownValue
            )
        case .MemoryPagePurges:
            return BasicEntry(
                key: .MemoryPagePurges,
                name: style == .dashboard ? NSLocalizedString("MEMORY_PURGES", comment: "Memory Purges") : NSLocalizedString("PURGES", comment: "Purges"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: Int64(memoryInfo.vmStatistics.purges))) ?? BasicEntry.unknownValue
            )
        case .MemoryBytesZeroFilled:
            return BasicEntry(
                key: .MemoryBytesZeroFilled,
                name: style == .dashboard ? NSLocalizedString("MEMORY_ZERO_FILLED", comment: "Zero Filled Memory") : NSLocalizedString("ZERO_FILLED", comment: "Zero Filled"),
                value: gBufferFormatter.string(fromByteCount: Int64(memoryInfo.vmStatistics.zero_fill_count * UInt64(System.PAGE_SIZE)))
            )
        case .MemoryBytesSpeculative:
            return BasicEntry(
                key: .MemoryBytesSpeculative,
                name: style == .dashboard ? NSLocalizedString("MEMORY_SPECULATIVE", comment: "Speculative Memory") : NSLocalizedString("SPECULATIVE", comment: "Speculative"),
                value: gBufferFormatter.string(fromByteCount: Int64(UInt64(memoryInfo.vmStatistics.speculative_count) * UInt64(System.PAGE_SIZE)))
            )
        case .MemoryBytesDecompressed:
            return BasicEntry(
                key: .MemoryBytesDecompressed,
                name: style == .dashboard ? NSLocalizedString("MEMORY_DECOMPRESSED", comment: "Decompressed Memory") : NSLocalizedString("DECOMPRESSED", comment: "Decompressed"),
                value: gBufferFormatter.string(fromByteCount: Int64(memoryInfo.vmStatistics.decompressions * UInt64(System.PAGE_SIZE)))
            )
        case .MemoryBytesCompressed:
            return BasicEntry(
                key: .MemoryBytesCompressed,
                name: style == .dashboard ? NSLocalizedString("MEMORY_COMPRESSED", comment: "Compressed Memory") : NSLocalizedString("COMPRESSED", comment: "Compressed"),
                value: gBufferFormatter.string(fromByteCount: Int64(memoryInfo.vmStatistics.compressions * UInt64(System.PAGE_SIZE)))
            )
        case .MemoryBytesSwappedIn:
            return BasicEntry(
                key: .MemoryBytesSwappedIn,
                name: style == .dashboard ? NSLocalizedString("MEMORY_SWAPPED_IN", comment: "Swapped In Memory") : NSLocalizedString("SWAPPED_IN", comment: "Swapped In"),
                value: gBufferFormatter.string(fromByteCount: Int64(memoryInfo.vmStatistics.swapins * UInt64(System.PAGE_SIZE)))
            )
        case .MemoryBytesSwappedOut:
            return BasicEntry(
                key: .MemoryBytesSwappedOut,
                name: style == .dashboard ? NSLocalizedString("MEMORY_SWAPPED_OUT", comment: "Swapped Out Memory") : NSLocalizedString("SWAPPED_OUT", comment: "Swapped Out"),
                value: gBufferFormatter.string(fromByteCount: Int64(memoryInfo.vmStatistics.swapouts * UInt64(System.PAGE_SIZE)))
            )
        case .MemoryBytesCompressor:
            return BasicEntry(
                key: .MemoryBytesCompressor,
                name: style == .dashboard ? NSLocalizedString("MEMORY_COMPRESSOR", comment: "Compressor Memory") : NSLocalizedString("COMPRESSOR", comment: "Compressor"),
                value: gBufferFormatter.string(fromByteCount: Int64(UInt64(memoryInfo.vmStatistics.compressor_page_count) * UInt64(System.PAGE_SIZE)))
            )
        case .MemoryBytesThrottled:
            return BasicEntry(
                key: .MemoryBytesThrottled,
                name: style == .dashboard ? NSLocalizedString("MEMORY_THROTTLED", comment: "Throttled Memory") : NSLocalizedString("THROTTLED", comment: "Throttled"),
                value: gBufferFormatter.string(fromByteCount: Int64(UInt64(memoryInfo.vmStatistics.throttled_count) * UInt64(System.PAGE_SIZE)))
            )
        case .MemoryBytesFileBacked:
            return BasicEntry(
                key: .MemoryBytesFileBacked,
                name: style == .dashboard ? NSLocalizedString("MEMORY_FILE_BACKED", comment: "File-backed Memory") : NSLocalizedString("FILE_BACKED", comment: "File-backed"),
                value: gBufferFormatter.string(fromByteCount: Int64(UInt64(memoryInfo.vmStatistics.external_page_count) * UInt64(System.PAGE_SIZE)))
            )
        case .MemoryBytesAnonymous:
            return BasicEntry(
                key: .MemoryBytesAnonymous,
                name: style == .dashboard ? NSLocalizedString("MEMORY_ANONYMOUS", comment: "Anonymous Memory") : NSLocalizedString("ANONYMOUS", comment: "Anonymous"),
                value: gBufferFormatter.string(fromByteCount: Int64(UInt64(memoryInfo.vmStatistics.internal_page_count) * UInt64(System.PAGE_SIZE)))
            )
        case .MemoryBytesUncompressed:
            return BasicEntry(
                key: .MemoryBytesUncompressed,
                name: style == .dashboard ? NSLocalizedString("MEMORY_UNCOMPRESSED", comment: "Uncompressed Memory") : NSLocalizedString("UNCOMPRESSED", comment: "Uncompressed"),
                value: gBufferFormatter.string(fromByteCount: Int64(memoryInfo.vmStatistics.total_uncompressed_pages_in_compressor * UInt64(System.PAGE_SIZE)))
            )
        case .MemorySize:
            return BasicEntry(
                key: .MemorySize,
                name: NSLocalizedString("MEMORY_SIZE", comment: "Memory Size"),
                value: gBufferFormatter.string(fromByteCount: Int64(System.hardwareMemorySize()))
            )
        case .PhysicalMemory:
            return BasicEntry(
                key: .PhysicalMemory,
                name: NSLocalizedString("PHYSICAL_MEMORY", comment: "Physical Memory"),
                value: gBufferFormatter.string(fromByteCount: Int64(memoryInfo.basicInfo.max_mem))
            )
        case .UserMemory:
            let memoryInfo = memoryInfo
            return BasicEntry(
                key: .UserMemory,
                name: NSLocalizedString("USER_MEMORY", comment: "User Memory"),
                value: gBufferFormatter.string(fromByteCount: Int64(memoryInfo.basicInfo.max_mem &- UInt64(memoryInfo.vmStatistics.wire_count) &* UInt64(natural_t(System.PAGE_SIZE))))
            )
        case .KernelPageSize:
            return BasicEntry(
                key: .KernelPageSize,
                name: NSLocalizedString("KERNEL_PAGE_SIZE", comment: "Kernel Page Size"),
                value: gBufferFormatter.string(fromByteCount: Int64(System.KERNEL_PAGE_SIZE))
            )
        case .PageSize:
            return BasicEntry(
                key: .PageSize,
                name: NSLocalizedString("PAGE_SIZE", comment: "Page Size"),
                value: gBufferFormatter.string(fromByteCount: Int64(System.PAGE_SIZE))
            )
        default:
            break
        }
        return nil
    }

    func updateBasicEntry(_ entry: BasicEntry, style: ValueStyle = .detailed) {
        switch entry.key {
        case .MemoryBytesWired:
            entry.value = getMemoryDescription(memoryInfo, name: .wired, style: style)
        case .MemoryBytesActive:
            entry.value = getMemoryDescription(memoryInfo, name: .active, style: style)
        case .MemoryBytesInactive:
            entry.value = getMemoryDescription(memoryInfo, name: .inactive, style: style)
        case .MemoryBytesPurgeable:
            entry.value = getMemoryDescription(memoryInfo, name: .purgeable, style: style)
        case .MemoryBytesOthers:
            entry.value = getMemoryDescription(memoryInfo, name: .others, style: style)
        case .MemoryBytesFree:
            entry.value = getMemoryDescription(memoryInfo, name: .free, style: style)
        case .MemoryPageReactivations:
            entry.value = gLargeNumberFormatter.string(from: NSNumber(value: Int64(memoryInfo.vmStatistics.reactivations))) ?? BasicEntry.unknownValue
        case .MemoryPageIns:
            entry.value = gLargeNumberFormatter.string(from: NSNumber(value: Int64(memoryInfo.vmStatistics.pageins))) ?? BasicEntry.unknownValue
        case .MemoryPageOuts:
            entry.value = gLargeNumberFormatter.string(from: NSNumber(value: Int64(memoryInfo.vmStatistics.pageouts))) ?? BasicEntry.unknownValue
        case .MemoryPageFaults:
            entry.value = gLargeNumberFormatter.string(from: NSNumber(value: Int64(memoryInfo.vmStatistics.faults))) ?? BasicEntry.unknownValue
        case .MemoryPageCOWFaults:
            entry.value = gLargeNumberFormatter.string(from: NSNumber(value: Int64(memoryInfo.vmStatistics.cow_faults))) ?? BasicEntry.unknownValue
        case .MemoryPageLookups:
            entry.value = gLargeNumberFormatter.string(from: NSNumber(value: Int64(memoryInfo.vmStatistics.lookups))) ?? BasicEntry.unknownValue
        case .MemoryPageHits:
            entry.value = gLargeNumberFormatter.string(from: NSNumber(value: Int64(memoryInfo.vmStatistics.hits))) ?? BasicEntry.unknownValue
        case .MemoryPagePurges:
            entry.value = gLargeNumberFormatter.string(from: NSNumber(value: Int64(memoryInfo.vmStatistics.purges))) ?? BasicEntry.unknownValue
        case .MemoryBytesZeroFilled:
            entry.value = gBufferFormatter.string(fromByteCount: Int64(memoryInfo.vmStatistics.zero_fill_count * UInt64(System.PAGE_SIZE)))
        case .MemoryBytesSpeculative:
            entry.value = gBufferFormatter.string(fromByteCount: Int64(UInt64(memoryInfo.vmStatistics.speculative_count) * UInt64(System.PAGE_SIZE)))
        case .MemoryBytesDecompressed:
            entry.value = gBufferFormatter.string(fromByteCount: Int64(memoryInfo.vmStatistics.decompressions * UInt64(System.PAGE_SIZE)))
        case .MemoryBytesCompressed:
            entry.value = gBufferFormatter.string(fromByteCount: Int64(memoryInfo.vmStatistics.compressions * UInt64(System.PAGE_SIZE)))
        case .MemoryBytesSwappedIn:
            entry.value = gBufferFormatter.string(fromByteCount: Int64(memoryInfo.vmStatistics.swapins * UInt64(System.PAGE_SIZE)))
        case .MemoryBytesSwappedOut:
            entry.value = gBufferFormatter.string(fromByteCount: Int64(memoryInfo.vmStatistics.swapouts * UInt64(System.PAGE_SIZE)))
        case .MemoryBytesCompressor:
            entry.value = gBufferFormatter.string(fromByteCount: Int64(UInt64(memoryInfo.vmStatistics.compressor_page_count) * UInt64(System.PAGE_SIZE)))
        case .MemoryBytesThrottled:
            entry.value = gBufferFormatter.string(fromByteCount: Int64(UInt64(memoryInfo.vmStatistics.throttled_count) * UInt64(System.PAGE_SIZE)))
        case .MemoryBytesFileBacked:
            entry.value = gBufferFormatter.string(fromByteCount: Int64(UInt64(memoryInfo.vmStatistics.external_page_count) * UInt64(System.PAGE_SIZE)))
        case .MemoryBytesAnonymous:
            entry.value = gBufferFormatter.string(fromByteCount: Int64(UInt64(memoryInfo.vmStatistics.internal_page_count) * UInt64(System.PAGE_SIZE)))
        case .MemoryBytesUncompressed:
            entry.value = gBufferFormatter.string(fromByteCount: Int64(memoryInfo.vmStatistics.total_uncompressed_pages_in_compressor * UInt64(System.PAGE_SIZE)))
        default:
            break
        }
    }

    func usageEntry(key: EntryKey, style _: ValueStyle = .detailed) -> UsageEntry<Double>? {
        switch key {
        case .MemoryInformation:
            return UsageEntry(key: .MemoryInformation, name: moduleName, items: usageItems)
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
