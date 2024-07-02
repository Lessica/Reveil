//
//  JailbreakChecker.swift
//  IOSSecuritySuite
//
//  Created by wregula on 23/04/2019.
//  Copyright © 2019 wregula. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity function_body_length type_body_length trailing_whitespace

import Darwin // fork
import Foundation
import MachO // dyld
import ObjectiveC // NSObject and Selector
import UIKit
import OrderedCollections

enum JailbreakChecker {
    struct JailbreakStatus: Codable {
        let passed: Bool
        let failMessage: String // Added for backwards compatibility
        let failedChecks: [FailedCheckType]
    }

    static func amIJailbroken() -> Bool {
        !performChecks().passed
    }

    static func amIJailbrokenWithFailMessage() -> (jailbroken: Bool, failMessage: String) {
        let status = performChecks()
        return (!status.passed, status.failMessage)
    }

    static func amIJailbrokenWithFailedChecks() -> (jailbroken: Bool, failedChecks: [FailedCheckType]) {
        let status = performChecks()
        return (!status.passed, status.failedChecks)
    }

    private static func performChecks() -> JailbreakStatus {
        var passed = true
        var failMessage = ""
        var result = CheckResult(passed: true, failMessage: "")
        var failedChecks: [FailedCheckType] = []

        for check in FailedCheck.allCases {
            switch check {
            case .urlSchemes:
                result = checkURLSchemes()
            case .existenceOfSuspiciousFiles:
                result = checkExistenceOfSuspiciousFiles()
            case .suspiciousFilesCanBeOpened:
                result = checkSuspiciousFilesCanBeOpened()
            case .restrictedDirectoriesWriteable:
                result = checkRestrictedDirectoriesWritable()
            case .fork:
                result = checkFork()
            case .symbolicLinks:
                result = checkSymbolicLinks()
            case .dyld:
                result = checkDYLD()
            case .suspiciousObjCClasses:
                result = checkSuspiciousObjCClasses()
            default:
                continue
            }

            passed = passed && result.passed

            if !result.passed {
                failedChecks.append(FailedCheckType(check: check, failMessage: result.failMessage))

                if !failMessage.isEmpty {
                    failMessage += ", "
                }
            }

            failMessage += result.failMessage
        }

        return JailbreakStatus(passed: passed, failMessage: failMessage, failedChecks: failedChecks)
    }

    private static func canOpenURLFromList(urlSchemes: [String]) -> CheckResult {
        for urlScheme in urlSchemes {
            if let url = URL(string: urlScheme) {
                if UIApplication.shared.canOpenURL(url) {
                    return CheckResult(passed: false, failMessage: "\(urlScheme) URL scheme detected")
                }
            }
        }
        return CheckResult(passed: true, failMessage: "")
    }

    static func getSuspiciousURLSchemes() -> [URLSchemeItem] {
        SecurityPresets.default.suspiciousURLSchemes
            .filter { item in
                if let url = URL(string: item.scheme) {
                    return UIApplication.shared.canOpenURL(url)
                }
                return false
            }
            .sorted()
    }

    // "cydia://" URL scheme has been removed. Turns out there is app in the official App Store
    // that has the cydia:// URL scheme registered, so it may cause false positive
    static func checkURLSchemes() -> CheckResult {
        canOpenURLFromList(urlSchemes: SecurityPresets.default.suspiciousURLSchemes.map(\.scheme))
    }

    private static let suspiciousFiles: Set<String> = {
        var paths = SecurityPresets.default.suspiciousFiles

        // These files can give false positive in the emulator
        if !EmulatorChecker.amIRunInEmulator() {
            paths.formUnion(SecurityPresets.default.suspiciousInterpreters)
        }

        return paths
    }()

