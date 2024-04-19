//
//  SecurityPresets.swift
//  Reveil
//
//  Created by Lessica on 2023/11/7.
//

import Foundation

struct SecurityPresets: Codable {
    enum ConstructError: Error {
        case invalidBundle(message: String)
    }

    private static let decoder = PropertyListDecoder()
    private static let defaultURL = Bundle.main.url(
        forResource: String(describing: SecurityPresets.self).components(separatedBy: ".").last!, withExtension: "plist"
    )

    static let `default`: SecurityPresets = {
        guard let defaultURL,
              let presetsData = try? Data(contentsOf: defaultURL),
              let sharedPresets = try? decoder.decode(SecurityPresets.self, from: presetsData)
        else {
            return SecurityPresets()
        }
        return sharedPresets
    }()

    func writeAhead(to url: URL) throws {
        let encoder = PropertyListEncoder()
        let presetsData = try encoder.encode(self)
        try presetsData.write(to: url, options: [.atomic])
    }

    private init() {}

    init(bundleURL: URL) throws {
        guard bundleURL.appendingPathComponent("Info.plist").fileExists ||
            bundleURL.appendingPathComponent("Contents/Info.plist").fileExists,
            let bundle = Bundle(url: bundleURL)
        else {
            throw ConstructError.invalidBundle(message: String(format: "Failed to initialize bundle at: %@", bundleURL.path))
        }

        if let bundleExecutableURL = bundle.executableURL,
           let executableHashValue = IntegrityChecker.getMachOFileHashValue(.customExecutable(bundleExecutableURL))
        {
            secureMainExecutableMachOHashes.removeAll(keepingCapacity: true)
            secureMainExecutableMachOHashes.insert(executableHashValue)
        }

        if let bundleProvisioningProfilePath = bundle.path(forResource: "embedded", ofType: "mobileprovision"),
           let profileHashValue = IntegrityChecker.calculateHashValue(path: bundleProvisioningProfilePath)
        {
            secureMobileProvisioningProfileHashes.removeAll(keepingCapacity: true)
            secureMobileProvisioningProfileHashes.insert(profileHashValue)
        }

        var updatedHashes: Dictionary<String, String> = secureResourceHashes
        for secureResourceName in secureResourceHashes.keys {
            let resourcePath = bundle.path(forResource: secureResourceName, ofType: nil)
            if let resourcePath, let resourceHashValue = IntegrityChecker.calculateHashValue(path: resourcePath)
            {
                updatedHashes.updateValue(resourceHashValue, forKey: secureResourceName)
            }
        }
        secureResourceHashes = updatedHashes
    }

    var secureStandaloneLibraries: Set<String> = [
        "/usr/lib/libBacktraceRecording.dylib",
        "/usr/lib/libMainThreadChecker.dylib",
        "/usr/lib/libRPAC.dylib",
        "/usr/lib/libViewDebuggerSupport.dylib",
        "/usr/lib/libobjc-trampolines.dylib",
        "/usr/lib/system/introspection/libdispatch.dylib",
        "/private/preboot/Cryptexes/OS/usr/lib/libobjc-trampolines.dylib",
        "/private/preboot/Cryptexes/OS/usr/lib/libglInterpose.dylib",
    ]

    var secureEntitlementKeys: Set<String> = [
        "get-task-allow",
        "application-identifier",
        "keychain-access-groups",
        "com.apple.developer.team-identifier",
        "com.apple.security.app-sandbox",
        "com.apple.security.network.client",
        "com.apple.private.security.container-required",
        "beta-reports-active",
        "aps-environment",
    ]

    var secureMainBundleIdentifiers: Set<String> = [
        "com.reveil.app",
        "com.82flex.reveil",
    ]

    var secureMobileProvisioningProfileHashes: Set<String> = [
        "",
    ]

    var secureMainExecutableMachOHashes: Set<String> = [
        "",
    ]

    var secureResourceHashes: Dictionary<String, String> = [
        "library_stub.zip": "",
        "rsc-001-country-mapping.json": "",
        "rsc-002-ios-versions.json": "",
        "rsc-003-iphone-models.json": "",
        "rsc-004-carriers.json": "",
        "rsc-005-ipad-models.json": "",
        "rsc-006-ipod-models.json": "",
    ]

