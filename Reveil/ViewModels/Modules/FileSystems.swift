//
//  FileSystems.swift
//  Reveil
//
//  Created by Lessica on 2023/10/6.
//

import Foundation
import OrderedCollections

final class FileSystems: Module {
    static let shared = FileSystems()

    private init() {
        items = []
        reloadData()
    }

    let moduleName = NSLocalizedString("FILE_SYSTEMS", comment: "File Systems")

    private let gBufferFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowedUnits = [.useKB, .useMB, .useGB, .useTB]
        return formatter
    }()

    private let gLargeNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.allowsFloats = false
        return formatter
    }()

    private func attributeDescriptions(_ flags: UInt32) -> [BasicEntry] {
        var descs = [FileSystem.Attribute]()
        if (flags & UInt32(MNT_RDONLY)) != 0 {
            descs.append(FileSystem.Attribute(name: "MNT_RDONLY", description: NSLocalizedString("MNT_RDONLY", comment: "A read-only file system")))
        }
        if (flags & UInt32(MNT_SYNCHRONOUS)) != 0 {
            descs.append(FileSystem.Attribute(name: "MNT_SYNCHRONOUS", description: NSLocalizedString("MNT_SYNCHRONOUS", comment: "File system is written to synchronously")))
        }
        if (flags & UInt32(MNT_NOEXEC)) != 0 {
            descs.append(FileSystem.Attribute(name: "MNT_NOEXEC", description: NSLocalizedString("MNT_NOEXEC", comment: "Can't exec from file system")))
        }
        if (flags & UInt32(MNT_NOSUID)) != 0 {
            descs.append(FileSystem.Attribute(name: "MNT_NOSUID", description: NSLocalizedString("MNT_NOSUID", comment: "Setuid bits are not honored on this file system")))
        }
        if (flags & UInt32(MNT_NODEV)) != 0 {
            descs.append(FileSystem.Attribute(name: "MNT_NODEV", description: NSLocalizedString("MNT_NODEV", comment: "Don't interpret special files")))
        }
        if (flags & UInt32(MNT_UNION)) != 0 {
            descs.append(FileSystem.Attribute(name: "MNT_UNION", description: NSLocalizedString("MNT_UNION", comment: "Union with underlying file system")))
        }
        if (flags & UInt32(MNT_ASYNC)) != 0 {
            descs.append(FileSystem.Attribute(name: "MNT_ASYNC", description: NSLocalizedString("MNT_ASYNC", comment: "File system written to asynchronously")))
        }
        if (flags & UInt32(MNT_CPROTECT)) != 0 {
            descs.append(FileSystem.Attribute(name: "MNT_CPROTECT", description: NSLocalizedString("MNT_CPROTECT", comment: "File system supports content protection")))
        }
        if (flags & UInt32(MNT_EXPORTED)) != 0 {
            descs.append(FileSystem.Attribute(name: "MNT_EXPORTED", description: NSLocalizedString("MNT_EXPORTED", comment: "File system is exported")))
        }
        if (flags & UInt32(MNT_REMOVABLE)) != 0 {
            descs.append(FileSystem.Attribute(name: "MNT_REMOVABLE", description: NSLocalizedString("MNT_REMOVABLE", comment: "File system can be removed from the system by user")))
        }
        if (flags & UInt32(MNT_QUARANTINE)) != 0 {
            descs.append(FileSystem.Attribute(name: "MNT_QUARANTINE", description: NSLocalizedString("MNT_QUARANTINE", comment: "File system is quarantined")))
        }
        if (flags & UInt32(MNT_LOCAL)) != 0 {
            descs.append(FileSystem.Attribute(name: "MNT_LOCAL", description: NSLocalizedString("MNT_LOCAL", comment: "File system is stored locally")))
        }
        if (flags & UInt32(MNT_QUOTA)) != 0 {
            descs.append(FileSystem.Attribute(name: "MNT_QUOTA", description: NSLocalizedString("MNT_QUOTA", comment: "Quotas are enabled on this file system")))
        }
        if (flags & UInt32(MNT_ROOTFS)) != 0 {
            descs.append(FileSystem.Attribute(name: "MNT_ROOTFS", description: NSLocalizedString("MNT_ROOTFS", comment: "This file system is the root of the file system")))
        }
        if (flags & UInt32(MNT_DOVOLFS)) != 0 {
            descs.append(FileSystem.Attribute(name: "MNT_DOVOLFS", description: NSLocalizedString("MNT_DOVOLFS", comment: "File system supports volfs")))
        }
        if (flags & UInt32(MNT_DONTBROWSE)) != 0 {
            descs.append(FileSystem.Attribute(name: "MNT_DONTBROWSE", description: NSLocalizedString("MNT_DONTBROWSE", comment: "File system is not appropriate path to user data")))
        }
        if (flags & UInt32(MNT_IGNORE_OWNERSHIP)) != 0 || (flags & UInt32(MNT_UNKNOWNPERMISSIONS)) != 0 {
            descs.append(FileSystem.Attribute(name: "MNT_IGNORE_OWNERSHIP", description: NSLocalizedString("MNT_IGNORE_OWNERSHIP", comment: "VFS will ignore ownership information on file system objects")))
        }
        if (flags & UInt32(MNT_AUTOMOUNTED)) != 0 {
            descs.append(FileSystem.Attribute(name: "MNT_AUTOMOUNTED", description: NSLocalizedString("MNT_AUTOMOUNTED", comment: "File system was mounted by automounter")))
        }
        if (flags & UInt32(MNT_JOURNALED)) != 0 {
            descs.append(FileSystem.Attribute(name: "MNT_JOURNALED", description: NSLocalizedString("MNT_JOURNALED", comment: "File system is journaled")))
        }
        if (flags & UInt32(MNT_NOUSERXATTR)) != 0 {
            descs.append(FileSystem.Attribute(name: "MNT_NOUSERXATTR", description: NSLocalizedString("MNT_NOUSERXATTR", comment: "Don't allow user extended attributes")))
        }
        if (flags & UInt32(MNT_DEFWRITE)) != 0 {
            descs.append(FileSystem.Attribute(name: "MNT_DEFWRITE", description: NSLocalizedString("MNT_DEFWRITE", comment: "File system should defer writes")))
        }
        if (flags & UInt32(MNT_MULTILABEL)) != 0 {
            descs.append(FileSystem.Attribute(name: "MNT_MULTILABEL", description: NSLocalizedString("MNT_MULTILABEL", comment: "MAC support for individual labels")))
        }
        if (flags & UInt32(MNT_NOFOLLOW)) != 0 {
            descs.append(FileSystem.Attribute(name: "MNT_NOFOLLOW", description: NSLocalizedString("MNT_NOFOLLOW", comment: "Don't follow symlink when resolving mount point")))
        }
        if (flags & UInt32(MNT_NOATIME)) != 0 {
            descs.append(FileSystem.Attribute(name: "MNT_NOATIME", description: NSLocalizedString("MNT_NOATIME", comment: "Disable update of file access time")))
        }
        if (flags & UInt32(MNT_SNAPSHOT)) != 0 {
            descs.append(FileSystem.Attribute(name: "MNT_SNAPSHOT", description: NSLocalizedString("MNT_SNAPSHOT", comment: "The mount is a snapshot")))
        }
        if (flags & UInt32(MNT_STRICTATIME)) != 0 {
            descs.append(FileSystem.Attribute(name: "MNT_STRICTATIME", description: NSLocalizedString("MNT_STRICTATIME", comment: "Enable strict update of file access time")))
        }
        return descs.map { BasicEntry(key: .Custom(name: $0.name), name: $0.description, value: String()) }
    }

    var items: [FileSystem]

    func reloadData() {
        items = OrderedSet(System.mountedVolumes()
            .compactMap { String(cString: withUnsafeBytes(of: $0.f_mntonname) { ptr in [UInt8](ptr) }) })
            .map { FileSystem(path: $0) }
    }

    func entries(fs: FileSystem) -> [BasicEntry] {
        guard let volume = System.mountedVolume(url: URL(fileURLWithPath: fs.path, isDirectory: true)) else {
            return []
        }

        var items = [BasicEntry]()
        items.append(BasicEntry(
            key: .MountPoint(path: fs.path),
            name: NSLocalizedString("MOUNT_POINT", comment: "Mount Point"),
            value: fs.path
        ))
        items.append(BasicEntry(
            key: .BlockSize(path: fs.path),
            name: NSLocalizedString("BLOCK_SIZE", comment: "Block Size"),
            value: gBufferFormatter.string(fromByteCount: Int64(volume.f_bsize))
        ))
        items.append(BasicEntry(
            key: .OptimalTransferSize(path: fs.path),
            name: NSLocalizedString("OPTIMAL_TRANSFER_SIZE", comment: "Optimal Transfer Size"),
            value: gBufferFormatter.string(fromByteCount: Int64(volume.f_iosize))
        ))
        items.append(BasicEntry(
            key: .FileSystemBlocks(path: fs.path),
            name: NSLocalizedString("BLOCKS", comment: "Blocks"),
            value: String(format: "%llu (%@)", volume.f_blocks, gBufferFormatter.string(fromByteCount: Int64(volume.f_blocks * UInt64(volume.f_bsize))))
        ))
        items.append(BasicEntry(
            key: .FileSystemFreeBlocks(path: fs.path),
            name: NSLocalizedString("FREE_BLOCKS", comment: "Free Blocks"),
            value: String(format: "%llu (%@)", volume.f_bfree, gBufferFormatter.string(fromByteCount: Int64(volume.f_bfree * UInt64(volume.f_bsize))))
        ))
        items.append(BasicEntry(
            key: .FileSystemAvailableBlocks(path: fs.path),
            name: NSLocalizedString("AVAIL_BLOCKS", comment: "Available Blocks"),
            value: String(format: "%llu (%@)", volume.f_bavail, gBufferFormatter.string(fromByteCount: Int64(volume.f_bavail * UInt64(volume.f_bsize))))
        ))
        items.append(BasicEntry(
            key: .FileSystemNodes(path: fs.path),
            name: NSLocalizedString("NODES", comment: "Nodes"),
            value: gLargeNumberFormatter.string(from: NSNumber(value: Int64(volume.f_files))) ?? BasicEntry.unknownValue
        ))
        items.append(BasicEntry(
            key: .FileSystemFreeNodes(path: fs.path),
            name: NSLocalizedString("FREE_NODES", comment: "Free Nodes"),
            value: gLargeNumberFormatter.string(from: NSNumber(value: Int64(volume.f_ffree))) ?? BasicEntry.unknownValue
        ))
        items.append(BasicEntry(
            key: .FileSystemIdentifier(path: fs.path),
            name: NSLocalizedString("IDENTIFIER", comment: "Identifier"),
            value: String(format: "%d, %d", volume.f_fsid.val.0, volume.f_fsid.val.1)
        ))
        items.append(BasicEntry(
            key: .FileSystemOwner(path: fs.path),
            name: NSLocalizedString("OWNER", comment: "Owner"),
            value: String(format: "%d (%@)", volume.f_owner, System.userName(uid: volume.f_owner) ?? BasicEntry.unknownValue)
        ))
        items.append(BasicEntry(
            key: .FileSystemType(path: fs.path),
            name: NSLocalizedString("TYPE", comment: "Type"),
            value: String(cString: withUnsafeBytes(of: volume.f_fstypename) { ptr in [UInt8](ptr) })
        ))

        let attrEntries = attributeDescriptions(volume.f_flags)
        if !attrEntries.isEmpty {
            items.append(BasicEntry(
                key: .FileSystemAttributes(path: fs.path),
                name: NSLocalizedString("ATTRIBUTES", comment: "Attributes"),
                value: String(),
                children: attrEntries
            ))
        }

        items.append(BasicEntry(
            key: .FileSystemFlavor(path: fs.path),
            name: NSLocalizedString("FLAVOR", comment: "Flavor"),
            value: String(format: "%u", volume.f_fssubtype)
        ))
        items.append(BasicEntry(
            key: .FileSystemDevice(path: fs.path),
            name: NSLocalizedString("DEVICE", comment: "Device"),
            value: String(cString: withUnsafeBytes(of: volume.f_mntfromname) { ptr in [UInt8](ptr) })
        ))

        return items
    }

    var basicEntries: [BasicEntry] { items.flatMap { entries(fs: $0) } }
    let usageEntry: UsageEntry<Double>? = nil

    func updateEntries() {}

    let updatableEntryKeys: [EntryKey] = [
        .FileSystems,
    ]

    func basicEntry(key: EntryKey, style _: ValueStyle = .detailed) -> BasicEntry? {
        switch key {
        case .FileSystems:
            return BasicEntry(
                key: .FileSystems,
                name: NSLocalizedString("NUMBER_OF_FILE_SYSTEMS", comment: "Number of File Systems"),
                value: gLargeNumberFormatter.string(from: NSNumber(value: items.count)) ?? BasicEntry.unknownValue
            )
        default:
            break
        }
        return nil
    }

    func updateBasicEntry(_ entry: BasicEntry, style _: ValueStyle = .detailed) {
        switch entry.key {
        case .FileSystems:
            entry.value = gLargeNumberFormatter.string(from: NSNumber(value: items.count)) ?? BasicEntry.unknownValue
        default:
            break
        }
    }

    func usageEntry(key _: EntryKey, style _: ValueStyle = .detailed) -> UsageEntry<Double>? { nil }

    func updateUsageEntry(_: UsageEntry<Double>, style _: ValueStyle) {}

    func trafficEntryIO(key _: EntryKey, style _: ValueStyle) -> TrafficEntryIO? { nil }

    func updateTrafficEntryIO(_: TrafficEntryIO, style _: ValueStyle) {}
}
