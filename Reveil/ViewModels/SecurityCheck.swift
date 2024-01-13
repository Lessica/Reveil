//
//  SecurityCheck.swift
//  Reveil
//
//  Created by Lessica on 2023/10/25.
//

import OrderedCollections
import SwiftUI

enum SecurityCheck: CaseIterable, Codable, Equatable, Hashable, RawRepresentable {
    enum Status: String, Codable, Equatable, Hashable {
        case unchanged
        case failed
        case passed

        var prefix: String {
            switch self {
            case .unchanged:
                return "?"
            case .failed:
                return "!"
            case .passed:
                return ""
            }
        }
    }

    case noSuspiciousFile(Status)
    case noSuspiciousLibrary(Status)
    case noSuspiciousSymbolicLink(Status)
    case noSuspiciousOpenedPort(Status)
    case noSuspiciousURLScheme(Status)
    case noSuspiciousObjCClass(Status)
    case noSuspiciousEnvironmentVariables(Status)
    case notInTrustCache(Status)
    case signedSystemVolume(Status)

    case noSuspiciousAccessibleFile(Status)
    case noSuspiciousAccessibleDirectory(Status)
    case unableToFork(Status)
    case unavailableSeatbeltSpecialPort(Status)
    case unprivilegedHostPort(Status)
    case untouchedProcessTaskPort(Status)

    case identifiedBundleIdentifier(Status)
    case identifiedMobileProvisioningProfile(Status)
    case identifiedMachO(Status)
    case identifiedEntitlements(Status)

    case noInjectedLibrary(Status)
    case noHookedLibrary(Status)
    case noUnsignedExecutablePage(Status)
    case enabledLibraryValidation(Status)
    case expectedCodeSigningStatus(Status)
    case stockDynamicLinker(Status)
    case noPSelectFlag(Status)

    case notInSimulator(Status)
    case knownParentProcess(Status)
    case noDebuggerAttached(Status)
    case noExceptionPort(Status)
    case noSignalHandler(Status)
    case unmodifiedExecutionState(Status)

    case notProxied(Status)

    typealias RawValue = String

    init?(rawValue: String) {
        guard rawValue.count > 1 else {
            return nil
        }
        var status = Status.passed
        if rawValue.hasPrefix("!") {
            status = .failed
        } else if rawValue.hasPrefix("?") {
            status = .unchanged
        }
        switch String(rawValue[rawValue.index(rawValue.startIndex, offsetBy: 1)...]) {
        case "noSuspiciousFile":
            self = .noSuspiciousFile(status)
        case "noSuspiciousLibrary":
            self = .noSuspiciousLibrary(status)
        case "noSuspiciousSymbolicLink":
            self = .noSuspiciousSymbolicLink(status)
        case "noSuspiciousOpenedPort":
            self = .noSuspiciousOpenedPort(status)
        case "noSuspiciousURLScheme":
            self = .noSuspiciousURLScheme(status)
        case "noSuspiciousObjCClass":
            self = .noSuspiciousObjCClass(status)
        case "noSuspiciousAccessibleFile":
            self = .noSuspiciousAccessibleFile(status)
        case "noSuspiciousAccessibleDirectory":
            self = .noSuspiciousAccessibleDirectory(status)
        case "noSuspiciousEnvironmentVariables":
            self = .noSuspiciousEnvironmentVariables(status)
        case "identifiedBundleIdentifier":
            self = .identifiedBundleIdentifier(status)
        case "identifiedMobileProvisioningProfile":
            self = .identifiedMobileProvisioningProfile(status)
        case "identifiedMachO":
            self = .identifiedMachO(status)
        case "identifiedEntitlements":
            self = .identifiedEntitlements(status)
        case "expectedCodeSigningStatus":
            self = .expectedCodeSigningStatus(status)
        case "notProxied":
            self = .notProxied(status)
        case "noInjectedLibrary":
            self = .noInjectedLibrary(status)
        case "noHookedLibrary":
            self = .noHookedLibrary(status)
        case "unableToFork":
            self = .unableToFork(status)
        case "notInSimulator":
            self = .notInSimulator(status)
        case "noDebuggerAttached":
            self = .noDebuggerAttached(status)
        case "knownParentProcess":
            self = .knownParentProcess(status)
        case "noUnsignedExecutablePage":
            self = .noUnsignedExecutablePage(status)
        case "unavailableSeatbeltSpecialPort":
            self = .unavailableSeatbeltSpecialPort(status)
        case "signedSystemVolume":
            self = .signedSystemVolume(status)
        case "noPSelectFlag":
            self = .noPSelectFlag(status)
        case "unprivilegedHostPort":
            self = .unprivilegedHostPort(status)
        case "enabledLibraryValidation":
            self = .enabledLibraryValidation(status)
        case "stockDynamicLinker":
            self = .stockDynamicLinker(status)
        case "unmodifiedExecutionState":
            self = .unmodifiedExecutionState(status)
        case "untouchedProcessTaskPort":
            self = .untouchedProcessTaskPort(status)
        case "notInTrustCache":
            self = .notInTrustCache(status)
        case "noExceptionPort":
            self = .noExceptionPort(status)
        case "noSignalHandler":
            self = .noSignalHandler(status)
        default:
            return nil
        }
    }