    static func checkExistenceOfSuspiciousFiles() -> CheckResult {
        for path in suspiciousFiles {
            if FileManager.default.fileExists(atPath: path) {
                return CheckResult(passed: false, failMessage: "Suspicious file exists: \(path)")
            } else if let result = FileChecker.checkExistenceOfSuspiciousFilesViaStat(path: path) {
                return result
            } else if let result = FileChecker.checkExistenceOfSuspiciousFilesViaFOpen(path: path, mode: .readable) {
                return result
            } else if let result = FileChecker.checkExistenceOfSuspiciousFilesViaAccess(path: path, mode: .readable) {
                return result
            }
        }

        return CheckResult(passed: true, failMessage: "")
    }

    static func getSuspiciousFiles() -> [String] {
        suspiciousFiles.filter {
            FileManager.default.fileExists(atPath: $0) ||
                FileChecker.checkExistenceOfSuspiciousFilesViaStat(path: $0) != nil ||
                FileChecker.checkExistenceOfSuspiciousFilesViaFOpen(path: $0, mode: .readable) != nil ||
                FileChecker.checkExistenceOfSuspiciousFilesViaAccess(path: $0, mode: .readable) != nil
        }
    }

    private static let suspiciousAccessibleFiles: Set<String> = {
        var paths = SecurityPresets.default.suspiciousAccessibleFiles

        // These files can give false positive in the emulator
        if !EmulatorChecker.amIRunInEmulator() {
            paths.formUnion(SecurityPresets.default.suspiciousAccessibleInterpreters)
        }

        return paths
    }()

    static func checkSuspiciousFilesCanBeOpened() -> CheckResult {
        for path in suspiciousAccessibleFiles {
            if FileManager.default.isReadableFile(atPath: path) {
                return CheckResult(passed: false, failMessage: "Suspicious file can be opened: \(path)")
            } else if let result = FileChecker.checkExistenceOfSuspiciousFilesViaFOpen(path: path, mode: .writable) {
                return result
            } else if let result = FileChecker.checkExistenceOfSuspiciousFilesViaAccess(path: path, mode: .writable) {
                return result
            }
        }

        return CheckResult(passed: true, failMessage: "")
    }

    static func getSuspiciousAccessibleFiles() -> [String] {
        suspiciousAccessibleFiles.filter {
            FileManager.default.isReadableFile(atPath: $0) ||
                FileChecker.checkExistenceOfSuspiciousFilesViaFOpen(path: $0, mode: .writable) != nil ||
                FileChecker.checkExistenceOfSuspiciousFilesViaAccess(path: $0, mode: .writable) != nil
        }
    }

    static func checkRestrictedDirectoriesWritable() -> CheckResult {
        if FileChecker.checkRestrictedPathIsReadonlyViaStatvfs(path: "/") == false {
            return CheckResult(passed: false, failMessage: "Restricted path / is not read-only")
        } else if FileChecker.checkRestrictedPathIsReadonlyViaStatfs(path: "/") == false {
            return CheckResult(passed: false, failMessage: "Restricted path / is not read-only")
        } else if FileChecker.checkRestrictedPathIsReadonlyViaGetfsstat(name: "/") == false {
            return CheckResult(passed: false, failMessage: "Restricted path / is not read-only")
        }

        // If library won't be able to write to any restricted directory the return(false, ...) is never reached
        // because of catch{} statement
        for path in SecurityPresets.default.suspiciousAccessibleDirectories {
            do {
                let pathWithSomeRandom = path + UUID().uuidString
                try "AmIJailbroken?".write(toFile: pathWithSomeRandom, atomically: true, encoding: String.Encoding.utf8)
                try FileManager.default.removeItem(atPath: pathWithSomeRandom) // clean if succesfully written
                return CheckResult(passed: false, failMessage: "Wrote to restricted path: \(path)")
            } catch {}
        }

        return CheckResult(passed: true, failMessage: "")
    }

