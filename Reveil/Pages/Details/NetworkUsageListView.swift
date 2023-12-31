//
//  NetworkUsageListView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/10.
//

import SwiftUI

struct NetworkUsageListView: View, ModuleListView {
    let module: Module = NetworkUsage.shared

    init() {}

    init?(entryKey: EntryKey) {
        guard module.updatableEntryKeys.contains(entryKey) else {
            return nil
        }
    }

    @State private var shouldTick: Bool = false

    var body: some View {
        DetailsListView(
            basicEntries: module.basicEntries,
            usageEntry: module.usageEntry,
            usageStyle: .regular
        )
        .navigationTitle(module.moduleName)
        .navigationBarItems(trailing: PinButton(pin: AppCodableStorage(
            wrappedValue: Pin(false), String(describing: NetworkUsage.self),
            store: PinStorage.shared.userDefaults
        )))
        .onReceive(GlobalTimer.shared.$tick) { _ in
            if shouldTick {
                module.updateEntries()
            }
        }
        .onAppear {
            shouldTick = true
        }
        .onDisappear {
            shouldTick = false
        }
    }
}

// MARK: - Previews

struct NetworkUsageListView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkUsageListView()
            .environmentObject(HighlightedEntryKey())
    }
}