    var rawValue: String {
        switch self {
        case let .noSuspiciousFile(status):
            return status.prefix + "noSuspiciousFiles"
        case let .noSuspiciousLibrary(status):
            return status.prefix + "noSuspiciousLibraries"
        case let .noSuspiciousSymbolicLink(status):
            return status.prefix + "noSuspiciousSymbolicLinks"
        case let .noSuspiciousOpenedPort(status):
            return status.prefix + "noSuspiciousOpenedPorts"
        case let .noSuspiciousURLScheme(status):
            return status.prefix + "noSuspiciousURLScheme"
        case let .noSuspiciousObjCClass(status):
            return status.prefix + "noSuspiciousObjCClass"
        case let .noSuspiciousAccessibleFile(status):
            return status.prefix + "noSuspiciousAccessibleFile"
        case let .noSuspiciousAccessibleDirectory(status):
            return status.prefix + "noSuspiciousAccessibleDirectory"
        case let .noSuspiciousEnvironmentVariables(status):
            return status.prefix + "noSuspiciousEnvironmentVariables"
        case let .identifiedBundleIdentifier(status):
            return status.prefix + "identifiedBundleIdentifier"
        case let .identifiedMobileProvisioningProfile(status):
            return status.prefix + "identifiedMobileProvisioningProfile"
        case let .identifiedMachO(status):
            return status.prefix + "identifiedMachO"
        case let .identifiedEntitlements(status):
            return status.prefix + "identifiedEntitlements"
        case let .expectedCodeSigningStatus(status):
            return status.prefix + "expectedCodeSigningStatus"
        case let .notProxied(status):
            return status.prefix + "notProxied"
        case let .noInjectedLibrary(status):
            return status.prefix + "noInjectedLibrary"
        case let .noHookedLibrary(status):
            return status.prefix + "noHookedLibrary"
        case let .unableToFork(status):
            return status.prefix + "unableToFork"
        case let .notInSimulator(status):
            return status.prefix + "notInSimulator"
        case let .noDebuggerAttached(status):
            return status.prefix + "noDebuggerAttached"
        case let .knownParentProcess(status):
            return status.prefix + "knownParentProcess"
        case let .noUnsignedExecutablePage(status):
            return status.prefix + "noUnsignedExecutablePage"
        case let .unavailableSeatbeltSpecialPort(status):
            return status.prefix + "unavailableSeatbeltSpecialPort"
        case let .signedSystemVolume(status):
            return status.prefix + "signedSystemVolume"
        case let .noPSelectFlag(status):
            return status.prefix + "noPSelectFlag"
        case let .unprivilegedHostPort(status):
            return status.prefix + "unprivilegedHostPort"
        case let .enabledLibraryValidation(status):
            return status.prefix + "enabledLibraryValidation"
        case let .stockDynamicLinker(status):
            return status.prefix + "stockDynamicLinker"
        case let .unmodifiedExecutionState(status):
            return status.prefix + "unmodifiedExecutionState"
        case let .untouchedProcessTaskPort(status):
            return status.prefix + "untouchedProcessTaskPort"
        case let .notInTrustCache(status):
            return status.prefix + "notInTrustCache"
        case let .noExceptionPort(status):
            return status.prefix + "noExceptionPort"
        case let .noSignalHandler(status):
            return status.prefix + "noSignalHandler"
        }
    }

    static let allCases: [SecurityCheck] = [
        .noSuspiciousFile(.unchanged),
        .noSuspiciousLibrary(.unchanged),
        .noSuspiciousSymbolicLink(.unchanged),
        .noSuspiciousOpenedPort(.unchanged),
        .noSuspiciousURLScheme(.unchanged),
        .noSuspiciousObjCClass(.unchanged),
        .noSuspiciousAccessibleFile(.unchanged),
        .noSuspiciousAccessibleDirectory(.unchanged),
        .noSuspiciousEnvironmentVariables(.unchanged),
        .identifiedBundleIdentifier(.unchanged),
        .identifiedMobileProvisioningProfile(.unchanged),
        .identifiedMachO(.unchanged),
        .identifiedEntitlements(.unchanged),
        .expectedCodeSigningStatus(.unchanged),
        .notProxied(.unchanged),
        .noInjectedLibrary(.unchanged),
        .noHookedLibrary(.unchanged),
        .unableToFork(.unchanged),
        .notInSimulator(.unchanged),
        .noDebuggerAttached(.unchanged),
        .knownParentProcess(.unchanged),
        .noUnsignedExecutablePage(.unchanged),
        .unavailableSeatbeltSpecialPort(.unchanged),
        .signedSystemVolume(.unchanged),
        .noPSelectFlag(.unchanged),
        .unprivilegedHostPort(.unchanged),
        .enabledLibraryValidation(.unchanged),
        .stockDynamicLinker(.unchanged),
        .unmodifiedExecutionState(.unchanged),
        .untouchedProcessTaskPort(.unchanged),
        .notInTrustCache(.unchanged),
        .noExceptionPort(.unchanged),
        .noSignalHandler(.unchanged),
    ]