    var insecureEnvironmentVariables: Set<String> = [
        "_MSSafeMode",
        "DYLD_FRAMEWORK_PATH",
        "DYLD_FALLBACK_FRAMEWORK_PATH",
        "DYLD_VERSIONED_FRAMEWORK_PATH",
        "DYLD_LIBRARY_PATH",
        "DYLD_FALLBACK_LIBRARY_PATH",
        "DYLD_VERSIONED_LIBRARY_PATH",
        "DYLD_IMAGE_SUFFIX",
        "DYLD_INSERT_LIBRARIES",
        "DYLD_PRINT_TO_FILE",
        "DYLD_PRINT_LIBRARIES",
        "DYLD_PRINT_LOADERS",
        "DYLD_PRINT_SEARCHING",
        "DYLD_PRINT_APIS",
        "DYLD_PRINT_BINDINGS",
        "DYLD_PRINT_INITIALIZERS",
        "DYLD_PRINT_SEGMENTS",
        "DYLD_PRINT_ENV",
        "DYLD_SHARED_REGION",
        "DYLD_SHARED_CACHE_DIR",
    ]

    var suspiciousExecutables: Set<String> = [
        "/usr/sbin/frida-server",
    ]

    var suspiciousLibraryNames: Set<String> = [
        "FridaGadget",
        "frida",
        "cynject",
        "libcycript",
        "RevealServer",
    ]

    var suspiciousLibraries: Set<String> = [
        "SubstrateLoader.dylib",
        "SSLKillSwitch2.dylib",
        "SSLKillSwitch.dylib",
        "MobileSubstrate.dylib",
        "TweakInject.dylib",
        "CydiaSubstrate",
        "cynject",
        "CustomWidgetIcons",
        "PreferenceLoader",
        "RocketBootstrap",
        "WeeLoader",
        "/.file", // HideJB (2.1.1) changes full paths of the suspicious libraries to "/.file"
        "libhooker",
        "SubstrateInserter",
        "SubstrateBootstrap",
        "ABypass",
        "FlyJB",
        "Substitute",
        "Cephei",
        "Electra",
        "AppSyncUnified-FrontBoard.dylib",
        "Shadow",
        "FridaGadget",
        "frida",
        "libcycript",
    ]

