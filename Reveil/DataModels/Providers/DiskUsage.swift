//
//  DiskUsage.swift
//  Reveil
//
//  Created by Lessica on 2023/10/2.
//

import Foundation

final class DiskUsage {
    static let shared = DiskUsage()

    private init() {
        totalDiskSpaceInBytes = Self.getTotalDiskSpaceInBytes()
        freeDiskSpaceInBytes = Self.getFreeDiskSpaceInBytes()
    }

    private static func getTotalDiskSpaceInBytes() -> Int64 {
        if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
           let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value
        {
            space
        } else {
            0
        }
    }

    var totalDiskSpaceInBytes: Int64

    private static func getFreeDiskSpaceInBytes() -> Int64 {
        if let space = try? URL(fileURLWithPath: NSHomeDirectory() as String).resourceValues(forKeys: [URLResourceKey.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage {
            space
        } else {
            0
        }
    }

    var freeDiskSpaceInBytes: Int64

    func reloadData() {
        totalDiskSpaceInBytes = Self.getTotalDiskSpaceInBytes()
        freeDiskSpaceInBytes = Self.getFreeDiskSpaceInBytes()
    }

    var usedDiskSpaceInBytes: Int64 { totalDiskSpaceInBytes - freeDiskSpaceInBytes }
    var usedRatio: Double { Double(usedDiskSpaceInBytes) / Double(totalDiskSpaceInBytes) }
}
