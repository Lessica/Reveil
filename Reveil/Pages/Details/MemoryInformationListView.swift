//
//  MemoryInformationListView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import SwiftUI

struct MemoryInformationListView: View, Identifiable, ModuleListView {
    let id = UUID()
    let module: Module = MemoryInformation.shared

    init() {}

    init?(entryKey: EntryKey) {
        guard module.updatableEntryKeys.contains(entryKey) else {
            return nil
        }
    }

    var body: some View {
        DetailsListView(
            basicEntries: module.basicEntries,
            usageEntry: module.usageEntry,
            usageStyle: .regular
        )
        .navigationTitle(module.moduleName)
        .navigationBarItems(trailing: PinButton(pin: AppCodableStorage(
            wrappedValue: Pin(true), .MemoryInformation,
            store: PinStorage.shared.userDefaults
        )))
        .onAppear {
            GlobalTimer.shared.addObserver(self)
        }
        .onDisappear {
            GlobalTimer.shared.removeObserver(self)
        }
    }
}

extension MemoryInformationListView: GlobalTimerObserver, Hashable {
    static func == (lhs: MemoryInformationListView, rhs: MemoryInformationListView) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func globalTimerEventOccurred(_ timer: GlobalTimer) {
        module.updateEntries()
    }
}

// MARK: - Previews

struct MemoryInformationListView_Previews: PreviewProvider {
    static var previews: some View {
        MemoryInformationListView()
            .environmentObject(HighlightedEntryKey())
    }
}