    var isFailed: Bool {
        switch self {
        case let .noSuspiciousFile(status): fallthrough
        case let .noSuspiciousLibrary(status): fallthrough
        case let .noSuspiciousSymbolicLink(status): fallthrough
        case let .noSuspiciousOpenedPort(status): fallthrough
        case let .noSuspiciousURLScheme(status): fallthrough
        case let .noSuspiciousObjCClass(status): fallthrough
        case let .noSuspiciousAccessibleFile(status): fallthrough
        case let .noSuspiciousAccessibleDirectory(status): fallthrough
        case let .noSuspiciousEnvironmentVariables(status): fallthrough
        case let .identifiedBundleIdentifier(status): fallthrough
        case let .identifiedMobileProvisioningProfile(status): fallthrough
        case let .identifiedMachO(status): fallthrough
        case let .identifiedEntitlements(status): fallthrough
        case let .expectedCodeSigningStatus(status): fallthrough
        case let .notProxied(status): fallthrough
        case let .noInjectedLibrary(status): fallthrough
        case let .noHookedLibrary(status): fallthrough
        case let .unableToFork(status): fallthrough
        case let .notInSimulator(status): fallthrough
        case let .noDebuggerAttached(status): fallthrough
        case let .knownParentProcess(status): fallthrough
        case let .noUnsignedExecutablePage(status): fallthrough
        case let .unavailableSeatbeltSpecialPort(status): fallthrough
        case let .signedSystemVolume(status): fallthrough
        case let .noPSelectFlag(status): fallthrough
        case let .unprivilegedHostPort(status): fallthrough
        case let .enabledLibraryValidation(status): fallthrough
        case let .stockDynamicLinker(status): fallthrough
        case let .unmodifiedExecutionState(status): fallthrough
        case let .untouchedProcessTaskPort(status): fallthrough
        case let .notInTrustCache(status): fallthrough
        case let .noExceptionPort(status): fallthrough
        case let .noSignalHandler(status):
            return status == .failed
        }
    }

    var isPassed: Bool {
        switch self {
        case let .noSuspiciousFile(status): fallthrough
        case let .noSuspiciousLibrary(status): fallthrough
        case let .noSuspiciousSymbolicLink(status): fallthrough
        case let .noSuspiciousOpenedPort(status): fallthrough
        case let .noSuspiciousURLScheme(status): fallthrough
        case let .noSuspiciousObjCClass(status): fallthrough
        case let .noSuspiciousAccessibleFile(status): fallthrough
        case let .noSuspiciousAccessibleDirectory(status): fallthrough
        case let .noSuspiciousEnvironmentVariables(status): fallthrough
        case let .identifiedBundleIdentifier(status): fallthrough
        case let .identifiedMobileProvisioningProfile(status): fallthrough
        case let .identifiedMachO(status): fallthrough
        case let .identifiedEntitlements(status): fallthrough
        case let .expectedCodeSigningStatus(status): fallthrough
        case let .notProxied(status): fallthrough
        case let .noInjectedLibrary(status): fallthrough
        case let .noHookedLibrary(status): fallthrough
        case let .unableToFork(status): fallthrough
        case let .notInSimulator(status): fallthrough
        case let .noDebuggerAttached(status): fallthrough
        case let .knownParentProcess(status): fallthrough
        case let .noUnsignedExecutablePage(status): fallthrough
        case let .unavailableSeatbeltSpecialPort(status): fallthrough
        case let .signedSystemVolume(status): fallthrough
        case let .noPSelectFlag(status): fallthrough
        case let .unprivilegedHostPort(status): fallthrough
        case let .enabledLibraryValidation(status): fallthrough
        case let .stockDynamicLinker(status): fallthrough
        case let .unmodifiedExecutionState(status): fallthrough
        case let .untouchedProcessTaskPort(status): fallthrough
        case let .notInTrustCache(status): fallthrough
        case let .noExceptionPort(status): fallthrough
        case let .noSignalHandler(status):
            return status == .passed
        }
    }

