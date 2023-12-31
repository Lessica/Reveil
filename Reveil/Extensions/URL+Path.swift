//
//  URL+Path.swift
//  Reveil
//
//  Created by Lessica on 7/27/20.
//

import Foundation

let UID_MOBILE = 501
let GID_MOBILE = 501
let UID_ROOT = 0
let GID_WHEEL = 0

extension String {
    var url: URL { URL(fileURLWithPath: self) }
    var absoluteURL: URL {
        if hasPrefix("/") {
            return URL(fileURLWithPath: self)
        }
        return URL(fileURLWithPath: self, relativeTo: URL.currentDirectoryURL)
    }

    var fileURL: URL { URL(fileURLWithPath: self, isDirectory: false) }
    var absoluteFileURL: URL {
        if hasPrefix("/") {
            return URL(fileURLWithPath: self, isDirectory: false)
        }
        return URL(fileURLWithPath: self, isDirectory: false, relativeTo: URL.currentDirectoryURL)
    }

    var directoryURL: URL { URL(fileURLWithPath: self, isDirectory: true) }
    var absoluteDirectoryURL: URL {
        if hasPrefix("/") {
            return URL(fileURLWithPath: self, isDirectory: true)
        }
        return URL(fileURLWithPath: self, isDirectory: true, relativeTo: URL.currentDirectoryURL)
    }
}

public extension [String] {
    func localizedStandardSorted() -> [Element] {
        sorted(by: { $0.localizedStandardCompare($1) == .orderedAscending })
    }
}

extension URL {
    enum OutputError: Error {
        case invalidPropertyList
        case invalidJSON
    }

