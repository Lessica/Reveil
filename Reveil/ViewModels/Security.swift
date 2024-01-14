//
//  Security.swift
//  Reveil
//
//  Created by Lessica on 2023/10/25.
//

import Darwin
import Foundation
import MachO
import OrderedCollections
import ZIPFoundation

import library_stub

private let VM_REGION_SUBMAP_INFO_COUNT_64: mach_msg_type_number_t =
    UInt32(MemoryLayout<vm_region_submap_info_data_64_t>.size / MemoryLayout<natural_t>.size)

private let VFS_DFLT_ATTR_VOL = attrgroup_t(ATTR_VOL_FSTYPE | ATTR_VOL_FSTYPENAME | ATTR_VOL_SIGNATURE | ATTR_VOL_SIZE |
    ATTR_VOL_SPACEFREE | ATTR_VOL_QUOTA_SIZE | ATTR_VOL_RESERVED_SIZE |
    ATTR_VOL_SPACEAVAIL | ATTR_VOL_MINALLOCATION |
    ATTR_VOL_ALLOCATIONCLUMP | ATTR_VOL_IOBLOCKSIZE |
    ATTR_VOL_MOUNTPOINT | ATTR_VOL_MOUNTFLAGS |
    ATTR_VOL_MOUNTEDDEVICE | ATTR_VOL_CAPABILITIES |
    ATTR_VOL_ATTRIBUTES | ATTR_VOL_ENCODINGSUSED)

final class Security: ObservableObject, StaticEntryProvider, Explainable {
    static let shared = Security()

    var description: String {
        NSLocalizedString("SECURITY", comment: "Security")
    }

    var moduleName: String {
        description
    }

    @Published var basicEntries: [BasicEntry]
    @Published var usageEntry: UsageEntry<Double>? = nil

    @Published var isLoading: Bool
    @Published var isInsecure: Bool

    private init() {
        basicEntries = []
        isLoading = false
        isInsecure = false
        reloadData()
    }

    private func hasInsecureCheck(_ checks: [SecurityCheck]) -> Bool {
        checks.first { $0.isFailed } != nil
    }

    func reloadData() {
        guard !isLoading else {
            return
        }

        isLoading = true

        #if os(iOS)
            _ = suspiciousURLSchemes
        #endif
        DispatchQueue.global(qos: .utility).async {
            let performedCases = SecurityCheck.allCases.map { $0.perform() }
            let groupedCases = Dictionary(grouping: performedCases) { $0.status }
            let allCases = (groupedCases[.failed] ?? []) + (groupedCases[.passed] ?? []) + (groupedCases[.unchanged] ?? [])

            let performedEntries = allCases.map { $0.entry() }
            let groupedEntries = Dictionary(grouping: performedEntries) { $0.children?.isEmpty ?? true }
            let allEntries = (groupedEntries[false] ?? []) + (groupedEntries[true] ?? [])

            DispatchQueue.main.async {
                self.basicEntries.removeAll(keepingCapacity: true)
                self.basicEntries.append(contentsOf: allEntries)
                self.isInsecure = self.hasInsecureCheck(performedCases)
                self.isLoading = false
            }
        }
    }

    private lazy var currentBundlePath: String = Bundle(for: Self.self).bundlePath

    private lazy var currentBundleURL: URL = Bundle(for: Self.self).bundleURL

    private lazy var currentExecutablePath: String? = {
        var pathSize = PATH_MAX
        let pathPtr = UnsafeMutablePointer<CChar>.allocate(capacity: Int(pathSize))
        let path: String?
        if _NSGetExecutablePath(pathPtr, &pathSize) == 0 {
            path = String(cString: pathPtr)
        } else {
            path = Bundle(for: Self.self).executablePath
        }
        pathPtr.deallocate()
        return path
    }()

    private lazy var currentExecutableURL: URL? = {
        guard let currentExecutablePath else {
            return nil
        }
        return URL(fileURLWithPath: currentExecutablePath)
    }()

    private lazy var currentRuntimePaths: [String] = {
        #if arch(arm64)
            guard let currentExecutableURL else {
                return []
            }
            return IOSSecuritySuite.findRuntimePaths(.customExecutable(currentExecutableURL)) ?? []
        #else
            return []
        #endif
    }()

