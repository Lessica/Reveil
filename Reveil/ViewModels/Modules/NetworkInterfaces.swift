//
//  NetworkInterfaces.swift
//  Reveil
//
//  Created by Lessica on 2023/10/6.
//

import Foundation

final class NetworkInterfaces: Module {
    static let shared = NetworkInterfaces()

    private init() {
        items = []
        reloadData()
    }

    let moduleName = NSLocalizedString("NETWORK_INTERFACES", comment: "Network Interfaces")

    private let gLargeNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        return formatter
    }()

    private let gBufferFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .memory
        formatter.allowedUnits = [.useAll]
        return formatter
    }()

    private let gTimeIntervalFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        return formatter
    }()

    private let gDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()

    private lazy var prefixIndexes: [NetworkPrefix: Int] = Dictionary(NetworkPrefix.allCases.map { ($0, 0) }) { _, new in new }

    private func clearPrefixIndexes() {
        prefixIndexes.keys.forEach { prefixIndexes.updateValue(0, forKey: $0) }
    }

    private func aliasByPrefix(_ name: String) -> String {
        var prefix = NetworkPrefix(rawValue: name)
        if prefix == nil {
            prefix = NetworkPrefix.others
        }
        guard let prefix,
              let index = prefixIndexes[prefix]
        else {
            return BasicEntry.unknownValue
        }
        prefixIndexes[prefix]? += 1
        return String(format: "%@ #%d", prefix.description, index + 1)
    }

    var items: [NetworkInterface]

    func reloadData() {
        clearPrefixIndexes()
        items = System.interfaceAddresses()
            .sorted(by: { $0.ifa_name.localizedStandardCompare($1.ifa_name) == .orderedAscending })
            .filter { $0.ifa_addr?.family == AF_LINK }
            .map { NetworkInterface(
                name: $0.ifa_name,
                alias: aliasByPrefix($0.ifa_name),
                rawValue: $0
            ) }
            .sorted(by: { $0.alias.localizedStandardCompare($1.alias) == .orderedAscending })
    }

    private struct Address {
        let address: SocketAddress
        let netmask: SocketAddress?
    }

    private func attributeDescriptions(_ flags: UInt32) -> [BasicEntry] {
        var descs = [NetworkInterface.Attribute]()
        if (flags & UInt32(IFF_UP)) != 0 {
            descs.append(NetworkInterface.Attribute(name: "IFF_UP", description: NSLocalizedString("IFF_UP", comment: "Interface is up")))
        }
        if (flags & UInt32(IFF_BROADCAST)) != 0 {
            descs.append(NetworkInterface.Attribute(name: "IFF_BROADCAST", description: NSLocalizedString("IFF_BROADCAST", comment: "Broadcast address valid")))
        }
        if (flags & UInt32(IFF_DEBUG)) != 0 {
            descs.append(NetworkInterface.Attribute(name: "IFF_DEBUG", description: NSLocalizedString("IFF_DEBUG", comment: "Turn on debugging")))
        }
        if (flags & UInt32(IFF_LOOPBACK)) != 0 {
            descs.append(NetworkInterface.Attribute(name: "IFF_LOOPBACK", description: NSLocalizedString("IFF_LOOPBACK", comment: "Is a loopback net")))
        }
        if (flags & UInt32(IFF_POINTOPOINT)) != 0 {
            descs.append(NetworkInterface.Attribute(name: "IFF_POINTOPOINT", description: NSLocalizedString("IFF_POINTOPOINT", comment: "Interface is point-to-point link")))
        }
        if (flags & UInt32(IFF_NOTRAILERS)) != 0 {
            descs.append(NetworkInterface.Attribute(name: "IFF_NOTRAILERS", description: NSLocalizedString("IFF_NOTRAILERS", comment: "Obsolete: avoid use of trailers")))
        }
        if (flags & UInt32(IFF_RUNNING)) != 0 {
            descs.append(NetworkInterface.Attribute(name: "IFF_RUNNING", description: NSLocalizedString("IFF_RUNNING", comment: "Resources allocated")))
        }
        if (flags & UInt32(IFF_NOARP)) != 0 {
            descs.append(NetworkInterface.Attribute(name: "IFF_NOARP", description: NSLocalizedString("IFF_NOARP", comment: "No address resolution protocol")))
        }
        if (flags & UInt32(IFF_PROMISC)) != 0 {
            descs.append(NetworkInterface.Attribute(name: "IFF_PROMISC", description: NSLocalizedString("IFF_PROMISC", comment: "Receive all packets")))
        }
        if (flags & UInt32(IFF_ALLMULTI)) != 0 {
            descs.append(NetworkInterface.Attribute(name: "IFF_ALLMULTI", description: NSLocalizedString("IFF_ALLMULTI", comment: "Receive all multicast packets")))
        }
        if (flags & UInt32(IFF_OACTIVE)) != 0 {
            descs.append(NetworkInterface.Attribute(name: "IFF_OACTIVE", description: NSLocalizedString("IFF_OACTIVE", comment: "Transmission in progress")))
        }
        if (flags & UInt32(IFF_SIMPLEX)) != 0 {
            descs.append(NetworkInterface.Attribute(name: "IFF_SIMPLEX", description: NSLocalizedString("IFF_SIMPLEX", comment: "Can't hear own transmissions")))
        }
        if (flags & UInt32(IFF_ALTPHYS)) != 0 {
            descs.append(NetworkInterface.Attribute(name: "IFF_ALTPHYS", description: NSLocalizedString("IFF_ALTPHYS", comment: "Use alternate physical connection")))
        }
        if (flags & UInt32(IFF_MULTICAST)) != 0 {
            descs.append(NetworkInterface.Attribute(name: "IFF_MULTICAST", description: NSLocalizedString("IFF_MULTICAST", comment: "Supports multicast")))
        }
        if (flags & UInt32(IFF_LINK0)) != 0 {
            descs.append(NetworkInterface.Attribute(name: "IFF_LINK0", description: NSLocalizedString("IFF_LINK0", comment: "Per link layer defined bit 0")))
        }
        if (flags & UInt32(IFF_LINK1)) != 0 {
            descs.append(NetworkInterface.Attribute(name: "IFF_LINK1", description: NSLocalizedString("IFF_LINK1", comment: "Per link layer defined bit 1")))
        }
        if (flags & UInt32(IFF_LINK2)) != 0 {
            descs.append(NetworkInterface.Attribute(name: "IFF_LINK2", description: NSLocalizedString("IFF_LINK2", comment: "Per link layer defined bit 2")))
        }
        return descs.map { BasicEntry(key: .Custom(name: $0.name), name: $0.description, value: String()) }
    }

    func entries(interface: NetworkInterface) -> [BasicEntry] {
        var items = [BasicEntry]()

        items.append(BasicEntry(
            key: .InterfaceName(name: interface.name),
            name: NSLocalizedString("INTERFACE_NAME", comment: "Interface Name"),
            value: interface.name
        ))

        switch interface.rawValue.ifa_addr {
        case let .Link(address, _):
            if !address.isEmpty {
                items.append(BasicEntry(
                    key: .InterfaceMacAddress(name: interface.name),
                    name: NSLocalizedString("MAC_ADDRESS_IDX", comment: "MAC Address"),
                    value: address
                ))
            }
        default:
            break
        }

        let inetAddrs = System.interfaceAddresses(name: interface.name)
        let addresses = inetAddrs
            .compactMap { inetAddr -> Address? in
                guard let saAddr = inetAddr.ifa_addr else {
                    return nil
                }
                guard saAddr.family == AF_INET || saAddr.family == AF_INET6 else {
                    return nil
                }
                return Address(address: saAddr, netmask: inetAddr.ifa_netmask)
            }
        if !addresses.isEmpty {
            let validAddresses = addresses.enumerated().sorted(by: { addr1, addr2 -> Bool in
                switch (addr1.element.address.family, addr2.element.address.family) {
                case (AF_INET, AF_INET):
                    fallthrough
                case (AF_INET6, AF_INET6):
                    if let host1 = addr1.element.address.host, let host2 = addr2.element.address.host {
                        return host1.stringValue.localizedStandardCompare(host2.stringValue) == .orderedAscending
                    }
                    fallthrough
                case (AF_INET, AF_INET6):
                    return true
                case (AF_INET6, AF_INET):
                    return false
                default:
                    break
                }
                return addr1.offset < addr2.offset
            }).map(\.element).enumerated().flatMap { addr in
                var entries = [BasicEntry](arrayLiteral: BasicEntry(
                    sectionName: String(format: NSLocalizedString("PROTOCOL_IDX", comment: "Protocol #%d - %@"),
                                        addr.offset + 1, addr.element.address.family == AF_INET ? "IPv4" : "IPv6")
                ))
                if let address = addr.element.address.host {
                    entries.append(BasicEntry(
                        key: .NetworkAddress(name: interface.name, index: addr.offset + 1),
                        name: NSLocalizedString("ADDRESS", comment: "Address"),
                        value: address.stringValue
                    ))
                }
                if addr.element.address.family == AF_INET,
                   let netmask = addr.element.netmask?.host,
                   let broadcastAddr = addr.element.address.host?.broadcastAddress(netmask: netmask)
                {
                    entries.append(BasicEntry(
                        key: .NetworkBroadcastAddress(name: interface.name, index: addr.offset + 1),
                        name: NSLocalizedString("BROADCAST", comment: "Broadcast"),
                        value: broadcastAddr.stringValue
                    ))
                }
                if let netmask = addr.element.netmask?.host {
                    entries.append(BasicEntry(
                        key: .NetworkMaskAddress(name: interface.name, index: addr.offset + 1),
                        name: NSLocalizedString("NETMASK", comment: "Netmask"),
                        value: netmask.stringValue
                    ))
                }
                return entries
            }
            if !validAddresses.isEmpty {
                items.append(BasicEntry(
                    key: .NetworkAddressCount(name: interface.name),
                    name: String(format: NSLocalizedString("ADDRESSES_COUNT", comment: "%d Addresses"), addresses.count),
                    value: String(),
                    children: validAddresses
                ))
            }
        }

        let ifaFlags = interface.rawValue.ifa_flags
        let flagEntries = attributeDescriptions(ifaFlags)
        if !flagEntries.isEmpty {
            items.append(BasicEntry(
                key: .InterfaceFlags(name: interface.name),
                name: NSLocalizedString("FLAGS", comment: "Flags"),
                value: String(),
                children: flagEntries
            ))
        }

        if let ifiData = interface.rawValue.ifa_data {
            items.append(BasicEntry(
                key: .InterfaceMTU(name: interface.name),
                name: NSLocalizedString("MTU", comment: "MTU"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: Int64(ifiData.ifi_mtu))) ?? BasicEntry.unknownValue
            ))

            items.append(BasicEntry(
                key: .InterfaceMetric(name: interface.name),
                name: NSLocalizedString("METRIC", comment: "Metric"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: Int64(ifiData.ifi_metric))) ?? BasicEntry.unknownValue
            ))

            items.append(BasicEntry(
                key: .InterfaceLineSpeed(name: interface.name),
                name: NSLocalizedString("LINE_SPEED", comment: "Line Speed"),
                value: String(format: NSLocalizedString("LINE_SPEED_FMT", comment: "%@/s"),
                              gBufferFormatter.string(fromByteCount: Int64(ifiData.ifi_baudrate)))
            ))

            items.append(BasicEntry(
                key: .InterfacePacketsReceived(name: interface.name),
                name: NSLocalizedString("PACKETS_RECEIVED", comment: "Packets Received"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: Int64(ifiData.ifi_ipackets))) ?? BasicEntry.unknownValue
            ))

            items.append(BasicEntry(
                key: .InterfaceInputErrors(name: interface.name),
                name: NSLocalizedString("INPUT_ERRORS", comment: "Input Errors"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: Int64(ifiData.ifi_ierrors))) ?? BasicEntry.unknownValue
            ))

            items.append(BasicEntry(
                key: .InterfacePacketsSent(name: interface.name),
                name: NSLocalizedString("PACKETS_SENT", comment: "Packets Sent"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: Int64(ifiData.ifi_opackets))) ?? BasicEntry.unknownValue
            ))

            items.append(BasicEntry(
                key: .InterfaceOutputErrors(name: interface.name),
                name: NSLocalizedString("OUTPUT_ERRORS", comment: "Output Errors"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: Int64(ifiData.ifi_oerrors))) ?? BasicEntry.unknownValue
            ))

            items.append(BasicEntry(
                key: .InterfaceCollisions(name: interface.name),
                name: NSLocalizedString("COLLISIONS", comment: "Collisions"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: Int64(ifiData.ifi_collisions))) ?? BasicEntry.unknownValue
            ))

            items.append(BasicEntry(
                key: .InterfaceBytesReceived(name: interface.name),
                name: NSLocalizedString("RECEIVED", comment: "Received"),
                value: gBufferFormatter.string(fromByteCount: Int64(ifiData.ifi_ibytes))
            ))

            items.append(BasicEntry(
                key: .InterfaceBytesSent(name: interface.name),
                name: NSLocalizedString("SENT", comment: "Sent"),
                value: gBufferFormatter.string(fromByteCount: Int64(ifiData.ifi_obytes))
            ))

            items.append(BasicEntry(
                key: .InterfaceMulticastPacketsReceived(name: interface.name),
                name: NSLocalizedString("MULTICAST_RECEIVED", comment: "Multicast Received"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: Int64(ifiData.ifi_imcasts))) ?? BasicEntry.unknownValue
            ))

            items.append(BasicEntry(
                key: .InterfaceMulticastPacketsSent(name: interface.name),
                name: NSLocalizedString("MULTICAST_SENT", comment: "Multicast Sent"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: Int64(ifiData.ifi_omcasts))) ?? BasicEntry.unknownValue
            ))

            items.append(BasicEntry(
                key: .InterfacePacketsDropped(name: interface.name),
                name: NSLocalizedString("DROPPED", comment: "Dropped"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: Int64(ifiData.ifi_iqdrops))) ?? BasicEntry.unknownValue
            ))

            items.append(BasicEntry(
                key: .InterfacePacketsUnsupported(name: interface.name),
                name: NSLocalizedString("UNSUPPORTED", comment: "Unsupported"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: Int64(ifiData.ifi_noproto))) ?? BasicEntry.unknownValue
            ))

            items.append(BasicEntry(
                key: .InterfaceSpentReceiving(name: interface.name),
                name: NSLocalizedString("SPENT_RECEIVING", comment: "Spent Receiving"),
                value: gTimeIntervalFormatter.string(from: TimeInterval(ifiData.ifi_recvtiming) / TimeInterval(USEC_PER_SEC)) ?? BasicEntry.unknownValue
            ))

            items.append(BasicEntry(
                key: .InterfaceSpentXmitting(name: interface.name),
                name: NSLocalizedString("SPENT_XMITTING", comment: "Spent Xmitting"),
                value: gTimeIntervalFormatter.string(from: TimeInterval(ifiData.ifi_xmittiming) / TimeInterval(USEC_PER_SEC)) ?? BasicEntry.unknownValue
            ))

            items.append(BasicEntry(
                key: .InterfaceLastChange(name: interface.name),
                name: NSLocalizedString("LAST_CHANGE", comment: "Last Change"),
                value: gDateTimeFormatter.string(
                    from: Date(timeIntervalSince1970: TimeInterval(ifiData.ifi_lastchange.tv_sec) + TimeInterval(ifiData.ifi_lastchange.tv_usec) / TimeInterval(USEC_PER_SEC)))
            ))
        }

        return items
    }

    var basicEntries: [BasicEntry] { items.flatMap { entries(interface: $0) } }
    let trafficEntries: [TrafficEntry<Int64>]? = nil
    let usageEntry: UsageEntry<Double>? = nil

    func updateEntries() {}

    let updatableEntryKeys: [EntryKey] = [
        .NetworkInterfaces,
    ]

    func basicEntry(key: EntryKey, style _: ValueStyle = .detailed) -> BasicEntry? {
        switch key {
        case .NetworkInterfaces:
            return BasicEntry(
                key: .FileSystems,
                name: NSLocalizedString("NUMBER_OF_NETWORK_INTERFACES", comment: "Number of Network Interfaces"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: items.count)) ?? BasicEntry.unknownValue
            )
        default:
            break
        }
        return nil
    }

    func updateBasicEntry(_ entry: BasicEntry, style _: ValueStyle = .detailed) {
        switch entry.key {
        case .NetworkInterfaces:
            entry.value = gLargeNumberFormatter.string(from: NSNumber(value: items.count)) ?? BasicEntry.unknownValue
        default:
            break
        }
    }

    func usageEntry(key _: EntryKey, style _: ValueStyle = .detailed) -> UsageEntry<Double>? { nil }

    func updateUsageEntry(_: UsageEntry<Double>, style _: ValueStyle) {}

    func trafficEntryIO(key _: EntryKey, style _: ValueStyle) -> TrafficEntryIO? { nil }

    func updateTrafficEntryIO(_: TrafficEntryIO, style _: ValueStyle) {}
}
