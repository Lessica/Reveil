//
//  Created by Mateusz Matrejek
//

import Foundation

final class Entitlements {
    struct Key {
        let rawKey: String

        init(_ name: String) {
            rawKey = name
        }

        static let autofillCredentialProvider = Key("com.apple.developer.authentication-services.autofill-credential-provider")
        static let signWithApple = Key("com.apple.developer.applesignin")
        static let contacts = Key("com.apple.developer.contacts.notes")
        static let classKit = Key("com.apple.developer.ClassKit-environment")
        static let automaticAssesmentConfiguration = Key("com.apple.developer.automatic-assessment-configuration")
        static let gameCenter = Key("com.apple.developer.game-center")
        static let healthKit = Key("com.apple.developer.healthkit")
        static let healthKitCapabilities = Key("com.apple.developer.healthkit.access")
        static let homeKit = Key("com.apple.developer.homekit")
        static let iCloudDevelopmentContainersIdentifiers = Key("com.apple.developer.icloud-container-development-container-identifiers")
        static let iCloudContainersEnvironment = Key("com.apple.developer.icloud-container-environment")
        static let iCloudContainerIdentifiers = Key("com.apple.developer.icloud-container-identifiers")
        static let iCloudServices = Key("com.apple.developer.icloud-services")
        static let iCloudKeyValueStore = Key("com.apple.developer.ubiquity-kvstore-identifier")
        static let interAppAudio = Key("inter-app-audio")
        static let networkExtensions = Key("com.apple.developer.networking.networkextension")
        static let personalVPN = Key("com.apple.developer.networking.vpn.api")
        static let apsEnvironment = Key("aps-environment")
        static let appGroups = Key("com.apple.security.application-groups")
        static let keychainAccessGroups = Key("keychain-access-groups")
        static let dataProtection = Key("com.apple.developer.default-data-protection")
        static let siri = Key("com.apple.developer.siri")
        static let passTypeIDs = Key("com.apple.developer.pass-type-identifiers")
        static let merchantIDs = Key("com.apple.developer.in-app-payments")
        static let wifiInfo = Key("com.apple.developer.networking.wifi-info")
        static let externalAccessoryConfiguration = Key("com.apple.external-accessory.wireless-configuration")
        static let multipath = Key("com.apple.developer.networking.multipath")
        static let hotspotConfiguration = Key("com.apple.developer.networking.HotspotConfiguration")
        static let nfcTagReaderSessionFormats = Key("com.apple.developer.nfc.readersession.formats")
        static let associatedDomains = Key("com.apple.developer.associated-domains")
        static let maps = Key("com.apple.developer.maps")
        static let driverKit = Key("com.apple.developer.driverkit.transport.pci")
    }

    static let empty: Entitlements = .init([:])

    let values: [String: Any]

    init(_ values: [String: Any]) {
        self.values = values
    }

    func value(forKey key: Entitlements.Key) -> Any? {
        values[key.rawKey]
    }

    class func entitlements(from data: Data) -> Entitlements {
        guard let rawValues = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
            return .empty
        }
        return Entitlements(rawValues)
    }
}