    var suspiciousFiles: Set<String> = [
        "/var/mobile/Library/Preferences/ABPattern", // A-Bypass
        "/usr/lib/ABDYLD.dylib", // A-Bypass,
        "/usr/lib/ABSubLoader.dylib", // A-Bypass
        "/usr/sbin/frida-server", // frida
        "/etc/apt/sources.list.d/electra.list", // electra
        "/etc/apt/sources.list.d/sileo.sources", // electra
        "/.bootstrapped_electra", // electra
        "/usr/lib/libjailbreak.dylib", // electra
        "/jb/lzma", // electra
        "/.cydia_no_stash", // unc0ver
        "/.installed_unc0ver", // unc0ver
        "/jb/offsets.plist", // unc0ver
        "/usr/share/jailbreak/injectme.plist", // unc0ver
        "/etc/apt/undecimus/undecimus.list", // unc0ver
        "/var/lib/dpkg/info/mobilesubstrate.md5sums", // unc0ver
        "/Library/MobileSubstrate/MobileSubstrate.dylib",
        "/jb/jailbreakd.plist", // unc0ver
        "/jb/amfid_payload.dylib", // unc0ver
        "/jb/libjailbreak.dylib", // unc0ver
        "/usr/libexec/cydia/firmware.sh",
        "/var/lib/cydia",
        "/etc/apt",
        "/private/var/lib/apt",
        "/private/var/Users/",
        "/var/log/apt",
        "/Applications/Cydia.app",
        "/private/var/stash",
        "/private/var/apt",
        "/private/var/ssh",
        "/private/var/master.passwd",
        "/private/var/zlogin",
        "/private/var/sudo_logsrvd.conf",
        "/private/var/suid_profile",
        "/private/var/zlogin", // zsh
        "/private/var/zlogout", // zsh
        "/private/var/zprofile", // zsh
        "/private/var/zshenv", // zsh
        "/private/var/zshrc", // zsh
        "/private/var/lib/apt/",
        "/private/var/lib/cydia",
        "/private/var/cache/apt/",
        "/private/var/log/syslog",
        "/private/var/tmp/cydia.log",
        "/Applications/Icy.app",
        "/Applications/MxTube.app",
        "/Applications/RockApp.app",
        "/Applications/blackra1n.app",
        "/Applications/SBSettings.app",
        "/Applications/FakeCarrier.app",
        "/Applications/WinterBoard.app",
        "/Applications/IntelliScreen.app",
        "/Applications/iFile.app", // iFile
        "/Applications/Filza.app", // Filza
        "/var/mobile/Library/Application Support/Containers/com.tigisoftware.Filza", // Filza
        "/var/mobile/Library/Saved Application State/com.tigisoftware.Filza.savedState", // Filza
        "/var/mobile/Library/HTTPStorages/com.tigisoftware.Filza", // Filza
        "/var/mobile/Library/SplashBoard/Snapshots/com.tigisoftware.Filza", // Filza
        "/var/mobile/Library/Filza", // Filza
        "/var/mobile/Library/Preferences/com.tigisoftware.Filza.plist", // Filza
        "/var/mobile/Library/Caches/com.tigisoftware.Filza", // Filza
        "/Applications/Flex3.app", // Flex3
        "/var/mobile/Library/Cookies/com.johncoates.Flex.binarycookies", // Flex3
        "/var/mobile/Library/Flex3", // Flex3
        "/var/mobile/Library/UserConfigurationProfiles/PublicInfo/Flex3Patches.plist", // Flex3
        "/Applications/NewTerm.app", // NewTerm
        "/var/root/.bash_history",
        "/var/root/Library/Caches/shshd",
        "/var/root/Library/HTTPStorages/shshd",
        "/var/mobile/.ekenablelogging", // ellekit
        "/var/mobile/.eksafemode", // ellekit safemode
        "/var/root/Library/Preferences/ws.hbang.Terminal.plist", // NewTerm
        "/var/mobile/Library/Preferences/ws.hbang.Terminal.plist", // NewTerm
        "/var/mobile/Library/Saved Application State/ws.hbang.Terminal.savedState", // NewTerm
        "/var/mobile/Library/HTTPStorages/ws.hbang.Terminal", // NewTerm
        "/var/mobile/Library/SplashBoard/Snapshots/ws.hbang.Terminal", // NewTerm
        "/var/mobile/Library/Caches/ws.hbang.Terminal", // NewTerm
        "/var/mobile/Library/Caches/Cephei", // NewTerm
        "/var/root/Library/Preferences/com.xina.jailbreak.plist", // Xina
        "/var/root/Library/Preferences/com.xina.blacklist.plist", // Xina
        "/var/mobile/Library/Preferences/com.xina.jailbreak.plist", // Xina
        "/var/mobile/Library/SplashBoard/Snapshots/com.xina.jailbreak", // Xina
        "/private/var/mobile/Library/SBSettings/Themes",
        "/Library/MobileSubstrate/CydiaSubstrate.dylib",
        "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
        "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
        "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
        "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
        "/Applications/Sileo.app", // Sileo
        "/var/mobile/Library/Sileo", // Sileo
        "/var/mobile/Library/Preferences/org.coolstar.SileoStore.plist", // Sileo
        "/var/mobile/Library/HTTPStorages/org.coolstar.SileoStore", // Sileo
        "/var/mobile/Library/Application Support/Containers/org.coolstar.SileoStore", // Sileo
        "/var/mobile/Library/Saved Application State/org.coolstar.SileoStore.savedState", // Sileo
        "/var/mobile/Library/SplashBoard/Snapshots/org.coolstar.SileoStore", // Sileo
        "/var/mobile/Library/Caches/org.coolstar.SileoStore", // Sileo
        "/var/binpack",
        "/Library/PreferenceBundles/LibertyPref.bundle",
        "/Library/PreferenceBundles/ShadowPreferences.bundle",
        "/Library/PreferenceBundles/ABypassPrefs.bundle",
        "/Library/PreferenceBundles/FlyJBPrefs.bundle",
        "/Library/PreferenceBundles/FlyJBPrefs.bundle",
        "/Library/PreferenceBundles/Cephei.bundle",
        "/Library/PreferenceBundles/SubstitutePrefs.bundle",
        "/Library/PreferenceBundles/libhbangprefs.bundle",
        "/usr/lib/libhooker.dylib",
        "/usr/lib/libsubstitute.dylib",
        "/usr/lib/substrate",
        "/usr/lib/TweakInject",
        "/var/binpack/Applications/loader.app", // checkra1n
        "/Applications/FlyJB.app", // Fly JB X
        "/Applications/Zebra.app", // Zebra
        "/var/mobile/Library/Application Support/xyz.willy.Zebra", // Zebra
        "/var/mobile/Library/Application Support/Containers/xyz.willy.Zebra", // Zebra
        "/var/mobile/Library/WebKit/xyz.willy.Zebra", // Zebra
        "/var/mobile/Library/Saved Application State/xyz.willy.Zebra.savedState", // Zebra
        "/var/mobile/Library/HTTPStorages/xyz.willy.Zebra", // Zebra
        "/var/mobile/Library/Preferences/xyz.willy.Zebra.plist", // Zebra
        "/var/mobile/Library/SplashBoard/Snapshots/xyz.willy.Zebra", // Zebra
        "/var/mobile/Library/Caches/xyz.willy.Zebra", // Zebra
        "/Library/BawAppie/ABypass", // ABypass
        "/Library/MobileSubstrate/DynamicLibraries/SSLKillSwitch2.plist", // SSL Killswitch
        "/Library/MobileSubstrate/DynamicLibraries/PreferenceLoader.plist", // PreferenceLoader
        "/Library/MobileSubstrate/DynamicLibraries/PreferenceLoader.dylib", // PreferenceLoader
        "/Library/MobileSubstrate/DynamicLibraries", // DynamicLibraries directory in general
        "/var/mobile/Library/Preferences/me.jjolano.shadow.plist",
        "/var/mobile/Library/Saved Application State/ru.domo.cocoatop64.savedState", // CocoaTop
        "/var/mobile/Library/Preferences/ru.domo.cocoatop64.plist", // CocoaTop
        "/var/mobile/Library/SplashBoard/Snapshots/ru.domo.cocoatop64", // CocoaTop
    ]

