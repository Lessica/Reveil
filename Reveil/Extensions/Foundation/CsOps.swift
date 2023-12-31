//
//  CsOps.swift
//  Reveil
//
//  Created by Lessica on 2023/11/5.
//

import Darwin
import Foundation

@discardableResult
func csops(pid: pid_t = getpid(), ops: CUnsignedInt, dest: UnsafeMutableRawPointer?, destSize: size_t) -> CInt {
    let csopsRaw = dlsym(.init(bitPattern: -2), "csops")
    typealias csopsType = @convention(c) (pid_t, CUnsignedInt, UnsafeMutableRawPointer?, size_t) -> CInt
    return unsafeBitCast(csopsRaw, to: csopsType.self)(pid, ops, dest, destSize)
}

let CS_OPS_STATUS = 0

struct CsOpsStatus: Codable, Hashable {
    let flag: CsOpsFlags
    let isRequired: Bool
    let isInsecure: Bool
    let isPresented: Bool
}

struct CsOpsFlags: OptionSet, Hashable, Codable {
    let rawValue: UInt32

    static let CS_VALID = CsOpsFlags(rawValue: 0x0000_0001)
    static let CS_ADHOC = CsOpsFlags(rawValue: 0x0000_0002)
    static let CS_GET_TASK_ALLOW = CsOpsFlags(rawValue: 0x0000_0004)
    static let CS_INSTALLER = CsOpsFlags(rawValue: 0x0000_0008)

    static let CS_HARD = CsOpsFlags(rawValue: 0x0000_0100)
    static let CS_KILL = CsOpsFlags(rawValue: 0x0000_0200)
    static let CS_CHECK_EXPIRATION = CsOpsFlags(rawValue: 0x0000_0400)
    static let CS_RESTRICT = CsOpsFlags(rawValue: 0x0000_0800)

    static let CS_ENFORCEMENT = CsOpsFlags(rawValue: 0x0000_1000)
    static let CS_REQUIRE_LV = CsOpsFlags(rawValue: 0x0000_2000)
    static let CS_ENTITLEMENTS_VALIDATED = CsOpsFlags(rawValue: 0x0000_4000)
    static let CS_NVRAM_UNRESTRICTED = CsOpsFlags(rawValue: 0x0000_8000)

    static let CS_EXEC_SET_HARD = CsOpsFlags(rawValue: 0x0010_0000)
    static let CS_EXEC_SET_KILL = CsOpsFlags(rawValue: 0x0020_0000)
    static let CS_EXEC_SET_ENFORCEMENT = CsOpsFlags(rawValue: 0x0040_0000)
    static let CS_EXEC_INHERIT_SIP = CsOpsFlags(rawValue: 0x0080_0000)

    static let CS_KILLED = CsOpsFlags(rawValue: 0x0100_0000)
    static let CS_DYLD_PLATFORM = CsOpsFlags(rawValue: 0x0200_0000)
    static let CS_PLATFORM_BINARY = CsOpsFlags(rawValue: 0x0400_0000)
    static let CS_PLATFORM_PATH = CsOpsFlags(rawValue: 0x0800_0000)

    static let CS_DEBUGGED = CsOpsFlags(rawValue: 0x1000_0000)
    static let CS_SIGNED = CsOpsFlags(rawValue: 0x2000_0000)
    static let CS_DEV_CODE = CsOpsFlags(rawValue: 0x4000_0000)
    static let CS_DATAVAULT_CONTROLLER = CsOpsFlags(rawValue: 0x8000_0000)

    static let insecureSet: Set<CsOpsFlags> = [.CS_INSTALLER, .CS_PLATFORM_BINARY, .CS_DEBUGGED] // .CS_GET_TASK_ALLOW
    static let requiredSecureSet: Set<CsOpsFlags> = [.CS_VALID, .CS_HARD, .CS_KILL, .CS_ENFORCEMENT, .CS_REQUIRE_LV, .CS_DYLD_PLATFORM, .CS_SIGNED]

    static let allCases: [CsOpsFlags] = [
        .CS_VALID, .CS_ADHOC, .CS_GET_TASK_ALLOW, .CS_INSTALLER,
        .CS_HARD, .CS_KILL, .CS_CHECK_EXPIRATION, .CS_RESTRICT,
        .CS_ENFORCEMENT, .CS_REQUIRE_LV, .CS_ENTITLEMENTS_VALIDATED, .CS_NVRAM_UNRESTRICTED,
        .CS_EXEC_SET_HARD, .CS_EXEC_SET_KILL, .CS_EXEC_SET_ENFORCEMENT, .CS_EXEC_INHERIT_SIP,
        .CS_KILLED, .CS_DYLD_PLATFORM, .CS_PLATFORM_BINARY, .CS_PLATFORM_PATH,
        .CS_DEBUGGED, .CS_SIGNED, .CS_DEV_CODE, .CS_DATAVAULT_CONTROLLER,
    ]

