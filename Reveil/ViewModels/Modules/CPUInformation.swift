//
//  CPUInformation.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import MachO
import SwiftUI

final class CPUInformation: Module {
    static let shared = CPUInformation()

    private init() {
        loadAverage = System.loadAverage()
        cpuUsage = CPUActivity.shared.getSummary()
    }

    let moduleName = NSLocalizedString("CPU_INFORMATION", comment: "CPU Information")

    private let gBufferFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        formatter.allowedUnits = [.useBytes, .useKB, .useMB]
        return formatter
    }()

    private let gLargeNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        return formatter
    }()

    private func cpuMarketingName(code: String) -> String {
        if code == "T6031" {
            return "Apple M3 Max"
        } else if code == "T6030" {
            return "Apple M3 Pro"
        } else if code == "T8122" {
            return "Apple M3"
        } else if code == "T8130" {
            return "Apple A17 Pro"
        } else if code == "T8120" {
            return "Apple A16 Bionic"
        } else if code == "T6022" {
            return "Apple M2 Ultra"
        } else if code == "T6021" {
            return "Apple M2 Max"
        } else if code == "T6020" {
            return "Apple M2 Pro"
        } else if code == "T8112" {
            return "Apple M2"
        } else if code == "T8110" {
            return "Apple A15 Bionic"
        } else if code == "T6002" {
            return "Apple M1 Ultra"
        } else if code == "T6001" {
            return "Apple M1 Max"
        } else if code == "T6000" {
            return "Apple M1 Pro"
        } else if code == "T8103" {
            return "Apple M1"
        } else if code == "T8101" {
            return "Apple A14 Bionic"
        } else if code == "T8030" {
            return "Apple A13 Bionic"
        } else if code == "T8027" {
            return "Apple A12X Bionic"
        } else if code == "T8020" {
            return "Apple A12 Bionic"
        } else if code == "T8015" {
            return "Apple A11 Bionic"
        } else if code == "T8011" {
            return "Apple A10X Fusion"
        } else if code == "T8010" {
            return "Apple A10 Fusion"
        } else if code == "S8000" || code == "S8003" {
            return "Apple A9"
        } else if code == "T7000" {
            return "Apple A8"
        } else if code == "S5L8960" {
            return "Apple A7"
        }
        return glGetString(GLenum(GL_RENDERER))?.withMemoryRebound(to: CChar.self, capacity: 1) {
            ptr in String(validatingUTF8: ptr)
        } ?? BasicEntry.unknownValue
    }

    private func cpuFamilyName(family: UInt32) -> String {
        switch family {
        case UInt32(CPUFAMILY_ARM_SWIFT):
            "Swift"
        case UInt32(CPUFAMILY_ARM_CYCLONE):
            "Cyclone"
        case UInt32(CPUFAMILY_ARM_TYPHOON):
            "Typhoon"
        case UInt32(CPUFAMILY_ARM_TWISTER):
            "Twister"
        case UInt32(CPUFAMILY_ARM_HURRICANE):
            "Hurricane"
        case UInt32(CPUFAMILY_ARM_MONSOON_MISTRAL):
            "Monsoon & Mistral"
        case UInt32(CPUFAMILY_ARM_VORTEX_TEMPEST):
            "Vortex & Tempest"
        case UInt32(CPUFAMILY_ARM_LIGHTNING_THUNDER):
            "Lightning & Thunder"
        case UInt32(CPUFAMILY_ARM_FIRESTORM_ICESTORM):
            "Firestorm & Icestorm"
        case UInt32(CPUFAMILY_ARM_BLIZZARD_AVALANCHE):
            "Blizzard & Avalanche"
        case UInt32(CPUFAMILY_ARM_EVEREST_SAWTOOTH):
            "Everest & Sawtooth"
        case UInt32(CPUFAMILY_ARM_COLL):
            "Coll"
        default:
            BasicEntry.unknownValue
        }
    }

    private var usageItems: [UsageEntry<Double>.Item] {
        [
            UsageEntry.Item(label: "User", value: cpuUsage.user, color: Color.accentColor),
            UsageEntry.Item(label: "Idle", value: cpuUsage.idle, color: Color.clear),
        ]
    }

    lazy var usageEntry: UsageEntry<Double>? = usageEntry(key: .CPUInformation)

    private let archInfo = NXGetLocalArchInfo()

    private var loadAverage: [Double]
    private var cpuUsage: System.CPUUsage

    lazy var basicEntries: [BasicEntry] = {
        reloadData()
        return updatableEntryKeys.compactMap { basicEntry(key: $0) }
    }()

    func reloadData() {
        loadAverage = System.loadAverage()
        cpuUsage = CPUActivity.shared.getSummary()
    }

    func updateEntries() {
        reloadData()
        usageEntry?.items = usageItems
        basicEntries.forEach { updateBasicEntry($0) }
    }

    let updatableEntryKeys: [EntryKey] = [
        .CPUInformation,
        .CPUUsageUser,
        .CPUUsageIdle,
        .CPUUsageLoad,
        .CPUProcessor,
        .CPUArchitecture,
        .CPUFamily,
        .CPUNumberOfCores,
        .CPUByteOrder,
        .CPUCacheLine,
        .CPUL1ICacheSize,
        .CPUL1DCacheSize,
        .CPUL2CacheSize,
        .CPUTBFrequency,
    ]

    func basicEntry(key: EntryKey, style: ValueStyle = .detailed) -> BasicEntry? {
        switch key {
        case .CPUUsageUser:
            return BasicEntry(
                key: .CPUUsageUser,
                name: NSLocalizedString("USAGE_USER", comment: "User"),
                value: String(format: "%.2f%%", cpuUsage.user * 100.0),
                color: Color.accentColor
            )
        case .CPUUsageIdle:
            return BasicEntry(
                key: .CPUUsageIdle,
                name: NSLocalizedString("USAGE_IDLE", comment: "Idle"),
                value: String(format: "%.2f%%", cpuUsage.idle * 100.0),
                color: Color.secondarySystemFillAlias
            )
        case .CPUUsageLoad:
            return BasicEntry(
                key: .CPUUsageLoad,
                name: style == .dashboard ? NSLocalizedString("CPU_USAGE_LOAD", comment: "CPU Load") : NSLocalizedString("USAGE_LOAD", comment: "Load"),
                value: String(format: "%.2f, %.2f, %.2f", loadAverage[0], loadAverage[1], loadAverage[2])
            )
        case .CPUProcessor:
            if let cpuCode = System.uname().version.components(separatedBy: "_").last, cpuCode.hasPrefix("T") {
                return BasicEntry(
                    key: .CPUProcessor,
                    name: NSLocalizedString("PROCESSOR", comment: "Processor"),
                    value: String(format: "%@ (%@)", cpuMarketingName(code: cpuCode), cpuCode)
                )
            }
        case .CPUArchitecture:
            if let archInfo,
               let archRaw = archInfo.pointee.name,
               let archCode = String(cString: archRaw, encoding: .utf8)
            {
                return BasicEntry(
                    key: .CPUArchitecture,
                    name: NSLocalizedString("CPU_ARCHITECTURE", comment: "CPU Architecture"),
                    value: archCode
                )
            }
        case .CPUFamily:
            return BasicEntry(
                key: .CPUFamily,
                name: NSLocalizedString("CPU_FAMILY", comment: "CPU Family"),
                value: cpuFamilyName(family: System.hardwareCPUFamily())
            )
        case .CPUNumberOfCores:
            return BasicEntry(
                key: .CPUNumberOfCores,
                name: style == .dashboard ? NSLocalizedString("NUMBER_OF_CPU_CORES", comment: "Number of CPU Cores") : NSLocalizedString("NUMBER_OF_CORES", comment: "Number of Cores"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: System.physicalCores())) ?? BasicEntry.unknownValue
            )
        case .CPUByteOrder:
            if let archInfo {
                let byteOrder = archInfo.pointee.byteorder
                let byteOrderStr = if byteOrder == NX_LittleEndian {
                    "1234"
                } else {
                    "4321"
                }
                return BasicEntry(
                    key: .CPUByteOrder,
                    name: NSLocalizedString("BYTE_ORDER", comment: "Byte Order"),
                    value: byteOrderStr
                )
            }
        case .CPUCacheLine:
            return BasicEntry(
                key: .CPUCacheLine,
                name: NSLocalizedString("CACHE_LINE", comment: "Cache Line"),
                value: gBufferFormatter.string(fromByteCount: Int64(System.hardwareCacheLineSize()))
            )
        case .CPUL1ICacheSize:
            return BasicEntry(
                key: .CPUL1ICacheSize,
                name: NSLocalizedString("L1_INST_CACHE_SIZE", comment: "L1 Instruction Cache Size"),
                value: gBufferFormatter.string(fromByteCount: Int64(System.hardwareLevel1InstructionCacheSize()))
            )
        case .CPUL1DCacheSize:
            return BasicEntry(
                key: .CPUL1DCacheSize,
                name: NSLocalizedString("L1_DATA_CACHE_SIZE", comment: "L1 Data Cache Size"),
                value: gBufferFormatter.string(fromByteCount: Int64(System.hardwareLevel1DataCacheSize()))
            )
        case .CPUL2CacheSize:
            return BasicEntry(
                key: .CPUL2CacheSize,
                name: NSLocalizedString("L2_CACHE_SIZE", comment: "L2 Cache Size"),
                value: gBufferFormatter.string(fromByteCount: Int64(System.hardwareLevel2CacheSize()))
            )
        case .CPUTBFrequency:
            return BasicEntry(
                key: .CPUTBFrequency,
                name: NSLocalizedString("TB_FREQ", comment: "TB Frequency"),
                value: String(format: "%.2f MHz", Double(System.hardwareTBFrequency()) / 1e6)
            )
        default:
            break
        }
        return nil
    }

    func updateBasicEntry(_ entry: BasicEntry, style _: ValueStyle = .detailed) {
        switch entry.key {
        case .CPUUsageUser:
            entry.value = String(format: "%.2f%%", cpuUsage.user * 100.0)
        case .CPUUsageIdle:
            entry.value = String(format: "%.2f%%", cpuUsage.idle * 100.0)
        case .CPUUsageLoad:
            entry.value = String(format: "%.2f, %.2f, %.2f", loadAverage[0], loadAverage[1], loadAverage[2])
        default:
            break
        }
    }

    func usageEntry(key: EntryKey, style _: ValueStyle = .detailed) -> UsageEntry<Double>? {
        switch key {
        case .CPUInformation:
            return UsageEntry(key: .CPUInformation, name: moduleName, items: usageItems)
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