    var status: Status {
        switch self {
        case let .noSuspiciousFile(status): fallthrough
        case let .noSuspiciousLibrary(status): fallthrough
        case let .noSuspiciousSymbolicLink(status): fallthrough
        case let .noSuspiciousOpenedPort(status): fallthrough
        case let .noSuspiciousURLScheme(status): fallthrough
        case let .noSuspiciousObjCClass(status): fallthrough
        case let .noSuspiciousAccessibleFile(status): fallthrough
        case let .noSuspiciousAccessibleDirectory(status): fallthrough
        case let .noSuspiciousEnvironmentVariables(status): fallthrough
        case let .identifiedBundleIdentifier(status): fallthrough
        case let .identifiedMobileProvisioningProfile(status): fallthrough
        case let .identifiedMachO(status): fallthrough
        case let .identifiedEntitlements(status): fallthrough
        case let .expectedCodeSigningStatus(status): fallthrough
        case let .notProxied(status): fallthrough
        case let .noInjectedLibrary(status): fallthrough
        case let .noHookedLibrary(status): fallthrough
        case let .unableToFork(status): fallthrough
        case let .notInSimulator(status): fallthrough
        case let .noDebuggerAttached(status): fallthrough
        case let .knownParentProcess(status): fallthrough
        case let .noUnsignedExecutablePage(status): fallthrough
        case let .unavailableSeatbeltSpecialPort(status): fallthrough
        case let .signedSystemVolume(status): fallthrough
        case let .noPSelectFlag(status): fallthrough
        case let .unprivilegedHostPort(status): fallthrough
        case let .enabledLibraryValidation(status): fallthrough
        case let .stockDynamicLinker(status): fallthrough
        case let .unmodifiedExecutionState(status): fallthrough
        case let .untouchedProcessTaskPort(status): fallthrough
        case let .notInTrustCache(status): fallthrough
        case let .noExceptionPort(status): fallthrough
        case let .noSignalHandler(status):
            return status
        }
    }

