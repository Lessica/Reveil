//
//  NetworkUsageListView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/10.
//

import SwiftUI

struct NetworkUsageListView: View, Identifiable, ModuleListView, GlobalTimerObserver {
    let id = UUID()
    let module: Module = NetworkUsage.shared
    let globalName: String = .init(describing: NetworkUsage.self)

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
                    wrappedValue: Pin(false), .NetworkUsage,
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

struct NetworkUsageListView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkUsageListView()
            .environmentObject(HighlightedEntryKey())
    }
}
