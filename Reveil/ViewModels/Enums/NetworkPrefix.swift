//
//  NetworkPrefix.swift
//  Reveil
//
//  Created by Lessica on 2023/10/13.
//

import SwiftUI

enum NetworkPrefix: String, CaseIterable, Codable, Identifiable {
    case lo // Loopback
    case gif // RFC2893 Tunnel
    case stf // RFC3056 Tunnel
    case utun // User Mode Tunnel
    case ipsec // IPSec Tunnel
    case en // Wired/Wireless
    case ap // Access Point
    case awdl // Apple Wireless Direct Link
    case p2p // Wi-Fi Peer to Peer
    case llw // Low Latency WAN
    case ppp // Point-to-Point Protocol
    case bridge // Personal Hotspot
    case pdp_ip // Cellular Connection
    case XHC // USB Packet Capture
    case pktap // Packet Layer Capture
    case iptap // IP Layer Capture
    case anpi // Virtual USB-C Dual Role Device

    case others = "__OTHERS__"
    case all = "__ALL__"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .lo: return NSLocalizedString("LOOPBACK", comment: "Loopback")
        case .gif: return NSLocalizedString("RFC2893_TUNNEL", comment: "RFC2893 Tunnel")
        case .stf: return NSLocalizedString("RFC3056_TUNNEL", comment: "RFC3056 Tunnel")
        case .utun: return NSLocalizedString("USER_MODE_TUNNEL", comment: "User Mode Tunnel")
        case .ipsec: return NSLocalizedString("IPSEC_TUNNEL", comment: "IPSec Tunnel")
        case .en: return NSLocalizedString("WIRED_WIRELESS", comment: "Wired/Wireless")
        case .ap: return NSLocalizedString("ACCESS_POINT", comment: "Access Point")
        case .awdl: return NSLocalizedString("APPLE_WIRELESS_DIRECT_LINK", comment: "Apple Wireless Direct Link")
        case .p2p: return NSLocalizedString("WIFI_PEER_TO_PEER", comment: "Wi-Fi Peer to Peer")
        case .llw: return NSLocalizedString("LOW_LATENCY_WAN", comment: "Low Latency WAN")
        case .ppp: return NSLocalizedString("POINT_TO_POINT_PROTOCOL", comment: "Point-to-Point Protocol")
        case .bridge: return NSLocalizedString("PERSONAL_HOTSPOT", comment: "Personal Hotspot")
        case .pdp_ip: return NSLocalizedString("CELLULAR_CONNECTION", comment: "Cellular Connection")
        case .XHC: return NSLocalizedString("USB_PACKET_CAPTURE", comment: "USB Packet Capture")
        case .pktap: return NSLocalizedString("PACKET_LAYER_CAPTURE", comment: "Packet Layer Capture")
        case .iptap: return NSLocalizedString("IP_LAYER_CAPTURE", comment: "IP Layer Capture")
        case .anpi: return NSLocalizedString("USB_DUAL_ROLE_DEVICE", comment: "USB Dual Role Device")
        case .others: return NSLocalizedString("OTHERS", comment: "Others")
        case .all: return NSLocalizedString("NETWORK", comment: "Network")
        }
    }
}

extension NetworkPrefix {
    init?(rawValue: String) {
        guard let prefix = Self.allCases.first(where: { rawValue.lowercased().hasPrefix($0.rawValue.lowercased()) })
        else {
            return nil
        }
        self = prefix
    }

    private static let colorPrefix = String(describing: NetworkInterface.self) + "-"
    private var colorName: String { Self.colorPrefix + rawValue }
    var color: Color? { self == .others ? nil : Color(colorName) }

    private static let keyPrefix = String(describing: NetworkUsage.self) + "-"
    var keyName: String { Self.keyPrefix + rawValue }

    init?(keyName: String) {
        guard keyName.hasPrefix(Self.keyPrefix) else {
            return nil
        }
        let rawVal = keyName[keyName.index(keyName.startIndex, offsetBy: Self.keyPrefix.count)...]
        self.init(rawValue: String(rawVal))
    }

    private var isCategoryCase: Bool { self != .all }
    static let categoryCases: [NetworkPrefix] = NetworkPrefix.allCases.filter(\.isCategoryCase)
}
