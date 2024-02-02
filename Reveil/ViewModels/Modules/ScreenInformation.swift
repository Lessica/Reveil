//
//  ScreenInformation.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import UIKit

final class ScreenInformation: Module {
    static let shared = ScreenInformation()
    private init() {}

    let moduleName = NSLocalizedString("SCREEN_INFORMATION", comment: "Screen Information")

    private let mainScreen = UIScreen.main

    private lazy var displaySizeDescription: String = {
        let displayWidth = Int(mainScreen.fixedCoordinateSpace.bounds.width * mainScreen.scale)
        let displayHeight = Int(mainScreen.fixedCoordinateSpace.bounds.height * mainScreen.scale)
        return "\(displayWidth)×\(displayHeight)"
    }()

    private lazy var physicalSizeDescription: String = {
        let physicalWidth = Int(mainScreen.nativeBounds.width)
        let physicalHeight = Int(mainScreen.nativeBounds.height)
        return "\(physicalWidth)×\(physicalHeight)"
    }()

    private lazy var logicalSizeDescription: String = {
        let logicalWidth = Int(mainScreen.fixedCoordinateSpace.bounds.width)
        let logicalHeight = Int(mainScreen.fixedCoordinateSpace.bounds.height)
        return "\(logicalWidth)×\(logicalHeight)"
    }()

    lazy var basicEntries: [BasicEntry] = updatableEntryKeys.compactMap { basicEntry(key: $0) }

    let usageEntry: UsageEntry<Double>? = nil

    func reloadData() {}

    func updateEntries() {
        basicEntries.forEach { updateBasicEntry($0) }
    }

    let updatableEntryKeys: [EntryKey] = [
        .DisplayResolution,
        .ScreenPhysicalResolution,
        .ScreenPhysicalScale,
        .ScreenLogicalResolution,
        .ScreenLogicalScale,
        .ScreenMaximumFramesPerSecond,
    ]

    func basicEntry(key: EntryKey, style: ValueStyle = .detailed) -> BasicEntry? {
        switch key {
        case .DisplayResolution:
            return BasicEntry(
                key: .DisplayResolution,
                name: NSLocalizedString("DISPLAY_RESOLUTION", comment: "Display Resolution"),
                value: displaySizeDescription
            )
        case .ScreenPhysicalResolution:
            return BasicEntry(
                key: .ScreenPhysicalResolution,
                name: style == .dashboard ? NSLocalizedString("SCREEN_PHYSICAL_RESOLUTION", comment: "Screen Physical Resolution") : NSLocalizedString("PHYSICAL_RESOLUTION", comment: "Physical Resolution"),
                value: physicalSizeDescription
            )
        case .ScreenPhysicalScale:
            return BasicEntry(
                key: .ScreenPhysicalScale,
                name: style == .dashboard ? NSLocalizedString("SCREEN_PHYSICAL_SCALE", comment: "Screen Physical Scale") : NSLocalizedString("PHYSICAL_SCALE", comment: "Physical Scale"),
                value: String(format: "%.3f", mainScreen.nativeScale)
            )
        case .ScreenLogicalResolution:
            return BasicEntry(
                key: .ScreenLogicalResolution,
                name: style == .dashboard ? NSLocalizedString("SCREEN_LOGICAL_RESOLUTION", comment: "Screen Logical Resolution") : NSLocalizedString("LOGICAL_RESOLUTION", comment: "Logical Resolution"),
                value: logicalSizeDescription
            )
        case .ScreenLogicalScale:
            return BasicEntry(
                key: .ScreenLogicalScale,
                name: style == .dashboard ? NSLocalizedString("SCREEN_LOGICAL_SCALE", comment: "Screen Logical Scale") : NSLocalizedString("LOGICAL_SCALE", comment: "Logical Scale"),
                value: String(format: "%.3f", mainScreen.scale)
            )
        case .ScreenMaximumFramesPerSecond:
            return BasicEntry(
                key: .ScreenMaximumFramesPerSecond,
                name: style == .dashboard ? NSLocalizedString("SCREEN_MAXIMUM_FPS", comment: "Screen Maximum FPS") : NSLocalizedString("MAXIMUM_FPS", comment: "Maximum FPS"),
                value: String(format: "%d", mainScreen.maximumFramesPerSecond)
            )
        default:
            break
        }
        return nil
    }

    func updateBasicEntry(_ basicEntry: BasicEntry, style _: ValueStyle = .detailed) {
        switch basicEntry.key {
        case .HostName:
            basicEntry.value = System.hostName() ?? BasicEntry.unknownValue
        default:
            break
        }
    }

    func usageEntry(key _: EntryKey, style _: ValueStyle = .detailed) -> UsageEntry<Double>? { nil }

    func updateUsageEntry(_: UsageEntry<Double>, style _: ValueStyle) {}

    func trafficEntryIO(key _: EntryKey, style _: ValueStyle) -> TrafficEntryIO? { nil }

    func updateTrafficEntryIO(_: TrafficEntryIO, style _: ValueStyle) {}
}
