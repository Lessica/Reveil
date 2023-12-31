//
//  IntegrityChecker.swift
//  IOSSecuritySuite
//
//  Created by NikoXu on 2020/8/21.
//  Copyright © 2020 wregula. All rights reserved.
//
// swiftlint:disable line_length large_tuple force_cast trailing_whitespace

import CommonCrypto
import Foundation
import MachO

final class IntegrityChecker {
    // Check if the application has been tampered with the specified checks
    static func amITampered(_ checks: [FileIntegrityCheck]) -> FileIntegrityCheckResult {
        var hitChecks: [FileIntegrityCheck] = []
        var result = false

        for check in checks {
            switch check {
            case let .bundleID(exceptedBundleID):
                if !checkBundleID(exceptedBundleID) {
                    result = true
                    hitChecks.append(check)
                }
            case let .mobileProvision(expectedSha256Value):
                if !checkMobileProvision(expectedSha256Value.lowercased()) {
                    result = true
                    hitChecks.append(check)
                }
            case let .machO(imageName, expectedSha256Value):
                if !checkMachO(imageName, with: expectedSha256Value.lowercased()) {
                    result = true
                    hitChecks.append(check)
                }
            }
        }

        return FileIntegrityCheckResult(result: result, hitChecks: hitChecks)
    }

    private static func checkBundleID(_ expectedBundleID: String) -> Bool {
        checkBundleID(Set(arrayLiteral: expectedBundleID))
    }

    static func checkBundleID(_ expectedBundleIDs: Set<String>) -> Bool {
        if let bid = Bundle(for: Self.self).bundleIdentifier, expectedBundleIDs.contains(bid) {
            return true
        }

        return false
    }

    private static func checkMobileProvision(_ expectedSha256Value: String) -> Bool {
        checkMobileProvision(Set<String>(arrayLiteral: expectedSha256Value))
    }

    static func checkMobileProvision(_ expectedSha256Values: Set<String>) -> Bool {
        guard let path = Bundle(for: Self.self).path(forResource: "embedded", ofType: "mobileprovision"),
              let hashValue = getMobileProvisionProfileHashValue(path: path)
        else { return false }

        return expectedSha256Values.contains(hashValue)
    }

    static func getMobileProvisionProfileHashValue(path: String) -> String? {
        guard FileManager.default.fileExists(atPath: path) else {
            return nil
        }

        guard let data = FileManager.default.contents(atPath: path) else {
            return nil
        }

        // Hash: SHA256
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }

        return Data(hash).hexEncodedString()
    }

    private static func checkMachO(_ imageName: String, with expectedSha256Value: String) -> Bool {
        checkMachO(imageName, with: Set(arrayLiteral: expectedSha256Value))
    }

    static func checkMachO(_ imageName: String?, with expectedSha256Values: Set<String>) -> Bool {
        let target: IntegrityCheckerTarget = if let imageName {
            IntegrityCheckerTarget.customImage(imageName)
        } else {
            .default
        }
        if let hashValue = getMachOFileHashValue(target) {
            return expectedSha256Values.contains(hashValue)
        }
        return false
    }

    static func checkMainMachO(_ expectedSha256Values: Set<String>) -> Bool {
        checkMachO(nil, with: expectedSha256Values)
    }
}

extension IntegrityChecker {
    // Get hash value of Mach-O "__TEXT.__text" data with a specified image target
    static func getMachOFileHashValue(_ target: IntegrityCheckerTarget = .default) -> String? {
        switch target {
        case let .customExecutable(executableURL):
            if let data = try? Data(contentsOf: executableURL) {
                return MachOParse(data: data).getTextSectionDataSHA256Value()
            }
            return nil
        case let .customImage(imageName):
            return MachOParse(imageName: imageName).getTextSectionDataSHA256Value()
        case .main:
            if let url = Bundle.main.executableURL, let data = try? Data(contentsOf: url) {
                return MachOParse(data: data).getTextSectionDataSHA256Value()
            }
            return nil
        case .default:
            return MachOParse().getTextSectionDataSHA256Value()
        }
    }

    // Find runtime paths with a specified image target
    static func findRuntimePaths(_ target: IntegrityCheckerTarget = .default) -> [String]? {
        switch target {
        case let .customExecutable(executableURL):
            if let data = try? Data(contentsOf: executableURL) {
                return MachOParse(data: data).findRuntimePaths()
            }
            return nil
        case let .customImage(imageName):
            return MachOParse(imageName: imageName).findRuntimePaths()
        case .main:
            if let url = Bundle.main.executableURL, let data = try? Data(contentsOf: url) {
                return MachOParse(data: data).findRuntimePaths()
            }
            return nil
        case .default:
            return MachOParse().findRuntimePaths()
        }
    }

