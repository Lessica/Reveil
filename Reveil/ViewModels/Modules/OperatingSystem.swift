//
//  OperatingSystem.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import Foundation
#if canImport(WebKit)
import WebKit
#endif

final class OperatingSystem: Module {
    static let shared = OperatingSystem()
    private init() {}

    let moduleName = NSLocalizedString("OPERATING_SYSTEM", comment: "Operating System")

    private let gSystemVersionString: String? = {
        let path = "/System/Library/CoreServices/SystemVersion.plist"
        let url = URL(fileURLWithPath: path, isDirectory: false)
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        guard let dictionary = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let productVersion = dictionary["ProductVersion"] as? String,
              let productBuildVersion = dictionary["ProductBuildVersion"] as? String
        else {
            return nil
        }
        return "Version \(productVersion) (Build \(productBuildVersion))"
    }()

    private let gUserAgentString: String? = {
        #if canImport(WebKit)
        let userAgent = WKWebView().value(forKey: "userAgent") as? String
        return userAgent
        #else
        return nil
        #endif
    }()

    private let gBufferFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        formatter.allowedUnits = [.useKB, .useMB]
        return formatter
    }()

    private let gLargeNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        return formatter
    }()

    private let gDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()

    private func getUptimeString() -> String {
        var uptimeStr: String
        let uptimeInfo = System.uptime()
        if uptimeInfo.days > 0 {
            uptimeStr = "\(uptimeInfo.days)d \(uptimeInfo.hrs)h \(uptimeInfo.mins)m \(uptimeInfo.secs)s"
        } else if uptimeInfo.hrs > 0 {
            uptimeStr = "\(uptimeInfo.hrs)h \(uptimeInfo.mins)m \(uptimeInfo.secs)s"
        } else if uptimeInfo.mins > 0 {
            uptimeStr = "\(uptimeInfo.mins)m \(uptimeInfo.secs)s"
        } else {
            uptimeStr = "\(uptimeInfo.secs)s"
        }
        return uptimeStr
    }

    private func getUptimeAtString() -> String {
        let uptimeStamp = TimeInterval(System.uptime().absolute)
        let uptimeObj = Date(timeIntervalSince1970: uptimeStamp)
        return gDateFormatter.string(from: uptimeObj)
    }

    private let unameStruct = System.uname()

    lazy var basicEntries: [BasicEntry] = updatableEntryKeys.compactMap { basicEntry(key: $0) }

    let trafficEntries: [TrafficEntry<Int64>]? = nil
    let usageEntry: UsageEntry<Double>? = nil

    func reloadData() {}

    func updateEntries() {
        basicEntries.forEach { updateBasicEntry($0) }
    }

    let updatableEntryKeys: [EntryKey] = [
        .System,
        .UserAgent,
        .KernelVersion,
        .KernelRelease,
        .KernelMaximumVnodes,
        .KernelMaximumGroups,
        .OSMaxSocketBufferSize,
        .OSMaxFilesPerProcess,
        .KernelMaximumProcesses,
        .HostID,
        .Uptime,
        .UptimeAt,
    ]

    func basicEntry(key: EntryKey, style _: ValueStyle = .detailed) -> BasicEntry? {
        switch key {
        case .System:
            return BasicEntry(
                key: .System,
                name: NSLocalizedString("SYSTEM", comment: "System"),
                value: gSystemVersionString ?? BasicEntry.unknownValue
            )
        case .UserAgent:
            return BasicEntry(
                key: .UserAgent,
                name: NSLocalizedString("USER_AGENT", comment: "User Agent"),
                value: gUserAgentString ?? BasicEntry.unknownValue
            )
        case .KernelVersion:
            return BasicEntry(
                key: .KernelVersion,
                name: NSLocalizedString("KERNEL_VERSION", comment: "Kernel Version"),
                value: unameStruct.version
            )
        case .KernelRelease:
            return BasicEntry(
                key: .KernelRelease,
                name: NSLocalizedString("KERNEL_RELEASE", comment: "Kernel Release"),
                value: unameStruct.release
            )
        case .KernelMaximumVnodes:
            return BasicEntry(
                key: .KernelMaximumVnodes,
                name: NSLocalizedString("KERNEL_MAXIMUM_VNODES", comment: "Kernel Maximum Vnodes"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: Int64(System.kernelMaximumVnodes()))) ?? BasicEntry.unknownValue
            )
        case .KernelMaximumGroups:
            return BasicEntry(
                key: .KernelMaximumGroups,
                name: NSLocalizedString("KERNEL_MAXIMUM_GROUPS", comment: "Kernel Maximum Groups"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: Int64(NGROUPS_MAX))) ?? BasicEntry.unknownValue
            )
        case .OSMaxSocketBufferSize:
            return BasicEntry(
                key: .OSMaxSocketBufferSize,
                name: NSLocalizedString("MAX_SOCKET_BUFFER_SIZE", comment: "Max Socket Buffer Size"),
                value: gBufferFormatter.string(fromByteCount: Int64(System.kernelMaximumSocketBufferSize()))
            )
        case .OSMaxFilesPerProcess:
            return BasicEntry(
                key: .OSMaxFilesPerProcess,
                name: NSLocalizedString("MAX_FILES_PER_PROCESS", comment: "Max Files per Process"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: Int64(System.kernelMaximumFilesPerProc()))) ?? BasicEntry.unknownValue
            )
        case .KernelMaximumProcesses:
            return BasicEntry(
                key: .KernelMaximumProcesses,
                name: NSLocalizedString("KERNEL_MAXIMUM_PROCESSES", comment: "Kernel Maximum Processes"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: Int64(System.kernelMaximumProcesses()))) ?? BasicEntry.unknownValue
            )
        case .HostID:
            return BasicEntry(
                key: .HostID,
                name: NSLocalizedString("HOST_ID", comment: "Host ID"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: Int64(System.kernelHostID()))) ?? BasicEntry.unknownValue
            )
        case .Uptime:
            return BasicEntry(
                key: .Uptime,
                name: NSLocalizedString("UPTIME", comment: "Uptime"),
                value: getUptimeString()
            )
        case .UptimeAt:
            return BasicEntry(
                key: .UptimeAt,
                name: NSLocalizedString("UPTIME_AT", comment: "Launched At"),
                value: getUptimeAtString()
            )
        default:
            break
        }
        return nil
    }

    func updateBasicEntry(_ entry: BasicEntry, style _: ValueStyle = .detailed) {
        switch entry.key {
        case .Uptime:
            entry.value = getUptimeString()
        default:
            break
        }
    }

    func usageEntry(key _: EntryKey, style _: ValueStyle = .detailed) -> UsageEntry<Double>? { nil }

    func updateUsageEntry(_: UsageEntry<Double>, style _: ValueStyle) {}

    func trafficEntryIO(key _: EntryKey, style _: ValueStyle) -> TrafficEntryIO? { nil }

    func updateTrafficEntryIO(_: TrafficEntryIO, style _: ValueStyle) {}
}