    var description: String {
        switch self {
        case let .noSuspiciousFile(status):
            return status == .failed ?
                NSLocalizedString("SUSPICIOUS_FILES_FOUND", comment: "Suspicious files found") :
                NSLocalizedString("NO_SUSPICIOUS_FILE", comment: "No suspicious file")
        case let .noSuspiciousLibrary(status):
            return status == .failed ?
                NSLocalizedString("SUSPICIOUS_LIBRARIES_FOUND", comment: "Suspicious libraries found") :
                NSLocalizedString("NO_SUSPICIOUS_LIBRARY", comment: "No suspicious library")
        case let .noSuspiciousSymbolicLink(status):
            return status == .failed ?
                NSLocalizedString("SUSPICIOUS_SYMBOLIC_LINKS_FOUND", comment: "Suspicious symbolic links found") :
                NSLocalizedString("NO_SUSPICIOUS_SYMBOLIC_LINK", comment: "No suspicious symbolic link")
        case let .noSuspiciousOpenedPort(status):
            return status == .failed ?
                NSLocalizedString("SUSPICIOUS_OPENED_PORTS_FOUND", comment: "Suspicious opened ports found") :
                NSLocalizedString("NO_SUSPICIOUS_OPENED_PORT", comment: "No suspicious opened port")
        case let .noSuspiciousURLScheme(status):
            return status == .failed ?
                NSLocalizedString("SUSPICIOUS_URL_SCHEMES_FOUND", comment: "Suspicious url schemes found") :
                NSLocalizedString("NO_SUSPICIOUS_URL_SCHEME", comment: "No suspicious url scheme")
        case let .noSuspiciousObjCClass(status):
            return status == .failed ?
                NSLocalizedString("SUSPICIOUS_OBJC_CLASSES_FOUND", comment: "Suspicious Objective-C classes found") :
                NSLocalizedString("NO_SUSPICIOUS_OBJC_CLASS", comment: "No suspicious Objective-C class")
        case let .noSuspiciousAccessibleFile(status):
            return status == .failed ?
                NSLocalizedString("SUSPICIOUS_WRITABLE_FILES_FOUND", comment: "Suspicious writable files found") :
                NSLocalizedString("NO_SUSPICIOUS_WRITABLE_FILE", comment: "No suspicious writable file")
        case let .noSuspiciousAccessibleDirectory(status):
            return status == .failed ?
                NSLocalizedString("SUSPICIOUS_WRITABLE_DIRECTORIES_FOUND", comment: "Suspicious writable directories found") :
                NSLocalizedString("NO_SUSPICIOUS_WRITABLE_DIRECTORY", comment: "No suspicious writable directory")
        case let .noSuspiciousEnvironmentVariables(status):
            return status == .failed ?
                NSLocalizedString("SUSPICIOUS_ENVIRONMENT_VARIABLES_FOUND", comment: "Suspicious environment variables found") :
                NSLocalizedString("NO_SUSPICIOUS_ENVIRONMENT_VARIABLE", comment: "No suspicious environment variable")
        case let .identifiedBundleIdentifier(status):
            return status == .failed ?
                NSLocalizedString("TAMPERED_BUNDLE_IDENTIFIER", comment: "Main bundle identifier was tampered") :
                NSLocalizedString("ORIGINAL_BUNDLE_IDENTIFIER", comment: "Main bundle has a valid bundle identifier")
        case let .identifiedMobileProvisioningProfile(status):
            return status == .failed ?
                NSLocalizedString("TAMPERED_MOBILE_PROVISIONING_PROFILE", comment: "Mobile provisioning profile was tampered") :
                NSLocalizedString("ORIGINAL_MOBILE_PROVISIONING_PROFILE", comment: "Mobile provisioning profile is trusted")
        case let .identifiedMachO(status):
            return status == .failed ?
                NSLocalizedString("TAMPERED_MACH_O", comment: "Main executable was tampered") :
                NSLocalizedString("ORIGINAL_MACH_O", comment: "Main executable is trusted")
        case let .identifiedEntitlements(status):
            return status == .failed ?
                NSLocalizedString("TAMPERED_ENTITLEMENTS", comment: "Unknown keys found in entitlements") :
                NSLocalizedString("ORIGINAL_ENTITLEMENTS", comment: "All keys in entitlements are trusted")
        case let .expectedCodeSigningStatus(status):
            return status == .failed ?
                NSLocalizedString("UNEXPECTED_CODE_SIGNING_STATUS", comment: "Unexpected code signing status") :
                NSLocalizedString("EXPECTED_CODE_SIGNING_STATUS", comment: "Valid code signing status")
        case let .notProxied(status):
            return status == .failed ?
                NSLocalizedString("PROXY_SETTINGS_FOUND", comment: "System HTTP/HTTPS proxy found") :
                NSLocalizedString("NO_PROXY_SETTINGS", comment: "No HTTP/HTTPS proxy")
        case let .noInjectedLibrary(status):
            return status == .failed ?
                NSLocalizedString("INJECTED_LIBRARIES_FOUND", comment: "Injected libraries found") :
                NSLocalizedString("NO_INJECTED_LIBRARY", comment: "No injected library")
        case let .noHookedLibrary(status):
            return status == .failed ?
                NSLocalizedString("HOOKED_LIBRARIES_FOUND", comment: "Hooked libraries found") :
                NSLocalizedString("NO_HOOKED_LIBRARY", comment: "No hooked library")
        case let .unableToFork(status):
            return status == .failed ?
                NSLocalizedString("AVAILABLE_FORK", comment: "Fork was able to create a new process (sandbox violation)") :
                NSLocalizedString("UNABLE_TO_FORK", comment: "Sandbox blocks call to fork(2)")
        case let .notInSimulator(status):
            return status == .failed ?
                NSLocalizedString("RUN_IN_SIMULATOR", comment: "Simulator environment detected") :
                NSLocalizedString("NOT_IN_SIMULATOR", comment: "Run on a hardware device")
        case let .noDebuggerAttached(status):
            return status == .failed ?
                NSLocalizedString("DEBUGGER_ATTACHED", comment: "Debugger attached") :
                NSLocalizedString("NO_DEBUGGER_ATTACHED", comment: "No debugger attached")
        case let .knownParentProcess(status):
            return status == .failed ?
                NSLocalizedString("UNKNOWN_PARENT_PROCESS", comment: "Unknown parent process") :
                NSLocalizedString("KNOWN_PARENT_PROCESS", comment: "Parent process is launchd")
        case let .noUnsignedExecutablePage(status):
            return status == .failed ?
                NSLocalizedString("UNSIGNED_EXECUTABLE_PAGES_FOUND", comment: "Unsigned executable pages found") :
                NSLocalizedString("NO_UNSIGNED_EXECUTABLE_PAGE", comment: "No unsigned executable page found")
        case let .unavailableSeatbeltSpecialPort(status):
            return status == .failed ?
                NSLocalizedString("SEATBELT_SPECIAL_PORT_IS_AVAILABLE", comment: "Seatbelt special port is available") :
                NSLocalizedString("UNAVAILABLE_SEATBELT_SPECIAL_PORT", comment: "Seatbelt special port is not available")
        case let .signedSystemVolume(status):
            return status == .failed ?
                NSLocalizedString("UNSIGNED_SYSTEM_VOLUME", comment: "System volume is not signed") :
                NSLocalizedString("SIGNED_SYSTEM_VOLUME", comment: "System volume is signed")
        case let .noPSelectFlag(status):
            return status == .failed ?
                NSLocalizedString("P_SELECT_FLAG_FOUND", comment: "Suspicious process flag P_SELECT found") :
                NSLocalizedString("NO_P_SELECT_FLAG", comment: "No suspicious process flag P_SELECT")
        case let .unprivilegedHostPort(status):
            return status == .failed ?
                NSLocalizedString("PRIVILEGED_HOST_PORT", comment: "Host port is privileged") :
                NSLocalizedString("UNPRIVILEGED_HOST_PORT", comment: "Host port is not privileged")
        case let .enabledLibraryValidation(status):
            return status == .failed ?
                NSLocalizedString("DISABLED_LIBRARY_VALIDATION", comment: "Library validation is disabled") :
                NSLocalizedString("ENABLED_LIBRARY_VALIDATION", comment: "Library validation is enabled")
        case let .stockDynamicLinker(status):
            return status == .failed ?
                NSLocalizedString("BAD_DYNAMIC_LINKER", comment: "Dynamic linker is unreliable") :
                NSLocalizedString("STOCK_DYNAMIC_LINKER", comment: "Dynamic linker is reliable")
        case let .unmodifiedExecutionState(status):
            return status == .failed ?
                NSLocalizedString("MODIFIED_EXECUTION_STATE", comment: "Execution state was modified") :
                NSLocalizedString("UNMODIFIED_EXECUTION_STATE", comment: "Execution state was not modified")
        case let .untouchedProcessTaskPort(status):
            return status == .failed ?
                NSLocalizedString("TOUCHED_PROCESS_TASK_PORT", comment: "Process task port was obtained") :
                NSLocalizedString("UNTOUCHED_PROCESS_TASK_PORT", comment: "Process task port was not obtained")
        case let .notInTrustCache(status):
            return status == .failed ?
                NSLocalizedString("IN_TRUST_CACHE", comment: "Binary is in trust cache") :
                NSLocalizedString("NOT_IN_TRUST_CACHE", comment: "Binary is not in trust cache")
        case let .noExceptionPort(status):
            return status == .failed ?
                NSLocalizedString("HAS_EXCEPTION_PORT", comment: "Exception ports were set") :
                NSLocalizedString("NO_EXCEPTION_PORT", comment: "Exception ports not set")
        case let .noSignalHandler(status):
            return status == .failed ?
                NSLocalizedString("HAS_SIGNAL_HANDLER", comment: "Signal handlers were set") :
                NSLocalizedString("NO_SIGNAL_HANDLER", comment: "Signal handlers not set")
        }
    }

