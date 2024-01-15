//
//  DeviceInformation.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import CoreTelephony

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

    #if canImport(UIKit)
        private func currentRadioTechName() -> String? {
            guard let currentRadioTech = CTTelephonyNetworkInfo().serviceCurrentRadioAccessTechnology,
                  let firstKey = currentRadioTech.keys.sorted().first,
                  let firstValue = currentRadioTech[firstKey]
            else {
                return nil
            }

            let techName: String = if firstValue == CTRadioAccessTechnologyLTE {
                "Long-Term Evolution (LTE)"
            } else if firstValue == CTRadioAccessTechnologyeHRPD {
                "Enhanced High Rate Packet Data (eHRPD)"
            } else if firstValue == CTRadioAccessTechnologyCDMAEVDORevB {
                "Code Division Multiple Access (CDMA) Evolution-Data Optimized (EV-DO) Rev. B"
            } else if firstValue == CTRadioAccessTechnologyCDMAEVDORevA {
                "Code Division Multiple Access (CDMA) Evolution-Data Optimized (EV-DO) Rev. A"
            } else if firstValue == CTRadioAccessTechnologyCDMAEVDORev0 {
                "Code Division Multiple Access (CDMA) Evolution-Data Optimized (EV-DO) Rev. 0"
            } else if firstValue == CTRadioAccessTechnologyCDMA1x {
                "Code Division Multiple Access (CDMA) 1x"
            } else if firstValue == CTRadioAccessTechnologyHSUPA {
                "High-Speed Uplink Packet Acess (HSUPA)"
            } else if firstValue == CTRadioAccessTechnologyHSDPA {
                "High-Speed Downlink Packet Access (HSDPA)"
            } else if firstValue == CTRadioAccessTechnologyWCDMA {
                "Wideband Code Division Multiple Access (WCDMA)"
            } else if firstValue == CTRadioAccessTechnologyEdge {
                "Enhanced Data rates for GSM Evolution (EDGE)"
            } else if firstValue == CTRadioAccessTechnologyGPRS {
                "General Packet Radio Service (GPRS)"
            } else {
                if #available(iOS 14.1, *) {
                    if firstValue == CTRadioAccessTechnologyNR {
                        "5G New Radio (NR)"
                    } else if firstValue == CTRadioAccessTechnologyNRNSA {
                        "5G New Radio Non-Standalone (NRNSA)"
                    } else {
                        BasicEntry.unknownValue
                    }
                } else {
                    // Fallback on earlier versions
                    BasicEntry.unknownValue
                }
            }

            return techName
        }
    #endif

    private var displaySizeDescription: String {
        #if canImport(UIKit)
            let mainScreen = UIScreen.main
            return "\(Int(mainScreen.fixedCoordinateSpace.bounds.height * mainScreen.scale))×\(Int(mainScreen.fixedCoordinateSpace.bounds.width * mainScreen.scale))"
        #endif
        #if canImport(AppKit)
            guard let mainScreen = NSScreen.main else {
                return NSLocalizedString("NOT_AVAILABLE", comment: "Not Available")
            }
            let scale = mainScreen.backingScaleFactor
            return "\(Int(mainScreen.frame.height * scale))×\(Int(mainScreen.frame.width * scale))"
        #endif

        return NSLocalizedString("NOT_AVAILABLE", comment: "Not Available")
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
            #if canImport(UIKit)
                if let techName = currentRadioTechName() {
                    return BasicEntry(
                        key: .RadioTech,
                        name: NSLocalizedString("RADIO_TECH", comment: "Radio Tech"),
                        value: techName
                    )
                }
            #else
                return BasicEntry(
                    key: .RadioTech,
                    name: NSLocalizedString("RADIO_TECH", comment: "Radio Tech"),
                    value: NSLocalizedString("NOT_AVAILABLE", comment: "Not Available")
                )
            #endif
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
