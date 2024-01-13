//
//  BatteryActivity.swift
//  Reveil
//
//  Created by Lessica on 2023/11/26.
//

#if canImport(UIKit)
    import UIKit
#else
    import Foundation
#endif

final class BatteryActivity {
    static let shared = BatteryActivity()

    enum BatteryState: Int, @unchecked Sendable {
        case unknown = 0
        case unplugged = 1
        case charging = 2
        case full = 3

        var description: String {
            switch self {
            case .unknown:
                return NSLocalizedString("BATTERY_UNKNOWN", comment: "Unknown")
            case .unplugged:
                return NSLocalizedString("BATTERY_UNPLUGGED", comment: "Unplugged")
            case .charging:
                return NSLocalizedString("BATTERY_CHARGING", comment: "Charging")
            case .full:
                return NSLocalizedString("BATTERY_FULL", comment: "Full")
            }
        }
    }

    private init() {
        #if canImport(UIKit)
            UIDevice.current.isBatteryMonitoringEnabled = true
        #endif
    }

    deinit {
        #if canImport(UIKit)
            UIDevice.current.isBatteryMonitoringEnabled = false
        #endif
    }

    func getBatteryLevel() -> Float {
        #if canImport(UIKit)
            return UIDevice.current.batteryLevel
        #else
            return 1.0
        #endif
    }

    func getBatteryState() -> BatteryState {
        #if canImport(UIKit)
            switch UIDevice.current.batteryState {
            case .unknown:
                return .unknown
            case .unplugged:
                return .unplugged
            case .charging:
                return .charging
            case .full:
                return .full
            @unknown default:
                return .unknown
            }
        #else
            return .unknown
        #endif
    }
}