    private lazy var currentLoadedDylibs: [String] = {
        #if arch(arm64)
            guard let currentExecutableURL, currentRuntimePaths.count > 0 else {
                return []
            }
            guard let loadedDylibs = IOSSecuritySuite.findLoadedDylibs(.customExecutable(currentExecutableURL)) else {
                return []
            }
            let parsedDylibs = loadedDylibs.flatMap { dylib in
                if let firstRange = dylib.range(of: "@rpath/") {
                    return currentRuntimePaths.map { rpath in
                        dylib.replacingCharacters(in: firstRange, with: rpath + "/")
                    }
                }
                return [dylib]
            }
            let executablePath = currentExecutableURL.deletingLastPathComponent().path
            let finalDylibs = parsedDylibs.map { dylib in
                if let firstRange = dylib.range(of: "@executable_path/") {
                    return dylib.replacingCharacters(in: firstRange, with: executablePath + "/")
                } else if let firstRange = dylib.range(of: "@loader_path/") {
                    return dylib.replacingCharacters(in: firstRange, with: executablePath + "/")
                }
                return dylib
            }
            return finalDylibs
        #else
            return []
        #endif
    }()

    private lazy var currentCodeSigningFlags: CsOpsFlags = {
        var flags = CsOpsFlags()
        csops(ops: CUnsignedInt(CS_OPS_STATUS), dest: &flags, destSize: MemoryLayout<CsOpsFlags>.size)
        return flags
    }()

    lazy var secureLibraryPaths: Set<String> = {
        var securePaths = Set<String>()
        if let currentExecutablePath {
            securePaths.insert(currentExecutablePath)
        }
        securePaths.formUnion(SecurityPresets.default.secureStandaloneLibraries)
        if currentLoadedDylibs.count > 0 {
            securePaths.formUnion(currentLoadedDylibs)
        }
        return securePaths
    }()

    lazy var loadedLibraryPaths: [String] = {
        var paths = [String]()
        for index in 0 ..< _dyld_image_count() {
            paths.append(String(cString: _dyld_get_image_name(index)))
        }
        return paths
    }()

    func hasInsecureLibraryPaths() -> Bool {
        loadedLibraryPaths.lazy
            .first {
                #if targetEnvironment(simulator)
                    !_dyld_shared_cache_contains_path($0)
                        && !secureLibraryPaths.contains($0)
                        && !$0.hasPrefix("/System/")
                        && !$0.hasPrefix("/Developer/")
                        && !$0.hasPrefix("/Library/Developer/CoreSimulator/Volumes/")
                #else
                    !_dyld_shared_cache_contains_path($0)
                        && !secureLibraryPaths.contains($0)
                        && !$0.hasPrefix("/System/")
                        && !$0.hasPrefix("/Developer/")
                #endif
            } != nil
    }

    func getInsecureLibraryPaths() -> [String] {
        let extraPaths = loadedLibraryPaths
            .filter { !_dyld_shared_cache_contains_path($0) && !secureLibraryPaths.contains($0) }
            .filter { !$0.hasPrefix("/System/") && !$0.hasPrefix("/Developer/") } // Read-Only File System
        #if targetEnvironment(simulator)
            .filter { !$0.hasPrefix("/Library/Developer/CoreSimulator/Volumes/") } // Read-Only File System
        #endif
        return extraPaths
    }

    func hasInsertedLibraryPaths() -> Bool {
        getenv("DYLD_INSERT_LIBRARIES") != nil
    }

    func getInsertedLibraryPaths() -> [String] {
        guard let envPtr = getenv("DYLD_INSERT_LIBRARIES") else {
            return []
        }
        let envStr = String(cString: envPtr)
        return envStr.components(separatedBy: ":")
    }

    lazy var suspiciousURLSchemes = JailbreakChecker.getSuspiciousURLSchemes()

    private static let availableSignals = [
        SIGHUP, SIGINT, SIGQUIT, SIGILL,
        SIGTRAP, SIGABRT, SIGEMT, SIGFPE,
        SIGKILL, SIGBUS, SIGSEGV, SIGSYS,
        SIGPIPE, SIGALRM, SIGTERM, SIGURG,
        SIGSTOP, SIGTSTP, SIGCONT, SIGCHLD,
        SIGTTIN, SIGTTOU, SIGIO, SIGXCPU,
        SIGXFSZ, SIGVTALRM, SIGPROF, SIGWINCH,
        SIGINFO, SIGUSR1, SIGUSR2,
    ]