    // Find loaded dylib with a specified image target
    static func findLoadedDylibs(_ target: IntegrityCheckerTarget = .default) -> [String]? {
        switch target {
        case let .customExecutable(executableURL):
            if let data = try? Data(contentsOf: executableURL) {
                return MachOParse(data: data).findLoadedDylibs()
            }
            return nil
        case let .customImage(imageName):
            return MachOParse(imageName: imageName).findLoadedDylibs()
        case .main:
            if let url = Bundle.main.executableURL, let data = try? Data(contentsOf: url) {
                return MachOParse(data: data).findLoadedDylibs()
            }
            return nil
        case .default:
            return MachOParse().findLoadedDylibs()
        }
    }
}

// MARK: - MachOParse

private struct SectionInfo {
    var section: UnsafePointer<section_64>
    var addr: UInt64
    var offset: UInt64
}

private struct SegmentInfo {
    var segment: UnsafePointer<segment_command_64>
    var addr: UInt64
    var offset: UInt64
}

// Convert (Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8) to String
@inline(__always)
private func convert16BitInt8TupleToString(int8Tuple: (Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8)) -> String {
    let mirror = Mirror(reflecting: int8Tuple)

    return mirror.children.map {
        String(UnicodeScalar(UInt8($0.value as! Int8)))
    }.joined().replacingOccurrences(of: "\0", with: "")
}

private class MachOParse {
    private var data: UnsafeMutableBufferPointer<UInt8>?
    private var base: UnsafePointer<mach_header>?
    private var slide: Int?

    init() {
        base = _dyld_get_image_header(0)
        slide = _dyld_get_image_vmaddr_slide(0)
    }

    init(header: UnsafePointer<mach_header>, slide: Int) {
        base = header
        self.slide = slide
    }

    init(imageName: String) {
        for index in 0 ..< _dyld_image_count() {
            if let cImgName = _dyld_get_image_name(index), String(cString: cImgName).contains(imageName),
               let header = _dyld_get_image_header(index)
            {
                base = header
                slide = _dyld_get_image_vmaddr_slide(index)
            }
        }
    }

