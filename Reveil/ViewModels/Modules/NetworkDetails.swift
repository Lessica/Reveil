//
//  NetworkDetails.swift
//  Reveil
//
//  Created by Lessica on 2023/10/12.
//

import Foundation

final class NetworkDetails: Module {
    static let shared = NetworkDetails()

    private var netStats: NetworkStatistics
    private let netTraffic = NetworkTraffic()

    private init() {
        netStats = netTraffic.getStatistics()
    }

    let moduleName = NSLocalizedString("NETWORK_DETAILS", comment: "Network Details")

    private let gBufferFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        formatter.allowedUnits = [.useAll]
        return formatter
    }()

    private lazy var trafficEntryMappings: [NetworkPrefix: TrafficEntryIO] = {
        let groupCases = NetworkPrefix.categoryCases.compactMap { pfx -> (NetworkPrefix, TrafficEntryIO)? in
            guard let io = trafficEntryIO(key: .NetworkCategoryUsage(prefix: pfx.rawValue), style: .detailed)
            else {
                return nil
            }
            return (pfx, io)
        }
        return Dictionary(groupCases, uniquingKeysWith: { _, new in new })
    }()

    func trafficEntries(prefix: NetworkPrefix) -> [TrafficEntry<Int64>] {
        guard let trafficEntryIO = trafficEntryMappings[prefix] else {
            return []
        }
        return trafficEntryIO.pair
    }

    private lazy var totalEntryMappings: [NetworkPrefix: BasicEntryIO] = {
        let groupCases = NetworkPrefix.categoryCases.compactMap { pfx -> (NetworkPrefix, BasicEntryIO)? in
            guard let downloadEntry = basicEntry(key: .NetworkCategoryBytesDownload(prefix: pfx.rawValue)),
                  let uploadEntry = basicEntry(key: .NetworkCategoryBytesUpload(prefix: pfx.rawValue))
            else {
                return nil
            }
            return (pfx, BasicEntryIO(download: downloadEntry, upload: uploadEntry))
        }
        return Dictionary(groupCases, uniquingKeysWith: { _, new in new })
    }()

    func entries(prefix: NetworkPrefix) -> [BasicEntry] {
        guard let basicEntryIO = totalEntryMappings[prefix] else {
            return []
        }
        return basicEntryIO.pair
    }

    var basicEntries: [BasicEntry] {
        reloadData()
        return totalEntryMappings.flatMap(\.value.pair)
    }

    var trafficEntries: [TrafficEntry<Int64>]? { trafficEntryMappings.flatMap(\.value.pair) }
    let usageEntry: UsageEntry<Double>? = nil

    func reloadData() {
        netStats = netTraffic.getStatistics()
    }

    func update(prefix: NetworkPrefix) {
        guard let trafficEntryIO = trafficEntryMappings[prefix],
              let basicEntryIO = totalEntryMappings[prefix]
        else {
            return
        }

        reloadData()
        updateTrafficEntryIO(trafficEntryIO, style: .detailed)

        basicEntryIO.pair.forEach { updateBasicEntry($0) }
    }

    func updateEntries() {
        NetworkPrefix.categoryCases.forEach { update(prefix: $0) }
    }

    lazy var updatableEntryKeys: [EntryKey] = [.NetworkUsage] +
        NetworkPrefix.categoryCases.flatMap { [
            .NetworkCategoryBytesDownload(prefix: $0.rawValue),
            .NetworkCategoryBytesUpload(prefix: $0.rawValue),
            .NetworkCategoryUsage(prefix: $0.rawValue),
        ] }

    func basicEntry(key: EntryKey, style: ValueStyle = .detailed) -> BasicEntry? {
        switch key {
        case let .NetworkCategoryBytesDownload(prefix):
            if let pfx = NetworkPrefix(rawValue: prefix) {
                let downloadBytes: Int64
                if let cachedDownloadBytes = netStats.receivedBytes(prefix: pfx) {
                    downloadBytes = cachedDownloadBytes
                } else {
                    downloadBytes = 0
                }
                return BasicEntry(
                    key: key,
                    name: style == .dashboard ? String(format: NSLocalizedString("TOTAL_DOWNLOAD_OF_INTERFACE", comment: "Total Download of %@"), pfx.description) : NSLocalizedString("TOTAL_DOWNLOAD", comment: "Total Download"),
                    value: gBufferFormatter.string(fromByteCount: downloadBytes)
                )
            }
        case let .NetworkCategoryBytesUpload(prefix):
            if let pfx = NetworkPrefix(rawValue: prefix) {
                let uploadBytes: Int64
                if let cachedUploadBytes = netStats.sentBytes(prefix: pfx) {
                    uploadBytes = cachedUploadBytes
                } else {
                    uploadBytes = 0
                }
                return BasicEntry(
                    key: key,
                    name: style == .dashboard ? String(format: NSLocalizedString("TOTAL_UPLOAD_OF_INTERFACE", comment: "Total Upload of %@"), pfx.description) : NSLocalizedString("TOTAL_UPLOAD", comment: "Total Upload"),
                    value: gBufferFormatter.string(fromByteCount: uploadBytes)
                )
            }
        default:
            break
        }
        return nil
    }

    func updateBasicEntry(_ entry: BasicEntry, style _: ValueStyle = .detailed) {
        switch entry.key {
        case let .NetworkCategoryBytesDownload(prefix):
            if let pfx = NetworkPrefix(rawValue: prefix),
               let downloadBytes = netStats.receivedBytes(prefix: pfx)
            {
                entry.value = gBufferFormatter.string(fromByteCount: downloadBytes)
            }
        case let .NetworkCategoryBytesUpload(prefix):
            if let pfx = NetworkPrefix(rawValue: prefix),
               let uploadBytes = netStats.sentBytes(prefix: pfx)
            {
                entry.value = gBufferFormatter.string(fromByteCount: uploadBytes)
            }
        default:
            break
        }
    }

    func usageEntry(key _: EntryKey, style _: ValueStyle = .detailed) -> UsageEntry<Double>? { nil }

    func updateUsageEntry(_: UsageEntry<Double>, style _: ValueStyle) {}

    func trafficEntryIO(key: EntryKey, style: ValueStyle) -> TrafficEntryIO? {
        switch key {
        case .NetworkUsage:
            return trafficEntryIO(key: .NetworkCategoryUsage(prefix: NetworkPrefix.all.rawValue), style: style)
        case let .NetworkCategoryUsage(prefix):
            if let pfx = NetworkPrefix(rawValue: prefix) {
                let netIO: NetworkIO
                if let cachedIO = netStats.io(prefix: pfx) {
                    netIO = cachedIO
                } else {
                    netIO = NetworkIO(received: 0, sent: 0)
                }
                return TrafficEntryIO(
                    child: BasicEntry(
                        key: pfx == .all ? .NetworkUsage : key,
                        name: pfx == .all
                            ? NSLocalizedString("NETWORK_USAGE", comment: "Network Usage")
                            : (style == .dashboard
                                ? String(format: NSLocalizedString("NETWORK_USAGE_OF", comment: "%@ Usage"), pfx.description)
                                : pfx.description)
                    ),
                    download: TrafficEntry(
                        child: BasicEntry(
                            key: .Custom(name: "Download"),
                            name: NSLocalizedString("DOWNLOAD", comment: "Download"),
                            value: String(format: "%@\n%@", String(
                                format: NSLocalizedString("LINE_SPEED_FMT", comment: "%@/s"),
                                gBufferFormatter.string(fromByteCount: 0)
                            ), gBufferFormatter.string(fromByteCount: netIO.received))
                        )
                    ),
                    upload: TrafficEntry(
                        child: BasicEntry(
                            key: .Custom(name: "Upload"),
                            name: NSLocalizedString("UPLOAD", comment: "Upload"),
                            value: String(format: "%@\n%@", String(
                                format: NSLocalizedString("LINE_SPEED_FMT", comment: "%@/s"),
                                gBufferFormatter.string(fromByteCount: 0)
                            ), gBufferFormatter.string(fromByteCount: netIO.sent))
                        )
                    )
                )
            }
        default:
            break
        }
        return nil
    }

    func updateTrafficEntryIO(_ entry: TrafficEntryIO, style _: ValueStyle) {
        var netPrefix: NetworkPrefix?
        switch entry.key {
        case .NetworkUsage:
            netPrefix = .all
        case let .NetworkCategoryUsage(prefix):
            if let pfx = NetworkPrefix(rawValue: prefix) {
                netPrefix = pfx
            }
        default:
            break
        }
        if let netPrefix, let netIO = netStats.io(prefix: netPrefix) {
            if netIO.receivedDelta == Int64.max {
                entry.download.invalidate()
            } else {
                entry.download.push(value: netIO.receivedDelta)
                if let basicChild = entry.download.basicChild {
                    basicChild.value = String(format: "%@\n%@", String(
                        format: NSLocalizedString("LINE_SPEED_FMT", comment: "%@/s"),
                        gBufferFormatter.string(fromByteCount: netIO.receivedDelta)
                    ), gBufferFormatter.string(fromByteCount: netIO.received))
                }
            }
            if netIO.sentDelta == Int64.max {
                entry.upload.invalidate()
            } else {
                entry.upload.push(value: netIO.sentDelta)
                if let basicChild = entry.upload.basicChild {
                    basicChild.value = String(format: "%@\n%@", String(
                        format: NSLocalizedString("LINE_SPEED_FMT", comment: "%@/s"),
                        gBufferFormatter.string(fromByteCount: netIO.sentDelta)
                    ), gBufferFormatter.string(fromByteCount: netIO.sent))
                }
            }
        }
    }
}