    var type: SecurityCheckType {
        switch self {
        case .noSuspiciousFile:
            return .jailbreakEnvironment
        case .noSuspiciousLibrary:
            return .jailbreakEnvironment
        case .noSuspiciousSymbolicLink:
            return .jailbreakEnvironment
        case .noSuspiciousOpenedPort:
            return .jailbreakEnvironment
        case .noSuspiciousURLScheme:
            return .jailbreakEnvironment
        case .noSuspiciousObjCClass:
            return .jailbreakEnvironment
        case .noSuspiciousEnvironmentVariables:
            return .jailbreakEnvironment
        case .notInTrustCache:
            return .jailbreakEnvironment
        case .signedSystemVolume:
            return .jailbreakEnvironment

        case .noSuspiciousAccessibleFile:
            return .sandboxViolation
        case .noSuspiciousAccessibleDirectory:
            return .sandboxViolation
        case .unableToFork:
            return .sandboxViolation
        case .unavailableSeatbeltSpecialPort:
            return .sandboxViolation
        case .unprivilegedHostPort:
            return .sandboxViolation
        case .untouchedProcessTaskPort:
            return .sandboxViolation

        case .identifiedBundleIdentifier:
            return .staticIntegrity
        case .identifiedMobileProvisioningProfile:
            return .staticIntegrity
        case .identifiedMachO:
            return .staticIntegrity
        case .identifiedEntitlements:
            return .staticIntegrity

        case .noInjectedLibrary:
            return .dynamicIntegrity
        case .noHookedLibrary:
            return .dynamicIntegrity
        case .noUnsignedExecutablePage:
            return .dynamicIntegrity
        case .enabledLibraryValidation:
            return .dynamicIntegrity
        case .expectedCodeSigningStatus:
            return .dynamicIntegrity
        case .stockDynamicLinker:
            return .dynamicIntegrity
        case .noPSelectFlag:
            return .dynamicIntegrity

        case .notInSimulator:
            return .debuggerEmulator
        case .knownParentProcess:
            return .debuggerEmulator
        case .noDebuggerAttached:
            return .debuggerEmulator
        case .noExceptionPort:
            return .debuggerEmulator
        case .noSignalHandler:
            return .debuggerEmulator
        case .unmodifiedExecutionState:
            return .debuggerEmulator

        case .notProxied:
            return .networkProxy
        }
    }