    func checkSignalHandlers() -> Bool {
        for signal in Self.availableSignals {
            var oldact = sigaction()
            sigaction(signal, nil, &oldact)
            if oldact.__sigaction_u.__sa_sigaction != nil {
                return false
            }
        }

        return true
    }

    private static let EXC_MASK_ALL = (
        EXC_MASK_BAD_ACCESS | EXC_MASK_BAD_INSTRUCTION | EXC_MASK_ARITHMETIC |
            EXC_MASK_EMULATION | EXC_MASK_SOFTWARE | EXC_MASK_BREAKPOINT |
            EXC_MASK_SYSCALL | EXC_MASK_MACH_SYSCALL | EXC_MASK_RPC_ALERT |
            EXC_MASK_CRASH | EXC_MASK_RESOURCE | EXC_MASK_GUARD |
            EXC_MASK_CORPSE_NOTIFY
    )

    func checkExceptionPorts() -> Bool {
        let typesCnt = Int(EXC_TYPES_COUNT)

        let masks = exception_mask_array_t.allocate(capacity: typesCnt)
        masks.initialize(repeating: exception_mask_t(), count: typesCnt)

        let oldHandlers = exception_handler_array_t.allocate(capacity: typesCnt)
        oldHandlers.initialize(repeating: exception_handler_t(), count: typesCnt)
        let oldBehaviors = exception_behavior_array_t.allocate(capacity: typesCnt)
        oldBehaviors.initialize(repeating: exception_behavior_t(), count: typesCnt)
        let oldFlavors = exception_flavor_array_t.allocate(capacity: typesCnt)
        oldFlavors.initialize(repeating: thread_state_flavor_t(), count: typesCnt)

        defer {
            masks.deallocate()
            oldHandlers.deallocate()
            oldBehaviors.deallocate()
            oldFlavors.deallocate()
        }

        var masksCnt: mach_msg_type_number_t = 0
        let kr = task_get_exception_ports(mach_task_self_, exception_mask_t(Self.EXC_MASK_ALL), masks, &masksCnt, oldHandlers, oldBehaviors, oldFlavors)
        guard kr == KERN_SUCCESS else {
            return false
        }

        let taskExceptionHandlers = UnsafeMutableBufferPointer(start: oldHandlers, count: typesCnt)

        guard taskExceptionHandlers.first(where: { $0 != 0 }) == nil
        else {
            return false
        }

        return true
    }

    func checkExecutionStates() -> Bool {
        let typesCnt = Int(EXC_TYPES_COUNT)

        let masks = exception_mask_array_t.allocate(capacity: typesCnt)
        masks.initialize(repeating: exception_mask_t(), count: typesCnt)

        let oldHandlers = exception_handler_array_t.allocate(capacity: typesCnt)
        oldHandlers.initialize(repeating: exception_handler_t(), count: typesCnt)
        let oldBehaviors = exception_behavior_array_t.allocate(capacity: typesCnt)
        oldBehaviors.initialize(repeating: exception_behavior_t(), count: typesCnt)
        let oldFlavors = exception_flavor_array_t.allocate(capacity: typesCnt)
        oldFlavors.initialize(repeating: thread_state_flavor_t(), count: typesCnt)

        defer {
            masks.deallocate()
            oldHandlers.deallocate()
            oldBehaviors.deallocate()
            oldFlavors.deallocate()
        }

        var masksCnt: mach_msg_type_number_t = 0
        let kr = task_get_exception_ports(mach_task_self_, exception_mask_t(Self.EXC_MASK_ALL), masks, &masksCnt, oldHandlers, oldBehaviors, oldFlavors)
        guard kr == KERN_SUCCESS else {
            return false
        }

        let taskThreadFlavors = UnsafeMutableBufferPointer(start: oldFlavors, count: typesCnt)

        guard taskThreadFlavors.first(where: { $0 == THREAD_STATE_NONE }) == nil
        else {
            return false
        }

        return true
    }

    func checkExtraTaskRefs() -> Bool {
        var refs = mach_port_urefs_t()
        let err = mach_port_get_refs(mach_task_self_, mach_task_self_, MACH_PORT_RIGHT_SEND, &refs)
        if err != KERN_SUCCESS {
            return false
        }

        return refs >= 0 && refs <= 2
    }

