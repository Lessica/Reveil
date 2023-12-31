//
//  BatteryInformation.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import SwiftUI

final class BatteryInformation: Module {
    static let shared = BatteryInformation()

    private init() {
        batteryLevel = Double(BatteryActivity.shared.getBatteryLevel())
        batteryUsed = 1.0 - batteryLevel
        batteryState = BatteryActivity.shared.getBatteryState()
    }

    let moduleName = NSLocalizedString("BATTERY_INFORMATION", comment: "Battery Information")

    private let gLargeNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        return formatter
    }()

    private var usageItems: [UsageEntry<Double>.Item] {
        [
            UsageEntry.Item(label: "Level", value: Double(batteryLevel), color: Color.accentColor),
            UsageEntry.Item(label: "Used", value: Double(batteryUsed), color: Color.clear),
        ]
    }

    lazy var usageEntry: UsageEntry<Double>? = usageEntry(key: .BatteryInformation)

    private var batteryLevel: Double
    private var batteryUsed: Double
    private var batteryState: BatteryActivity.BatteryState

    private lazy var batteryCapacity: Double = DeviceInformation.shared.gModelDictionary?["battery_capacity"] as? Double ?? 0

    private lazy var batteryCapacityDescription: String = if batteryCapacity > 0,
                                                             let numericCapacity = gLargeNumberFormatter.string(from: NSNumber(value: Int64(batteryCapacity * 1000.0)))
    {
        String(format: "%@ mAh", numericCapacity)
    } else {
        BasicEntry.unknownValue
    }

    lazy var basicEntries: [BasicEntry] = {
        reloadData()
        return updatableEntryKeys.compactMap { basicEntry(key: $0) }
    }()

    func reloadData() {
        batteryLevel = Double(BatteryActivity.shared.getBatteryLevel())
        batteryUsed = 1.0 - batteryLevel
        batteryState = BatteryActivity.shared.getBatteryState()
    }

    func updateEntries() {
        reloadData()
        usageEntry?.items = usageItems
        basicEntries.forEach { updateBasicEntry($0) }
    }

    let updatableEntryKeys: [EntryKey] = [
        .BatteryInformation,
        .BatteryLevel,
        .BatteryUsed,
        .BatteryState,
        .BatteryCapacity,
    ]

    func basicEntry(key: EntryKey, style: ValueStyle = .detailed) -> BasicEntry? {
        switch key {
        case .BatteryLevel:
            return BasicEntry(
                key: .BatteryLevel,
                name: style == .detailed ? NSLocalizedString("BATTERY_LEVEL", comment: "Level") : NSLocalizedString("BATTERY_LEVEL_FULL", comment: "Battery Level"),
                value: String(format: "%d%%", Int(round(batteryLevel * 100.0))),
                color: Color.accentColor
            )
        case .BatteryUsed:
            return BasicEntry(
                key: .BatteryUsed,
                name: style == .detailed ? NSLocalizedString("BATTERY_USED", comment: "Used") : NSLocalizedString("BATTERY_USED_FULL", comment: "Battery Used"),
                value: String(format: "%d%%", Int(round(batteryUsed * 100.0))),
                color: Color(PlatformColor.secondarySystemFillAlias)
            )
        case .BatteryState:
            return BasicEntry(
                key: .BatteryState,
                name: style == .detailed ? NSLocalizedString("BATTERY_STATE", comment: "State") : NSLocalizedString("BATTERY_STATE_FULL", comment: "Battery State"),
                value: batteryState.description
            )
        case .BatteryCapacity:
            return BasicEntry(
                key: .BatteryCapacity,
                name: style == .detailed ? NSLocalizedString("BATTERY_CAPACITY", comment: "Capacity") : NSLocalizedString("BATTERY_CAPACITY_FULL", comment: "Battery Capacity"),
                value: batteryCapacityDescription
            )
        default:
            break
        }
        return nil
    }

    func updateBasicEntry(_ entry: BasicEntry, style _: ValueStyle = .detailed) {
        switch entry.key {
        case .BatteryLevel:
            entry.value = String(format: "%d%%", Int(round(batteryLevel * 100.0)))
        case .BatteryUsed:
            entry.value = String(format: "%d%%", Int(round(batteryUsed * 100.0)))
        case .BatteryState:
            entry.value = batteryState.description
        case .BatteryCapacity:
            entry.value = batteryCapacityDescription
        default:
            break
        }
    }

    func usageEntry(key: EntryKey, style: ValueStyle = .detailed) -> UsageEntry<Double>? {
        switch key {
        case .BatteryInformation:
            return UsageEntry(key: .BatteryInformation, name: style == .detailed ? moduleName : NSLocalizedString("BATTERY_LEVEL_FULL", comment: "Battery Level"), items: usageItems)
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