    init(data: Data) {
        let uint8Ptr = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: data.count)
        _ = uint8Ptr.initialize(from: data)
        self.data = uint8Ptr
        base = uint8Ptr.withMemoryRebound(to: mach_header.self) { buffer in
            UnsafePointer(buffer.baseAddress)
        }
        slide = nil
    }

    deinit {
        if let data {
            data.deinitialize()
            data.deallocate()
        }
    }

    private func vm2real(_ vmaddr: UInt64) -> UInt64 {
        guard let slide else {
            return vmaddr
        }

        return UInt64(slide) + vmaddr
    }

    func findRuntimePaths() -> [String]? {
        guard let header = base else {
            return nil
        }

        guard var curCmd = UnsafeMutablePointer<segment_command_64>(bitPattern: UInt(bitPattern: header) + UInt(MemoryLayout<mach_header_64>.size)) else {
            return nil
        }

        var array: [String] = Array()
        var segCmd: UnsafeMutablePointer<segment_command_64>!

        for _ in 0 ..< header.pointee.ncmds {
            segCmd = curCmd
            if segCmd.pointee.cmd == LC_RPATH {
                if let rpath = UnsafeMutableRawPointer(segCmd)?.assumingMemoryBound(to: rpath_command.self),
                   let cName = UnsafeMutableRawPointer(rpath)?.advanced(by: Int(rpath.pointee.path.offset)).assumingMemoryBound(to: CChar.self)
                {
                    let rpathName = String(cString: cName)
                    array.append(rpathName)
                }
            }

            curCmd = UnsafeMutableRawPointer(curCmd).advanced(by: Int(curCmd.pointee.cmdsize)).assumingMemoryBound(to: segment_command_64.self)
        }

        return array
    }

    func findLoadedDylibs() -> [String]? {
        guard let header = base else {
            return nil
        }

        guard var curCmd = UnsafeMutablePointer<segment_command_64>(bitPattern: UInt(bitPattern: header) + UInt(MemoryLayout<mach_header_64>.size)) else {
            return nil
        }

        var array: [String] = Array()
        var segCmd: UnsafeMutablePointer<segment_command_64>!

        for _ in 0 ..< header.pointee.ncmds {
            segCmd = curCmd
            if segCmd.pointee.cmd == LC_LOAD_DYLIB || segCmd.pointee.cmd == LC_LOAD_WEAK_DYLIB {
                if let dylib = UnsafeMutableRawPointer(segCmd)?.assumingMemoryBound(to: dylib_command.self),
                   let cName = UnsafeMutableRawPointer(dylib)?.advanced(by: Int(dylib.pointee.dylib.name.offset)).assumingMemoryBound(to: CChar.self)
                {
                    let dylibName = String(cString: cName)
                    array.append(dylibName)
                }
            }

            curCmd = UnsafeMutableRawPointer(curCmd).advanced(by: Int(curCmd.pointee.cmdsize)).assumingMemoryBound(to: segment_command_64.self)
        }

        return array
    }

    func findSegment(_ segname: String) -> SegmentInfo? {
        guard let header = base else {
            return nil
        }

        guard var curCmd = UnsafeMutablePointer<segment_command_64>(bitPattern: UInt(bitPattern: header) + UInt(MemoryLayout<mach_header_64>.size)) else {
            return nil
        }

        var segCmd: UnsafeMutablePointer<segment_command_64>!

        for _ in 0 ..< header.pointee.ncmds {
            segCmd = curCmd
            if segCmd.pointee.cmd == LC_SEGMENT_64 {
                let segName = convert16BitInt8TupleToString(int8Tuple: segCmd.pointee.segname)

                if segname == segName {
                    let vmaddr = vm2real(segCmd.pointee.vmaddr)
                    let segmentInfo = SegmentInfo(
                        segment: segCmd, addr: vmaddr, offset: segCmd.pointee.fileoff
                    )
                    return segmentInfo
                }
            }

            curCmd = UnsafeMutableRawPointer(curCmd).advanced(by: Int(curCmd.pointee.cmdsize)).assumingMemoryBound(to: segment_command_64.self)
        }

        return nil
    }

    func findSection(_ segname: String, secname: String) -> SectionInfo? {
        guard let header = base else {
            return nil
        }

        guard var curCmd = UnsafeMutablePointer<segment_command_64>(bitPattern: UInt(bitPattern: header) + UInt(MemoryLayout<mach_header_64>.size)) else {
            return nil
        }

        var segCmd: UnsafeMutablePointer<segment_command_64>!

        for _ in 0 ..< header.pointee.ncmds {
            segCmd = curCmd
            if segCmd.pointee.cmd == LC_SEGMENT_64 {
                let segName = convert16BitInt8TupleToString(int8Tuple: segCmd.pointee.segname)

                if segname == segName {
                    for sectionID in 0 ..< segCmd.pointee.nsects {
                        guard let sect = UnsafeMutablePointer<section_64>(bitPattern: UInt(bitPattern: curCmd) + UInt(MemoryLayout<segment_command_64>.size) + UInt(sectionID)) else {
                            return nil
                        }

                        let secName = convert16BitInt8TupleToString(int8Tuple: sect.pointee.sectname)

                        if secName == secname {
                            let addr = vm2real(sect.pointee.addr)
                            let sectionInfo = SectionInfo(
                                section: sect, addr: addr, offset: UInt64(sect.pointee.offset)
                            )
                            return sectionInfo
                        }
                    }
                }
            }

            curCmd = UnsafeMutableRawPointer(curCmd).advanced(by: Int(curCmd.pointee.cmdsize)).assumingMemoryBound(to: segment_command_64.self)
        }

        return nil
    }

    func getTextSectionDataSHA256Value() -> String? {
        guard let sectionInfo = findSection(SEG_TEXT, secname: SECT_TEXT) else {
            return nil
        }

        let startAddr: UnsafeMutablePointer<UInt8>?
        if let data {
            startAddr = data.baseAddress?.advanced(by: Int(sectionInfo.offset))
        } else {
            startAddr = UnsafeMutablePointer<UInt8>(bitPattern: Int(sectionInfo.addr))
        }

        let size = sectionInfo.section.pointee.size

        // Hash: SHA256
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        if let startAddr {
            _ = CC_SHA256(startAddr, CC_LONG(size), &hash)
        }

        return Data(hash).hexEncodedString()
    }
}

private extension Data {
    func hexEncodedString() -> String {
        map { String(format: "%02hhx", $0) }.joined()
    }
}