    private lazy var entitlements: Entitlements? = {
        guard let currentExecutablePath else {
            return nil
        }
        guard let reader = try? EntitlementsReader(currentExecutablePath) else {
            return nil
        }
        return try? reader.readEntitlements()
    }()

    func checkEntitlements() -> Bool {
        guard let entKeys = entitlements?.values.keys else {
            return false
        }
        return Set(entKeys).subtracting(SecurityPresets.default.secureEntitlementKeys).isEmpty
    }

    func getUnknownEntitlementKeys() -> [String] {
        guard let entKeys = entitlements?.values.keys else {
            return []
        }
        return OrderedSet(entKeys).subtracting(SecurityPresets.default.secureEntitlementKeys).elements
    }

    func checkMainBundleIdentifier() -> Bool {
        guard let bid = Bundle(for: Self.self).bundleIdentifier else {
            return false
        }
        return SecurityPresets.default.secureMainBundleIdentifiers.contains(bid)
    }

    func checkMobileProvisioningProfileHash() -> Bool {
        IntegrityChecker.checkMobileProvision(SecurityPresets.default.secureMobileProvisioningProfileHashes)
    }

    func checkResourceHashes() -> Bool {
        let resHashes = SecurityPresets.default.secureResourceHashes
        for resName in resHashes.keys {
            if let resHash = resHashes[resName] {
                let resTampered = IntegrityChecker.amITampered([.commonResource(resName, resHash)]).result
                if resTampered {
                    return false
                }
            }
        }
        return true
    }

    func getModifiedResourceNames() -> [String] {
        var modifiedNames = [String]()
        let resHashes = SecurityPresets.default.secureResourceHashes
        for resName in resHashes.keys {
            if let resHash = resHashes[resName] {
                let resTampered = IntegrityChecker.amITampered([.commonResource(resName, resHash)]).result
                if resTampered {
                    modifiedNames.append(resName)
                }
            }
        }
        return modifiedNames
    }

    func checkMachOHash() -> Bool {
        #if DEBUG
            return IntegrityChecker.checkMachO(currentExecutablePath, with: SecurityPresets.default.secureMainExecutableMachOHashes)
        #else
            return IntegrityChecker.checkMainMachO(SecurityPresets.default.secureMainExecutableMachOHashes)
        #endif
    }

    func checkPrivilegedHostPort() -> Bool {
        var privPort = host_priv_t()
        var kr: kern_return_t
        kr = host_get_special_port(mach_host_self(), HOST_LOCAL_NODE, HOST_PRIV_PORT, &privPort)
        guard kr != KERN_SUCCESS else {
            return false
        }
        kr = task_get_special_port(mach_task_self_, TASK_HOST_PORT, &privPort)
        if kr == KERN_SUCCESS {
            var bootInfo = UnsafeMutablePointer<CChar>.allocate(capacity: Mirror(reflecting: kernel_boot_info_t.self).children.count)
            kr = host_get_boot_info(privPort, &bootInfo)
            bootInfo.deallocate()
            guard kr != KERN_SUCCESS else {
                return false
            }
        }
        return true
    }

    func checkLibraryValidationEnabled() -> Bool {
        guard currentCodeSigningFlags.contains(.CS_REQUIRE_LV) else {
            return false
        }

        guard let srcURL = Bundle(for: Self.self).url(forResource: "library_stub", withExtension: "zip") else {
            return false
        }

        let fileManager = FileManager.default
        guard let cachesURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return false
        }

        let dstURL = cachesURL.appendingPathComponent("SecurityCheck")
            .appendingPathComponent("enabledLibraryValidation")
            .appendingPathComponent(UUID().uuidString)

        do {
            try fileManager.createDirectory(at: dstURL, withIntermediateDirectories: true, attributes: nil)
            try fileManager.unzipItem(at: srcURL, to: dstURL)
        } catch {
            print("Extraction of ZIP archive failed with error: \(error)")
            try? fileManager.removeItem(at: dstURL)
            return false
        }

        let libraryURL = dstURL.appendingPathComponent("library_stub.framework")
        guard let libraryBundle = Bundle(url: libraryURL) else {
            try? fileManager.removeItem(at: dstURL)
            return false
        }

        do {
            try libraryBundle.loadAndReturnError()
        } catch {
            print("Load of stub library failed with error: \(error)")
            try? fileManager.removeItem(at: dstURL)
            return true // Library Validation ON
        }

