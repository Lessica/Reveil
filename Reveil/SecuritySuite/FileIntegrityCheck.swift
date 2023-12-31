//
//  FileIntegrityCheck.swift
//  Reveil
//
//  Created by Lessica on 2023/10/29.
//

import Foundation

enum FileIntegrityCheck: Codable {
    // Compare current bundleID with a specified bundleID.
    case bundleID(String)

    // Compare current hash value(SHA256 hex string) of `embedded.mobileprovision` with a specified hash value.
    // Use command `"shasum -a 256 /path/to/embedded.mobileprovision"` to get SHA256 value on your macOS.
    case mobileProvision(String)

    // Compare current hash value(SHA256 hex string) of executable file with a specified (Image Name, Hash Value).
    // Only work on dynamic library and arm64.
    case machO(String, String)
}

extension FileIntegrityCheck: Explainable {
    var description: String {
        switch self {
        case let .bundleID(exceptedBundleID):
            "The expected bundle identify was \(exceptedBundleID)"
        case let .mobileProvision(expectedSha256Value):
            "The expected hash value of Mobile Provision file was \(expectedSha256Value)"
        case let .machO(imageName, expectedSha256Value):
            "The expected hash value of \"__TEXT.__text\" data of \(imageName) Mach-O file was \(expectedSha256Value)"
        }
    }
}
