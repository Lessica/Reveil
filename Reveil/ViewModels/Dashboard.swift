//
//  Dashboard.swift
//  Reveil
//
//  Created by Lessica on 2023/10/19.
//

import Combine
import SwiftUI

final class Dashboard: ObservableObject {
    static let shared = Dashboard()

    private init() {
        entries = []
        cachedModuleNames = []
        cachedModuleMappings = [:]
        cachedModules = []
        registerNotifications()
    }

    var registeredModules: [Module] = [
        DeviceInformation.shared,
        OperatingSystem.shared,
        CPUInformation.shared,
        MemoryInformation.shared,
        DiskSpace.shared,
        FileSystems.shared,
        NetworkInterfaces.shared,
        NetworkDetails.shared,
        NetworkUsage.shared,
        BatteryInformation.shared,
    ]

    var registeredModuleListViewTypes: [any ModuleListView.Type] = [
        DeviceInformationListView.self,
        OperatingSystemListView.self,
        CPUInformationListView.self,
        MemoryInformationListView.self,
        DiskSpaceListView.self,
        FileSystemsListView.self,
        FileSystemListView.self,
        NetworkInterfacesListView.self,
        NetworkInterfaceListView.self,
        NetworkDetailsListView.self,
        NetworkDetailListView.self,
        NetworkUsageListView.self,
        BatteryInformationListView.self,
    ]

    @Published var entries: [any Entry]

    var cachedModuleNames: Set<ModuleName>
    var cachedModuleMappings: [EntryKey: Module]
    var cachedModules: [Module]

    func anyModule(key: EntryKey) -> (Module)? {
        guard let targetModule = registeredModules.lazy.filter({ $0.updatableEntryKeys.contains(key) }).first
        else {
            return nil
        }
        return targetModule
    }

    func anyEntry(key: EntryKey) -> (any Entry)? {
        guard let targetModule = anyModule(key: key) else {
            return nil
        }
        cachedModuleNames.insert(targetModule.moduleName)
        cachedModuleMappings[key] = targetModule
        if let usageEntry = targetModule.usageEntry(key: key, style: .dashboard), usageEntry.key == key {
            switch key {
            case .CPUInformation:
                return ActivityEntry(child: usageEntry, overrideName: NSLocalizedString("CPU_USAGE", comment: "CPU Usage"))
            case .MemoryInformation:
                return ActivityEntry(child: usageEntry, overrideName: NSLocalizedString("MEMORY_USAGE", comment: "Memory Usage"))
            default:
                break
            }
            return usageEntry
        }
        if let trafficEntryIO = targetModule.trafficEntryIO(key: key, style: .dashboard) {
            return trafficEntryIO
        }
        if let basicEntry = targetModule.basicEntry(key: key, style: .dashboard) {
            return basicEntry
        }
        #if DEBUG
            fatalError("inconsistent state of an entry key")
        #else
            return nil
        #endif
    }

    func anyListView(key: EntryKey) -> AnyView {
        for registeredModuleListViewType in registeredModuleListViewTypes {
            if let registeredModuleListView = registeredModuleListViewType.init(entryKey: key) {
                return AnyView(registeredModuleListView)
            }
        }
        return AnyView(EmptyView())
    }

    func reloadEntries(keys: [EntryKey]) {
        debugPrint("Dashboard.reloadEntries")
        entries.removeAll(keepingCapacity: true)
        cachedModuleNames.removeAll(keepingCapacity: true)
        cachedModuleMappings.removeAll(keepingCapacity: true)
        cachedModules.removeAll(keepingCapacity: true)
        let anyEntries = keys.compactMap { anyEntry(key: $0) }.compactMap { $0 }
        entries.append(contentsOf: anyEntries)
        cachedModules = registeredModules.filter { cachedModuleNames.contains($0.moduleName) }
        objectWillChange.send()
    }

    func updateEntries() {
        debugPrint("Dashboard.updateEntries")
        cachedModules.forEach { $0.reloadData() }
        for entry in entries {
            guard let targetModule = cachedModuleMappings[entry.key] else {
                continue
            }
            if let basicEntry = entry as? BasicEntry {
                targetModule.updateBasicEntry(basicEntry, style: .dashboard)
            } else if let usageEntry = entry as? UsageEntry<Double> {
                targetModule.updateUsageEntry(usageEntry, style: .dashboard)
            } else if let activityEntry = entry as? ActivityEntry,
                      let usageChild = activityEntry.usageChild
            {
                targetModule.updateUsageEntry(usageChild, style: .dashboard)
            } else if let trafficEntryIO = entry as? TrafficEntryIO {
                targetModule.updateTrafficEntryIO(trafficEntryIO, style: .dashboard)
            }
        }
    }

    private var cancellable: AnyCancellable?

    func registerNotifications() {
        cancellable = PinStorage.shared.$pinnedEntryKeys.sink { [weak self] entryKeys in
            self?.reloadEntries(keys: entryKeys)
        }
    }

    deinit {
        cancellable?.cancel()
    }
}