        return false
    }

    func checkSeatbeltSpecialPort() -> Bool {
        let TASK_SEATBELT_PORT: Int32 = 7
        var specialPort = mach_port_t()
        let kr = task_get_special_port(mach_task_self_, TASK_SEATBELT_PORT, &specialPort)
        guard kr != KERN_SUCCESS else {
            return false
        }
        return true
    }

    /* This check is no longer available on latest iOS versions. */
    func checkTrustCache() -> Bool {
        var isAdhocSignedOut: ObjCBool = false
        var nsData: NSData?
        let ret = evaluateSignature(currentExecutableURL, &nsData, &isAdhocSignedOut)
        if ret == 0, isAdhocSignedOut.boolValue, let nsData = nsData as? Data {
            return !isCdHashInTrustCache(nsData)
        }
        return true
    }

    func checkExecutableMemoryRegions() -> Bool {
        var kr: kern_return_t
        var address = vm_address_t()
        var size = vm_size_t()
        var depth = natural_t(1)
        let taskSelf = mach_task_self_
        while true {
            var regionInfo = vm_region_submap_info_64()
            var infoCount = VM_REGION_SUBMAP_INFO_COUNT_64
            kr = withUnsafeMutablePointer(to: &regionInfo) { $0.withMemoryRebound(to: Int32.self, capacity: Int(infoCount)) {
                vm_region_recurse_64(taskSelf, &address, &size, &depth, $0, &infoCount)
            } }
            let isSubmap = regionInfo.is_submap != 0
            guard kr == KERN_SUCCESS, isSubmap || size > 0 else {
                break
            }
            if isSubmap {
                depth += 1
            } else {
                if (regionInfo.protection & VM_PROT_EXECUTE) != 0 {
                    if regionInfo.share_mode == SM_SHARED || regionInfo.share_mode == SM_SHARED_ALIASED {
                        return false
                    }
                }

                address += size
            }
        }
        return true
    }

    lazy var currentEnvironmentVariables = OrderedSet<String>(ProcessInfo.processInfo.environment.keys)

    func checkDYLDEnvironmentVariables() -> Bool {
        guard currentCodeSigningFlags.contains(.CS_DYLD_PLATFORM) else {
            return false
        }
        return currentEnvironmentVariables.first { $0.hasPrefix("DYLD_") } == nil
    }

    func checkSuspiciousEnvironmentVariables() -> Bool {
        currentEnvironmentVariables.isDisjoint(with: SecurityPresets.default.insecureEnvironmentVariables)
    }

    func getSuspiciousEnvironmentVariables() -> [String] {
        currentEnvironmentVariables.intersection(SecurityPresets.default.insecureEnvironmentVariables).sorted {
            $0.localizedStandardCompare($1) == .orderedAscending
        }
    }

    private lazy var lazyCodeSigningStatus = CsOpsFlags.allCases
        .lazy.map {
            CsOpsStatus(
                flag: $0,
                isRequired: CsOpsFlags.requiredSecureSet.contains($0),
                isInsecure: CsOpsFlags.insecureSet.contains($0),
                isPresented: self.currentCodeSigningFlags.contains($0)
            )
        }

    func checkCodeSigningStatus() -> Bool {
        lazyCodeSigningStatus.first {
            ($0.isRequired && !$0.isPresented) || ($0.isPresented && $0.isInsecure)
        } == nil
    }

    func getCodeSigningStatus() -> [CsOpsStatus] {
        enum CsOpsStatusStyle: CaseIterable {
            case securePresented
            case insecurePresented
            case insecureMissing
            case secureMissing
        }
        let childCases = [CsOpsStatus](lazyCodeSigningStatus)
        let groupedCases = Dictionary(grouping: childCases) { status -> CsOpsStatusStyle in
            status.isPresented
                ? (status.isInsecure ? .insecurePresented : .securePresented)
                : (status.isRequired ? .insecureMissing : .secureMissing)
        }
        return CsOpsStatusStyle.allCases.compactMap { groupedCases[$0] }.flatMap { $0 }
    }

    func checkSignedSystemVolume() -> Bool {
        if let bootHash = FileChecker.getMountedVolumeInfoViaStatfs(path: "/")?
            .fileSystemName.components(separatedBy: "@").first
        {
            return bootHash.hasPrefix("com.apple.")
        }
        return false
    }
}
