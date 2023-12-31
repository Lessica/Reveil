//
//  ReverseEngineeringToolsChecker.swift
//  IOSSecuritySuite
//
//  Created by wregula on 24/04/2019.
//  Copyright © 2019 wregula. All rights reserved.
//
// swiftlint:disable trailing_whitespace

import Foundation
import MachO // dyld

enum ReverseEngineeringToolsChecker {
    struct ReverseEngineeringToolsStatus: Codable {
        let passed: Bool
        let failedChecks: [FailedCheckType]
    }

    static func amIReverseEngineered() -> Bool {
        !performChecks().passed
    }

    static func amIReverseEngineeredWithFailedChecks() -> (reverseEngineered: Bool, failedChecks: [FailedCheckType]) {
        let status = performChecks()
        return (!status.passed, status.failedChecks)
    }

    private static func performChecks() -> ReverseEngineeringToolsStatus {
        var passed = true
        var result = CheckResult(passed: true, failMessage: "")
        var failedChecks: [FailedCheckType] = []

        for check in FailedCheck.allCases {
            switch check {
            case .existenceOfSuspiciousFiles:
                result = checkExistenceOfSuspiciousFiles()
            case .dyld:
                result = checkDYLD()
            case .openedPorts:
                result = checkOpenedPorts()
            case .pSelectFlag:
                result = checkPSelectFlag()
            default:
                continue
            }

            passed = passed && result.passed

            if !result.passed {
                failedChecks.append(FailedCheckType(check: check, failMessage: result.failMessage))
            }
        }

        return ReverseEngineeringToolsStatus(passed: passed, failedChecks: failedChecks)
    }

    static func checkDYLD() -> CheckResult {
        for index in 0 ..< _dyld_image_count() {
            let imageName = String(cString: _dyld_get_image_name(index))

            // The fastest case insensitive contains check.
            for library in SecurityPresets.default.suspiciousLibraryNames where imageName.localizedCaseInsensitiveContains(library) {
                return CheckResult(passed: false, failMessage: "Suspicious library loaded: \(imageName)")
            }
        }

        return CheckResult(passed: true, failMessage: "")
    }

    static func getSuspiciousLibraries() -> [String] {
        var foundLibraries = [String]()
        for index in 0 ..< _dyld_image_count() {
            let imageName = String(cString: _dyld_get_image_name(index))

            // The fastest case insensitive contains check.
            for library in SecurityPresets.default.suspiciousLibraryNames where imageName.localizedCaseInsensitiveContains(library) {
                foundLibraries.append(imageName)
            }
        }

        return foundLibraries
    }

    static func checkExistenceOfSuspiciousFiles() -> CheckResult {
        for path in SecurityPresets.default.suspiciousExecutables {
            if FileManager.default.fileExists(atPath: path) {
                return CheckResult(passed: false, failMessage: "Suspicious file found: \(path)")
            }
        }

        return CheckResult(passed: true, failMessage: "")
    }

    static func getSuspiciousFiles() -> [String] {
        SecurityPresets.default.suspiciousExecutables.filter { FileManager.default.fileExists(atPath: $0) }
    }

    static func checkOpenedPorts() -> CheckResult {
        for port in SecurityPresets.default.suspiciousPorts.map(\.port) {
            if canOpenLocalConnection(port: port) {
                return CheckResult(passed: false, failMessage: "Port \(port) is open")
            }
        }

        return CheckResult(passed: true, failMessage: "")
    }

    static func getOpenedPortItems() -> [PortItem] {
        SecurityPresets.default.suspiciousPorts.filter { canOpenLocalConnection(port: $0.port) }
    }

    private static func canOpenLocalConnection(port: Int) -> Bool {
        func swapBytesIfNeeded(port: in_port_t) -> in_port_t {
            let littleEndian = Int(OSHostByteOrder()) == OSLittleEndian
            return littleEndian ? _OSSwapInt16(port) : port
        }

        var serverAddress = sockaddr_in()
        serverAddress.sin_family = sa_family_t(AF_INET)
        serverAddress.sin_addr.s_addr = inet_addr("127.0.0.1")
        serverAddress.sin_port = swapBytesIfNeeded(port: in_port_t(port))
        let sock = socket(AF_INET, SOCK_STREAM, 0)

        let result = withUnsafePointer(to: &serverAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                connect(sock, $0, socklen_t(MemoryLayout<sockaddr_in>.stride))
            }
        }

        defer {
            close(sock)
        }

        if result != -1 {
            return true // Port is opened
        }

        return false
    }

    // EXPERIMENTAL
    static func checkPSelectFlag() -> CheckResult {
        var kinfo = kinfo_proc()
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride
        let sysctlRet = sysctl(&mib, UInt32(mib.count), &kinfo, &size, nil, 0)

        if sysctlRet != 0 {
            print("Error occured when calling sysctl(). This check may not be reliable")
        }

        if (kinfo.kp_proc.p_flag & P_SELECT) != 0 {
            return CheckResult(passed: false, failMessage: "Suspicious PFlag value")
        }

        return CheckResult(passed: true, failMessage: "")
    }
}