    func perform() -> SecurityCheck {
        switch self {
        case .noSuspiciousFile:
            return .noSuspiciousFile(
                JailbreakChecker.checkExistenceOfSuspiciousFiles().passed &&
                    ReverseEngineeringToolsChecker.checkExistenceOfSuspiciousFiles().passed
                    ? .passed : .failed)
        case .noSuspiciousLibrary:
            return .noSuspiciousLibrary(
                JailbreakChecker.checkDYLD().passed &&
                    ReverseEngineeringToolsChecker.checkDYLD().passed
                    ? .passed : .failed)
        case .noSuspiciousSymbolicLink:
            return .noSuspiciousSymbolicLink(JailbreakChecker.checkSymbolicLinks().passed ? .passed : .failed)
        case .noSuspiciousOpenedPort:
            return .noSuspiciousOpenedPort(ReverseEngineeringToolsChecker.checkOpenedPorts().passed ? .passed : .failed)
        case .noSuspiciousURLScheme:
            return .noSuspiciousURLScheme(Security.shared.suspiciousURLSchemes.isEmpty ? .passed : .failed)
        case .noSuspiciousObjCClass:
            return .noSuspiciousObjCClass(JailbreakChecker.checkSuspiciousObjCClasses().passed ? .passed : .failed)
        case .noSuspiciousAccessibleFile:
            return .noSuspiciousAccessibleFile(JailbreakChecker.checkSuspiciousFilesCanBeOpened().passed ? .passed : .failed)
        case .noSuspiciousAccessibleDirectory:
            return .noSuspiciousAccessibleDirectory(JailbreakChecker.checkRestrictedDirectoriesWritable().passed ? .passed : .failed)
        case .noSuspiciousEnvironmentVariables:
            return .noSuspiciousEnvironmentVariables(Security.shared.checkSuspiciousEnvironmentVariables() ? .passed : .failed)
        case .identifiedBundleIdentifier:
            return .identifiedBundleIdentifier(Security.shared.checkMainBundleIdentifier() ? .passed : .failed)
        case .identifiedMobileProvisioningProfile:
            return .identifiedMobileProvisioningProfile(Security.shared.checkMobileProvisioningProfileHash() ? .passed : .failed)
        case .identifiedMachO:
            return .identifiedMachO(Security.shared.checkMachOHash() ? .passed : .failed)
        case .identifiedEntitlements:
            return .identifiedEntitlements(Security.shared.checkEntitlements() ? .passed : .failed)
        case .expectedCodeSigningStatus:
            return .expectedCodeSigningStatus(Security.shared.checkCodeSigningStatus() ? .passed : .failed)
        case .notProxied:
            return .notProxied(IOSSecuritySuite.amIProxied() ? .failed : .passed)
        case .noInjectedLibrary:
            return .noInjectedLibrary(Security.shared.hasInsecureLibraryPaths() ? .failed : .passed)
        case .noHookedLibrary:
            return .noHookedLibrary(Security.shared.hasInsertedLibraryPaths() ? .failed : .passed)
        case .unableToFork:
            return .unableToFork(JailbreakChecker.checkFork().passed ? .passed : .failed)
        case .notInSimulator:
            return .notInSimulator(IOSSecuritySuite.amIRunInEmulator() ? .failed : .passed)
        case .noDebuggerAttached:
            return .noDebuggerAttached(IOSSecuritySuite.amIDebugged() ? .failed : .passed)
        case .knownParentProcess:
            return .knownParentProcess(IOSSecuritySuite.isParentPidUnexpected() ? .failed : .passed)
        case .noUnsignedExecutablePage:
            return .noUnsignedExecutablePage(Security.shared.checkExecutableMemoryRegions() ? .passed : .failed)
        case .unavailableSeatbeltSpecialPort:
            return .unavailableSeatbeltSpecialPort(Security.shared.checkSeatbeltSpecialPort() ? .passed : .failed)
        case .signedSystemVolume:
            return .signedSystemVolume(Security.shared.checkSignedSystemVolume() ? .passed : .failed)
        case .noPSelectFlag:
            return .noPSelectFlag(ReverseEngineeringToolsChecker.checkPSelectFlag().passed ? .passed : .failed)
        case .unprivilegedHostPort:
            return .unprivilegedHostPort(Security.shared.checkPrivilegedHostPort() ? .passed : .failed)
        case .enabledLibraryValidation:
            return .enabledLibraryValidation(Security.shared.checkLibraryValidationEnabled() ? .passed : .failed)
        case .stockDynamicLinker:
            return .stockDynamicLinker(Security.shared.checkDYLDEnvironmentVariables() ? .passed : .failed)
        case .unmodifiedExecutionState:
            return .unmodifiedExecutionState(Security.shared.checkExecutionStates() ? .passed : .failed)
        case .untouchedProcessTaskPort:
            return .untouchedProcessTaskPort(Security.shared.checkExtraTaskRefs() ? .passed : .failed)
        case .notInTrustCache:
            return .notInTrustCache(Security.shared.checkTrustCache() ? .passed : .failed)
        case .noExceptionPort:
            return .noExceptionPort(Security.shared.checkExceptionPorts() ? .passed : .failed)
        case .noSignalHandler:
            return .noSignalHandler(Security.shared.checkSignalHandlers() ? .passed : .failed)
        }
    }

