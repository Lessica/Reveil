//
//  ifaddrs_safe.swift
//  Reveil
//
//  Created by Lessica on 2023/10/8.
//

import Foundation

extension timeval32: Codable {
    enum CodingKeys: CodingKey {
        case tv_sec
        case tv_usec
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(tv_sec: container.decode(__int32_t.self, forKey: .tv_sec),
                      tv_usec: container.decode(__int32_t.self, forKey: .tv_usec))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tv_sec, forKey: .tv_sec)
        try container.encode(tv_usec, forKey: .tv_usec)
    }
}

extension if_data: Codable {
    enum CodingKeys: CodingKey {
        case ifi_type
        case ifi_typelen
        case ifi_physical
        case ifi_addrlen
        case ifi_hdrlen
        case ifi_recvquota
        case ifi_xmitquota
        case ifi_unused1
        case ifi_mtu
        case ifi_metric
        case ifi_baudrate
        case ifi_ipackets
        case ifi_ierrors
        case ifi_opackets
        case ifi_oerrors
        case ifi_collisions
        case ifi_ibytes
        case ifi_obytes
        case ifi_imcasts
        case ifi_omcasts
        case ifi_iqdrops
        case ifi_noproto
        case ifi_recvtiming
        case ifi_xmittiming
        case ifi_lastchange
        case ifi_unused2
        case ifi_hwassist
        case ifi_reserved1
        case ifi_reserved2
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(ifi_type: container.decode(u_char.self, forKey: .ifi_type),
                      ifi_typelen: container.decode(u_char.self, forKey: .ifi_typelen),
                      ifi_physical: container.decode(u_char.self, forKey: .ifi_physical),
                      ifi_addrlen: container.decode(u_char.self, forKey: .ifi_addrlen),
                      ifi_hdrlen: container.decode(u_char.self, forKey: .ifi_hdrlen),
                      ifi_recvquota: container.decode(u_char.self, forKey: .ifi_recvquota),
                      ifi_xmitquota: container.decode(u_char.self, forKey: .ifi_xmitquota),
                      ifi_unused1: container.decode(u_char.self, forKey: .ifi_unused1),
                      ifi_mtu: container.decode(UInt32.self, forKey: .ifi_mtu),
                      ifi_metric: container.decode(UInt32.self, forKey: .ifi_metric),
                      ifi_baudrate: container.decode(UInt32.self, forKey: .ifi_baudrate),
                      ifi_ipackets: container.decode(UInt32.self, forKey: .ifi_ipackets),
                      ifi_ierrors: container.decode(UInt32.self, forKey: .ifi_ierrors),
                      ifi_opackets: container.decode(UInt32.self, forKey: .ifi_opackets),
                      ifi_oerrors: container.decode(UInt32.self, forKey: .ifi_oerrors),
                      ifi_collisions: container.decode(UInt32.self, forKey: .ifi_collisions),
                      ifi_ibytes: container.decode(UInt32.self, forKey: .ifi_ibytes),
                      ifi_obytes: container.decode(UInt32.self, forKey: .ifi_obytes),
                      ifi_imcasts: container.decode(UInt32.self, forKey: .ifi_imcasts),
                      ifi_omcasts: container.decode(UInt32.self, forKey: .ifi_omcasts),
                      ifi_iqdrops: container.decode(UInt32.self, forKey: .ifi_iqdrops),
                      ifi_noproto: container.decode(UInt32.self, forKey: .ifi_noproto),
                      ifi_recvtiming: container.decode(UInt32.self, forKey: .ifi_recvtiming),
                      ifi_xmittiming: container.decode(UInt32.self, forKey: .ifi_xmittiming),
                      ifi_lastchange: container.decode(timeval32.self, forKey: .ifi_lastchange),
                      ifi_unused2: container.decode(UInt32.self, forKey: .ifi_unused2),
                      ifi_hwassist: container.decode(UInt32.self, forKey: .ifi_hwassist),
                      ifi_reserved1: container.decode(UInt32.self, forKey: .ifi_reserved1),
                      ifi_reserved2: container.decode(UInt32.self, forKey: .ifi_reserved2))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ifi_type, forKey: .ifi_type)
        try container.encode(ifi_typelen, forKey: .ifi_typelen)
        try container.encode(ifi_physical, forKey: .ifi_physical)
        try container.encode(ifi_addrlen, forKey: .ifi_addrlen)
        try container.encode(ifi_hdrlen, forKey: .ifi_hdrlen)
        try container.encode(ifi_recvquota, forKey: .ifi_recvquota)
        try container.encode(ifi_xmitquota, forKey: .ifi_xmitquota)
        try container.encode(ifi_unused1, forKey: .ifi_unused1)
        try container.encode(ifi_mtu, forKey: .ifi_mtu)
        try container.encode(ifi_metric, forKey: .ifi_metric)
        try container.encode(ifi_baudrate, forKey: .ifi_baudrate)
        try container.encode(ifi_ipackets, forKey: .ifi_ipackets)
        try container.encode(ifi_ierrors, forKey: .ifi_ierrors)
        try container.encode(ifi_opackets, forKey: .ifi_opackets)
        try container.encode(ifi_oerrors, forKey: .ifi_oerrors)
        try container.encode(ifi_collisions, forKey: .ifi_collisions)
        try container.encode(ifi_ibytes, forKey: .ifi_ibytes)
        try container.encode(ifi_obytes, forKey: .ifi_obytes)
        try container.encode(ifi_imcasts, forKey: .ifi_imcasts)
        try container.encode(ifi_omcasts, forKey: .ifi_omcasts)
        try container.encode(ifi_iqdrops, forKey: .ifi_iqdrops)
        try container.encode(ifi_noproto, forKey: .ifi_noproto)
        try container.encode(ifi_recvtiming, forKey: .ifi_recvtiming)
        try container.encode(ifi_xmittiming, forKey: .ifi_xmittiming)
        try container.encode(ifi_lastchange, forKey: .ifi_lastchange)
        try container.encode(ifi_unused2, forKey: .ifi_unused2)
        try container.encode(ifi_hwassist, forKey: .ifi_hwassist)
        try container.encode(ifi_reserved1, forKey: .ifi_reserved1)
        try container.encode(ifi_reserved2, forKey: .ifi_reserved2)
    }
}

struct ifaddrs_safe: Codable {
    let ifa_name: String
    let ifa_flags: UInt32
    let ifa_addr: SocketAddress?
    let ifa_netmask: SocketAddress?
    let ifa_dstaddr: SocketAddress?
    let ifa_data: if_data?

    init(addrs: ifaddrs) {
        ifa_name = String(cString: addrs.ifa_name)
        ifa_flags = addrs.ifa_flags
        if let ifaAddr = addrs.ifa_addr {
            ifa_addr = SocketAddress(ifaAddr)
            if ifaAddr.pointee.sa_family == sa_family_t(AF_LINK) {
                ifa_data = addrs.ifa_data.withMemoryRebound(to: if_data.self, capacity: 1) { pointer in
                    pointer.pointee
                }
            } else {
                ifa_data = nil
            }
        } else {
            ifa_addr = nil
            ifa_data = nil
        }
        if let ifaAddr = addrs.ifa_netmask {
            ifa_netmask = SocketAddress(ifaAddr)
        } else {
            ifa_netmask = nil
        }
        if let ifaAddr = addrs.ifa_dstaddr {
            ifa_dstaddr = SocketAddress(ifaAddr)
        } else {
            ifa_dstaddr = nil
        }
    }
}