    static func getSuspiciousAccessibleDirectories() -> [String] {
        var directories = [String]()

        if FileChecker.checkRestrictedPathIsReadonlyViaStatvfs(path: "/") == false {
            directories.append("/")
        } else if FileChecker.checkRestrictedPathIsReadonlyViaStatfs(path: "/") == false {
            directories.append("/")
        } else if FileChecker.checkRestrictedPathIsReadonlyViaGetfsstat(name: "/") == false {
            directories.append("/")
        }

        directories.append(contentsOf: SecurityPresets.default.suspiciousAccessibleDirectories.filter { path in

            do {
                let pathWithSomeRandom = path + UUID().uuidString
                try "AmIJailbroken?".write(toFile: pathWithSomeRandom, atomically: true, encoding: String.Encoding.utf8)
                try FileManager.default.removeItem(atPath: pathWithSomeRandom) // clean if succesfully written
                return true
            } catch {}

            return false
        })

        return directories
    }

    static func checkFork() -> CheckResult {
        guard !EmulatorChecker.amIRunInEmulator() else {
            print("App run in the emulator, skipping the fork check.")
            return CheckResult(passed: true, failMessage: "")
        }

        let pointerToFork = UnsafeMutableRawPointer(bitPattern: -2)
        let forkPtr = dlsym(pointerToFork, "fork")
        typealias ForkType = @convention(c) () -> pid_t
        let fork = unsafeBitCast(forkPtr, to: ForkType.self)
        let forkResult = fork()

        if forkResult >= 0 {
            if forkResult > 0 {
                kill(forkResult, SIGTERM)
            }
            return CheckResult(passed: false, failMessage: "Fork was able to create a new process (sandbox violation)")
        }

        return CheckResult(passed: true, failMessage: "")
    }

    static func checkSymbolicLinks() -> CheckResult {
        for path in SecurityPresets.default.suspiciousSymbolicLinks {
            do {
                let result = try FileManager.default.destinationOfSymbolicLink(atPath: path)
                if !result.isEmpty {
                    return CheckResult(passed: false, failMessage: "Non standard symbolic link detected: \(path) points to \(result)")
                }
            } catch {}
        }

        return CheckResult(passed: true, failMessage: "")
    }

    static func getSuspiciousSymbolicLinks() -> [String] {
        SecurityPresets.default.suspiciousSymbolicLinks.filter { path in

            do {
                let result = try FileManager.default.destinationOfSymbolicLink(atPath: path)
                if !result.isEmpty {
                    return true
                }
            } catch {}

            return false
        }
    }

    static func checkDYLD() -> CheckResult {
        for index in 0 ..< _dyld_image_count() {
            let imageName = String(cString: _dyld_get_image_name(index))

            // The fastest case insensitive contains check.
            for library in SecurityPresets.default.suspiciousLibraries where imageName.localizedCaseInsensitiveContains(library) {
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
            for library in SecurityPresets.default.suspiciousLibraries where imageName.localizedCaseInsensitiveContains(library) {
                foundLibraries.append(imageName)
            }
        }

        return foundLibraries
    }

    static func checkSuspiciousObjCClasses() -> CheckResult {
        for item in SecurityPresets.default.suspiciousObjCClasses {
            if let clazz = objc_getClass(item.className) as? NSObject.Type {
                let selector = Selector(item.selectorName)
                switch item.methodType {
                case .instance:
                    if class_getInstanceMethod(clazz, selector) != nil {
                        return CheckResult(passed: false, failMessage: "Suspicious objective-c class detected: \(item.className)")
                    }
                case .clazz:
                    if class_getClassMethod(clazz, selector) != nil {
                        return CheckResult(passed: false, failMessage: "Suspicious objective-c class detected: \(item.className)")
                    }
                }
            }
        }

        return CheckResult(passed: true, failMessage: "")
    }

    static func getSuspiciousObjCClasses() -> [ObjCClassItem] {
        SecurityPresets.default.suspiciousObjCClasses.filter { item in

            if let clazz = objc_getClass(item.className) as? NSObject.Type {
                let selector = Selector(item.selectorName)
                switch item.methodType {
                case .instance:
                    if class_getInstanceMethod(clazz, selector) != nil {
                        return true
                    }
                case .clazz:
                    if class_getClassMethod(clazz, selector) != nil {
                        return true
                    }
                }
            }

            return false
        }
    }
}