    var name: String {
        switch self {
        case .CS_VALID: "CS_VALID"
        case .CS_ADHOC: "CS_ADHOC"
        case .CS_GET_TASK_ALLOW: "CS_GET_TASK_ALLOW"
        case .CS_INSTALLER: "CS_INSTALLER"
        case .CS_HARD: "CS_HARD"
        case .CS_KILL: "CS_KILL"
        case .CS_CHECK_EXPIRATION: "CS_CHECK_EXPIRATION"
        case .CS_RESTRICT: "CS_RESTRICT"
        case .CS_ENFORCEMENT: "CS_ENFORCEMENT"
        case .CS_REQUIRE_LV: "CS_REQUIRE_LV"
        case .CS_ENTITLEMENTS_VALIDATED: "CS_ENTITLEMENTS_VALIDATED"
        case .CS_NVRAM_UNRESTRICTED: "CS_NVRAM_UNRESTRICTED"
        case .CS_EXEC_SET_HARD: "CS_EXEC_SET_HARD"
        case .CS_EXEC_SET_KILL: "CS_EXEC_SET_KILL"
        case .CS_EXEC_SET_ENFORCEMENT: "CS_EXEC_SET_ENFORCEMENT"
        case .CS_EXEC_INHERIT_SIP: "CS_EXEC_INHERIT_SIP"
        case .CS_KILLED: "CS_KILLED"
        case .CS_DYLD_PLATFORM: "CS_DYLD_PLATFORM"
        case .CS_PLATFORM_BINARY: "CS_PLATFORM_BINARY"
        case .CS_PLATFORM_PATH: "CS_PLATFORM_PATH"
        case .CS_DEBUGGED: "CS_DEBUGGED"
        case .CS_SIGNED: "CS_SIGNED"
        case .CS_DEV_CODE: "CS_DEV_CODE"
        case .CS_DATAVAULT_CONTROLLER: "CS_DATAVAULT_CONTROLLER"
        default: "CS_UNKNOWN"
        }
    }

    var description: String {
        switch self {
        case .CS_VALID:
            NSLocalizedString("CS_VALID", comment: "Dynamically valid")
        case .CS_ADHOC:
            NSLocalizedString("CS_ADHOC", comment: "Ad Hoc signed")
        case .CS_GET_TASK_ALLOW:
            NSLocalizedString("CS_GET_TASK_ALLOW", comment: "Has get-task-allow entitlement")
        case .CS_INSTALLER:
            NSLocalizedString("CS_INSTALLER", comment: "Has installer entitlement")
        case .CS_HARD:
            NSLocalizedString("CS_HARD", comment: "Don't load invalid pages")
        case .CS_KILL:
            NSLocalizedString("CS_KILL", comment: "Kill process if it becomes invalid")
        case .CS_CHECK_EXPIRATION:
            NSLocalizedString("CS_CHECK_EXPIRATION", comment: "Force expiration checking")
        case .CS_RESTRICT:
            NSLocalizedString("CS_RESTRICT", comment: "Tell dyld to treat restricted")
        case .CS_ENFORCEMENT:
            NSLocalizedString("CS_ENFORCEMENT", comment: "Require enforcement")
        case .CS_REQUIRE_LV:
            NSLocalizedString("CS_REQUIRE_LV", comment: "Require library validation")
        case .CS_ENTITLEMENTS_VALIDATED:
            NSLocalizedString("CS_ENTITLEMENTS_VALIDATED", comment: "Code signature permits restricted entitlements")
        case .CS_NVRAM_UNRESTRICTED:
            NSLocalizedString("CS_NVRAM_UNRESTRICTED", comment: "Has com.apple.rootless.restricted-nvram-variables.heritable entitlement")
        case .CS_EXEC_SET_HARD:
            NSLocalizedString("CS_EXEC_SET_HARD", comment: "Set CS_HARD on any exec'ed process")
        case .CS_EXEC_SET_KILL:
            NSLocalizedString("CS_EXEC_SET_KILL", comment: "Set CS_KILL on any exec'ed process")
        case .CS_EXEC_SET_ENFORCEMENT:
            NSLocalizedString("CS_EXEC_SET_ENFORCEMENT", comment: "Set CS_ENFORCEMENT on any exec'ed process")
        case .CS_EXEC_INHERIT_SIP:
            NSLocalizedString("CS_EXEC_INHERIT_SIP", comment: "Set CS_INSTALLER on any exec'ed process")
        case .CS_KILLED:
            NSLocalizedString("CS_KILLED", comment: "Was killed by kernel for invalidity")
        case .CS_DYLD_PLATFORM:
            NSLocalizedString("CS_DYLD_PLATFORM", comment: "Dyld used to load this is a platform binary")
        case .CS_PLATFORM_BINARY:
            NSLocalizedString("CS_PLATFORM_BINARY", comment: "This is a platform binary")
        case .CS_PLATFORM_PATH:
            NSLocalizedString("CS_PLATFORM_PATH", comment: "Platform binary by the fact of path (OS X only)")
        case .CS_DEBUGGED:
            NSLocalizedString("CS_DEBUGGED", comment: "Process is currently or has previously been debugged and allowed to run with invalid pages")
        case .CS_SIGNED:
            NSLocalizedString("CS_SIGNED", comment: "Process has a signature (may have gone invalid)")
        case .CS_DEV_CODE:
            NSLocalizedString("CS_DEV_CODE", comment: "Code is dev signed, cannot be loaded into prod signed code")
        case .CS_DATAVAULT_CONTROLLER:
            NSLocalizedString("CS_DATAVAULT_CONTROLLER", comment: "Has Data Vault controller entitlement")
        default:
            String(format: NSLocalizedString("CS_UNKNOWN_FLAG", comment: "Unknown flag (0x%08x)"), rawValue)
        }
    }
}
