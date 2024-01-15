//
//  MemoryInformationListView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import SwiftUI

struct MemoryInformationListView: View, Identifiable, ModuleListView, GlobalTimerObserver {
    let id = UUID()
    let module: Module = MemoryInformation.shared
    let globalName: String = .init(describing: MemoryInformation.self)

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

        .toolbar {
            ToolbarItem {
                PinButton(pin: AppCodableStorage(
                    wrappedValue: Pin(true), .MemoryInformation,
                    store: PinStorage.shared.userDefaults
                ))
            }
        }
        .onAppear {
            GlobalTimer.shared.addObserver(self)
        }
        .onDisappear {
            GlobalTimer.shared.removeObserver(self)
        }
    }

    func eventOccurred(globalTimer _: GlobalTimer) {
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
