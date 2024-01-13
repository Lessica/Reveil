//
//  DeviceInformation.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import CoreTelephony
import UIKit

final class DeviceInformation: Module {
    static let shared = DeviceInformation()
    private init() {}

    let moduleName = NSLocalizedString("DEVICE_INFORMATION", comment: "Device Information")

    private static func gLoadModelDatabase(_ name: String) -> [[String: Any]] {
        guard let jsonURL = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: jsonURL),
              let dictionary = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        else {
            return []
        }
        return dictionary
    }

    let gModelDictionary: [String: Any]? = {
        var dictionary = [[String: Any]]()
        dictionary.append(contentsOf: gLoadModelDatabase("rsc-003-iphone-models"))
        dictionary.append(contentsOf: gLoadModelDatabase("rsc-005-ipad-models"))
        dictionary.append(contentsOf: gLoadModelDatabase("rsc-006-ipod-models"))
        let deviceName = System.uname().machine
        return dictionary.first { $0["machine"] as? String == deviceName }
    }()

    private func currentRadioTechName() -> String? {
        guard let currentRadioTech = CTTelephonyNetworkInfo().serviceCurrentRadioAccessTechnology,
              let firstKey = currentRadioTech.keys.sorted().first,
              let firstValue = currentRadioTech[firstKey]
        else {
            return nil
        }

        let techName: String
        if firstValue == CTRadioAccessTechnologyLTE {
            techName = "Long-Term Evolution (LTE)"
        } else if firstValue == CTRadioAccessTechnologyeHRPD {
            techName = "Enhanced High Rate Packet Data (eHRPD)"
        } else if firstValue == CTRadioAccessTechnologyCDMAEVDORevB {
            techName = "Code Division Multiple Access (CDMA) Evolution-Data Optimized (EV-DO) Rev. B"
        } else if firstValue == CTRadioAccessTechnologyCDMAEVDORevA {
            techName = "Code Division Multiple Access (CDMA) Evolution-Data Optimized (EV-DO) Rev. A"
        } else if firstValue == CTRadioAccessTechnologyCDMAEVDORev0 {
            techName = "Code Division Multiple Access (CDMA) Evolution-Data Optimized (EV-DO) Rev. 0"
        } else if firstValue == CTRadioAccessTechnologyCDMA1x {
            techName = "Code Division Multiple Access (CDMA) 1x"
        } else if firstValue == CTRadioAccessTechnologyHSUPA {
            techName = "High-Speed Uplink Packet Acess (HSUPA)"
        } else if firstValue == CTRadioAccessTechnologyHSDPA {
            techName = "High-Speed Downlink Packet Access (HSDPA)"
        } else if firstValue == CTRadioAccessTechnologyWCDMA {
            techName = "Wideband Code Division Multiple Access (WCDMA)"
        } else if firstValue == CTRadioAccessTechnologyEdge {
            techName = "Enhanced Data rates for GSM Evolution (EDGE)"
        } else if firstValue == CTRadioAccessTechnologyGPRS {
            techName = "General Packet Radio Service (GPRS)"
        } else {
            if #available(iOS 14.1, *) {
                if firstValue == CTRadioAccessTechnologyNR {
                    techName = "5G New Radio (NR)"
                } else if firstValue == CTRadioAccessTechnologyNRNSA {
                    techName = "5G New Radio Non-Standalone (NRNSA)"
                } else {
                    techName = BasicEntry.unknownValue
                }
            } else {
                // Fallback on earlier versions
                techName = BasicEntry.unknownValue
            }
        }

        return techName
    }

    private var displaySizeDescription: String {
        let mainScreen = UIScreen.main
        return "\(Int(mainScreen.fixedCoordinateSpace.bounds.height * mainScreen.scale))×\(Int(mainScreen.fixedCoordinateSpace.bounds.width * mainScreen.scale))"
    }

    lazy var basicEntries: [BasicEntry] = updatableEntryKeys.compactMap { basicEntry(key: $0) }

    let usageEntry: UsageEntry<Double>? = nil

    func reloadData() {}

    func updateEntries() {
        basicEntries.forEach { updateBasicEntry($0) }
    }

    let updatableEntryKeys: [EntryKey] = [
        .DeviceName,
        .MarketingName,
        .DeviceModel,
        .BootromVersion,
        .RadioTech,
        .HostName,
        .DisplayResolution,
    ]

    func basicEntry(key: EntryKey, style _: ValueStyle = .detailed) -> BasicEntry? {
        switch key {
        case .DeviceName:
            return BasicEntry(
                key: .DeviceName,
                name: NSLocalizedString("DEVICE_NAME", comment: "Device Name"),
                value: gModelDictionary?["machine"] as? String ?? BasicEntry.unknownValue
            )
        case .MarketingName:
            return BasicEntry(
                key: .MarketingName,
                name: NSLocalizedString("MARKETING_NAME", comment: "Marketing Name"),
                value: gModelDictionary?["name"] as? String ?? BasicEntry.unknownValue
            )
        case .DeviceModel:
            return BasicEntry(
                key: .DeviceModel,
                name: NSLocalizedString("DEVICE_MODEL", comment: "Device Model"),
                value: System.modelName()
            )
        case .BootromVersion:
            return BasicEntry(
                key: .BootromVersion,
                name: NSLocalizedString("BOOTROM_VERSION", comment: "Bootrom Version"),
                value: gModelDictionary?["bootrom"] as? String ?? BasicEntry.unknownValue
            )
        case .RadioTech:
            if let techName = currentRadioTechName() {
                return BasicEntry(
                    key: .RadioTech,
                    name: NSLocalizedString("RADIO_TECH", comment: "Radio Tech"),
                    value: techName
                )
            }
        case .HostName:
            return BasicEntry(
                key: .HostName,
                name: NSLocalizedString("HOST_NAME", comment: "Host Name"),
                value: System.hostName() ?? BasicEntry.unknownValue
            )
        case .DisplayResolution:
            return BasicEntry(
                key: .DisplayResolution,
                name: NSLocalizedString("DISPLAY_RESOLUTION", comment: "Display Resolution"),
                value: displaySizeDescription
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