    static var currentDirectoryURL: URL { URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true) }

    var itemExists: Bool {
        FileManager.default.fileExists(atPath: path)
    }

    var itemOwnerAccountID: Int16? {
        (try? FileManager.default.attributesOfItem(atPath: path)[FileAttributeKey.ownerAccountID] as? NSNumber)?.int16Value
    }

    var itemGroupAccountID: Int16? {
        (try? FileManager.default.attributesOfItem(atPath: path)[FileAttributeKey.groupOwnerAccountID] as? NSNumber)?.int16Value
    }

    var itemPermissions: Int16? {
        (try? FileManager.default.attributesOfItem(atPath: path)[FileAttributeKey.posixPermissions] as? NSNumber)?.int16Value
    }

    var itemCreatedAt: Date? {
        (try? FileManager.default.attributesOfItem(atPath: path)[FileAttributeKey.creationDate] as? NSDate) as Date?
    }

    var itemModifiedAt: Date? {
        (try? FileManager.default.attributesOfItem(atPath: path)[FileAttributeKey.modificationDate] as? NSDate) as Date?
    }

    var isRegularFile: Bool {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: path) else {
            return false
        }
        guard let type = attributes[FileAttributeKey.type] as? FileAttributeType else {
            return false
        }
        return type == .typeRegular
    }

    var isDirectory: Bool {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: path) else {
            return false
        }
        guard let type = attributes[FileAttributeKey.type] as? FileAttributeType else {
            return false
        }
        return type == .typeDirectory
    }

    var isSymbolicLink: Bool {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: path) else {
            return false
        }
        guard let type = attributes[FileAttributeKey.type] as? FileAttributeType else {
            return false
        }
        return type == .typeSymbolicLink
    }

    var isReadable: Bool {
        FileManager.default.isReadableFile(atPath: path)
    }

    var isWritable: Bool {
        FileManager.default.isWritableFile(atPath: path)
    }

    var isExecutable: Bool {
        FileManager.default.isExecutableFile(atPath: path)
    }

    var isDeletable: Bool {
        FileManager.default.isDeletableFile(atPath: path)
    }

    /// check if the URL is a directory and if it is reachable
    func isDirectoryAndReachable() throws -> Bool {
        guard try resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true else {
            return false
        }
        return try checkResourceIsReachable()
    }

    /// returns total allocated size of a the directory including its subFolders or not
    func directoryTotalAllocatedSize(includingSubfolders: Bool = false) throws -> Int? {
        guard try isDirectoryAndReachable() else { return nil }
        if includingSubfolders {
            guard
                let urls = FileManager.default.enumerator(at: self, includingPropertiesForKeys: nil)?.allObjects as? [URL] else { return nil }
            return try urls.lazy.reduce(0) {
                try ($1.resourceValues(forKeys: [.totalFileAllocatedSizeKey]).totalFileAllocatedSize ?? 0) + $0
            }
        }
        return try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil).lazy.reduce(0) {
            try ($1.resourceValues(forKeys: [.totalFileAllocatedSizeKey])
                .totalFileAllocatedSize ?? 0) + $0
        }
    }

    /// returns the directory total size on disk
    func sizeOnDisk() throws -> String? {
        guard let size = try directoryTotalAllocatedSize(includingSubfolders: true) else { return nil }
        URL.byteCountFormatter.countStyle = .file
        guard let byteCount = URL.byteCountFormatter.string(for: size) else { return nil }
        return byteCount + " on disk"
    }

    private static let byteCountFormatter = ByteCountFormatter()

    var fileExists: Bool {
        var isDirectory = ObjCBool(booleanLiteral: false)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && !isDirectory.boolValue
    }

    var directoryExists: Bool {
        var isDirectory = ObjCBool(booleanLiteral: false)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }

    var directoryContents: [String]? { try? FileManager.default.contentsOfDirectory(atPath: path).localizedStandardSorted() }
    var directoryContentURLs: [URL]? { directoryContents?.map { self.appendingPathComponent($0) } }

    var propertyListContents: Any? { try? PropertyListSerialization.propertyList(from: Data(contentsOf: self), options: [], format: nil) }
    var JSONContents: Any? { try? JSONSerialization.jsonObject(with: Data(contentsOf: self), options: []) }
    func writePropertyList(_ object: Any) throws {
        guard PropertyListSerialization.propertyList(object, isValidFor: .binary) else {
            throw OutputError.invalidPropertyList
        }
        let data = try PropertyListSerialization.data(fromPropertyList: object, format: .binary, options: 0)
        try data.write(to: self, options: [.withoutOverwriting])
    }

    func writeJSON(_ object: Any, options opt: JSONSerialization.WritingOptions = []) throws {
        guard JSONSerialization.isValidJSONObject(object) else {
            throw OutputError.invalidJSON
        }
        let data = try JSONSerialization.data(withJSONObject: object, options: opt)
        try data.write(to: self, options: [.withoutOverwriting])
    }

    func hasExtension(_ ext: String) -> Bool { pathExtension == ext }
    func hasExtensions(_ exts: [String]) -> Bool { exts.contains(pathExtension) }
    func deletingPathExtensions(_ exts: [String]) -> URL {
        let allSlices = lastPathComponent.split(separator: ".").map { String($0) }
        var slices = [String]()
        var skipAll = false
        for slice in allSlices.reversed() {
            if !skipAll, exts.contains(slice) {
                continue
            } else {
                slices.append(slice)
                skipAll = true
            }
        }
        return deletingLastPathComponent()
            .appendingPathComponent(
                slices.reversed()
                    .joined(separator: "."))
    }

    func takePlace(contents: Data = Data(), overwrite: Bool = false, withIntermediateDirectories createIntermediates: Bool = false) throws {
        if createIntermediates {
            try deletingLastPathComponent()
                .ensureDirectoryExists(
                    owner: Int16(getuid()),
                    groupOwner: Int16(getgid()),
                    permissions: Int16(0o755),
                    withIntermediateDirectories: createIntermediates
                )
        }
        if !itemExists || overwrite {
            try contents.write(to: self, options: overwrite ? [.atomic] : [.withoutOverwriting])
        }
    }

    func ensureUserPermissions(_ permissions: Int16? = nil) throws {
        if let permissions {
            try ensure(owner: Int16(UID_MOBILE), groupOwner: Int16(GID_MOBILE), permissions: permissions)
        } else if directoryExists {
            try ensure(owner: Int16(UID_MOBILE), groupOwner: Int16(GID_MOBILE), permissions: Int16(0o755))
        } else /* fileExists */ {
            try ensure(owner: Int16(UID_MOBILE), groupOwner: Int16(GID_MOBILE), permissions: Int16(0o644))
        }
    }

    func ensureUserDirectoryExists(permissions: Int16 = Int16(0o755), withIntermediateDirectories createIntermediates: Bool = false) throws {
        try ensureDirectoryExists(owner: Int16(UID_MOBILE), groupOwner: Int16(GID_MOBILE), permissions: permissions, withIntermediateDirectories: createIntermediates)
    }

    func ensure(owner: Int16, groupOwner: Int16, permissions: Int16 = Int16(0o755)) throws {
        try FileManager.default.setAttributes([
            FileAttributeKey.ownerAccountID: NSNumber(value: owner),
            FileAttributeKey.groupOwnerAccountID: NSNumber(value: groupOwner),
            FileAttributeKey.posixPermissions: NSNumber(value: permissions),
        ], ofItemAtPath: path)
    }

    func ensureDirectoryExists(owner: Int16, groupOwner: Int16, permissions: Int16 = Int16(0o755), withIntermediateDirectories createIntermediates: Bool = false) throws {
        if !itemExists {
            try FileManager.default.createDirectory(at: self, withIntermediateDirectories: createIntermediates, attributes: [
                FileAttributeKey.ownerAccountID: NSNumber(value: owner),
                FileAttributeKey.groupOwnerAccountID: NSNumber(value: groupOwner),
                FileAttributeKey.posixPermissions: NSNumber(value: permissions),
            ])
        } else {
            try ensure(owner: owner, groupOwner: groupOwner, permissions: permissions)
        }
    }

    func ensureOwnersAndPermissionsSameAs(_ url: URL) throws {
        let dstAttrs = try FileManager.default.attributesOfItem(atPath: url.path)
        try ensure(
            owner: (dstAttrs[FileAttributeKey.ownerAccountID] as! NSNumber).int16Value,
            groupOwner: (dstAttrs[FileAttributeKey.groupOwnerAccountID] as! NSNumber).int16Value,
            permissions: (dstAttrs[FileAttributeKey.posixPermissions] as! NSNumber).int16Value
        )
    }

    func ensureParentDirectoryExists() throws {
        guard !itemExists else { return }
        let parentDirectoryURL = deletingLastPathComponent()
        if !parentDirectoryURL.directoryExists {
            try parentDirectoryURL.ensureDirectoryExists(
                owner: Int16(UID_ROOT),
                groupOwner: Int16(GID_WHEEL),
                permissions: Int16(0o755),
                withIntermediateDirectories: true
            )
        }
    }

    func removeIfExists() throws {
        if itemExists {
            try FileManager.default.removeItem(at: self)
        }
    }

    func remove() throws {
        try FileManager.default.removeItem(at: self)
    }

    func removeContents(ifDeletable deletableOnly: Bool = false, skipIfNotDeletable skip: Bool = false) throws {
        let itemURLs = try FileManager.default.contentsOfDirectory(
            at: self,
            includingPropertiesForKeys: nil,
            options: [.skipsSubdirectoryDescendants]
        )

        try itemURLs.forEach {
            if deletableOnly, !$0.isDeletable {
                return
            }
            if skip {
                try? $0.remove()
            } else {
                try $0.remove()
            }
        }
    }

    func duplicate(to url: URL) throws {
        try FileManager.default.copyItem(at: self, to: url)
    }

    func relativePath(from base: URL) -> String? {
        // Ensure that both URLs represent files:
        guard isFileURL, base.isFileURL else {
            return nil
        }

        // Remove/replace "." and "..", make paths absolute:
        let destComponents = standardized.resolvingSymlinksInPath().pathComponents
        let baseComponents = base.standardized.resolvingSymlinksInPath().pathComponents

        // Find number of common path components:
        var i = 0
        while i < destComponents.count, i < baseComponents.count,
              destComponents[i] == baseComponents[i]
        {
            i += 1
        }

        // Build relative path:
        var relComponents = Array(repeating: "..", count: baseComponents.count - i)
        relComponents.append(contentsOf: destComponents[i...])
        return relComponents.joined(separator: "/")
    }

    func createSymlink(to path: String) throws {
        try FileManager.default.createSymbolicLink(atPath: self.path, withDestinationPath: path)
    }

    func withReadableFileHandle<ResultType>(_ block: (UnsafeMutablePointer<FILE>?) throws -> ResultType) rethrows -> ResultType {
        try withUnsafeFileSystemRepresentation { pathPtr in
            let fp = fopen(pathPtr, "rb")
            defer {
                if let fp {
                    fclose(fp)
                }
            }
            return try block(fp)
        }
    }
}