    private func csOpsStatusColor(_ status: CsOpsStatus) -> Color {
        status.isPresented
            ? (status.isInsecure ? Color("SecurityLeaks") : Color.accentColor)
            : (status.isRequired ? Color("SecurityLeaks") : Color(PlatformColor.secondarySystemFillAlias))
    }

    func entry() -> BasicEntry {
        var entryChildren: [BasicEntry]?
        switch self {
        case let .noSuspiciousFile(status):
            if status == .failed {
                entryChildren = OrderedSet(
                    JailbreakChecker.getSuspiciousFiles() +
                        ReverseEngineeringToolsChecker.getSuspiciousFiles()
                ).map {
                    BasicEntry(customLabel: $0, allowedToCopy: true)
                }
            }
        case let .noSuspiciousLibrary(status):
            if status == .failed {
                entryChildren = OrderedSet(
                    JailbreakChecker.getSuspiciousLibraries() +
                        ReverseEngineeringToolsChecker.getSuspiciousLibraries()
                ).map {
                    BasicEntry(customLabel: $0, allowedToCopy: true)
                }
            }
        case let .noSuspiciousOpenedPort(status):
            if status == .failed {
                entryChildren = ReverseEngineeringToolsChecker.getOpenedPortItems().map { item in
                    BasicEntry(key: .AllowedToCopy(name: item.description), name: item.description, value: String(format: "%d", item.port))
                }
            }
        case let .noSuspiciousURLScheme(status):
            if status == .failed {
                entryChildren = Security.shared.suspiciousURLSchemes.map { item in
                    BasicEntry(key: .AllowedToCopy(name: item.description), name: item.description, value: item.scheme)
                }
            }
        case let .noSuspiciousObjCClass(status):
            if status == .failed {
                entryChildren = JailbreakChecker.getSuspiciousObjCClasses().map {
                    BasicEntry(customLabel: $0.description, allowedToCopy: true)
                }
            }
        case let .noSuspiciousAccessibleFile(status):
            if status == .failed {
                entryChildren = JailbreakChecker.getSuspiciousAccessibleFiles().map {
                    BasicEntry(customLabel: $0, allowedToCopy: true)
                }
            }
        case let .noSuspiciousAccessibleDirectory(status):
            if status == .failed {
                entryChildren = JailbreakChecker.getSuspiciousAccessibleDirectories().map {
                    BasicEntry(customLabel: $0, allowedToCopy: true)
                }
            }
        case let .noSuspiciousEnvironmentVariables(status):
            if status == .failed {
                entryChildren = Security.shared.getSuspiciousEnvironmentVariables().map {
                    BasicEntry(customLabel: $0, allowedToCopy: true)
                }
            }
        case let .identifiedEntitlements(status):
            if status == .failed {
                entryChildren = Security.shared.getUnknownEntitlementKeys().map {
                    BasicEntry(customLabel: $0, allowedToCopy: true)
                }
            }
        case let .expectedCodeSigningStatus(status):
            if status == .failed {
                entryChildren = Security.shared.getCodeSigningStatus().map {
                    BasicEntry(
                        key: .Custom(name: $0.flag.name),
                        name: $0.flag.description,
                        color: csOpsStatusColor($0)
                    )
                }
            }
        case let .noInjectedLibrary(status):
            if status == .failed {
                entryChildren = Security.shared.getInsecureLibraryPaths().map {
                    BasicEntry(customLabel: $0, allowedToCopy: true)
                }
            }
        case let .noHookedLibrary(status):
            if status == .failed {
                entryChildren = Security.shared.getInsertedLibraryPaths().map {
                    BasicEntry(customLabel: $0, allowedToCopy: true)
                }
            }
        default:
            break
        }
        return BasicEntry(
            key: .Custom(name: rawValue),
            name: description,
            color: isPassed ? Color.accentColor : (isFailed ? Color("SecurityLeaks") : Color(PlatformColor.secondarySystemFillAlias)),
            children: entryChildren
        )
    }
}