    var suspiciousInterpreters: Set<String> = [
        "/bin/bash",
        "/usr/sbin/sshd",
        "/usr/libexec/ssh-keysign",
        "/bin/sh",
        "/etc/ssh/sshd_config",
        "/usr/libexec/sftp-server",
        "/usr/bin/ssh",
    ]

    var suspiciousAccessibleFiles: Set<String> = [
        "/.installed_unc0ver",
        "/.bootstrapped_electra",
        "/Applications/Cydia.app",
        "/Library/MobileSubstrate/MobileSubstrate.dylib",
        "/etc/apt",
        "/var/log/apt",
    ]

    var suspiciousAccessibleInterpreters: Set<String> = [
        "/bin/bash",
        "/usr/sbin/sshd",
        "/usr/bin/ssh",
    ]

    var suspiciousAccessibleDirectories: Set<String> = [
        "/",
        "/root/",
        "/private/",
        "/jb/",
        "/Library/",
    ]

    var suspiciousSymbolicLinks: Set<String> = [
        "/var/lib/undecimus/apt", // unc0ver
        "/Applications",
        "/Library/Ringtones",
        "/Library/Wallpaper",
        "/usr/arm-apple-darwin9",
        "/usr/include",
        "/usr/libexec",
        "/usr/share",
    ]

    var suspiciousPorts: [PortItem] = [
        PortItem(port: 46952, description: "X.X.T."),
        PortItem(port: 27042, description: "Frida Server"),
        PortItem(port: 4444, description: "Frida Gadget"),
        PortItem(port: 22, description: "OpenSSH"),
        PortItem(port: 44, description: "Checkra1n"),
    ]

    var suspiciousURLSchemes: [URLSchemeItem] = [
        URLSchemeItem(scheme: "cydia://", description: "Cydia"),
        URLSchemeItem(scheme: "undecimus://", description: "Unc0ver"),
        URLSchemeItem(scheme: "sileo://", description: "Sileo"),
        URLSchemeItem(scheme: "zbra://", description: "Zebra"),
        URLSchemeItem(scheme: "filza://", description: "Filza"),
        URLSchemeItem(scheme: "activator://", description: "Activator"),
    ]

    var suspiciousObjCClasses: [ObjCClassItem] = [
        ObjCClassItem(className: "ShadowRuleset", selectorName: "internalDictionary", methodType: .instance),
    ]
}
