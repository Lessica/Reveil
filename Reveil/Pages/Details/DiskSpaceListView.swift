//
//  DiskSpaceListView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import SwiftUI

struct DiskSpaceListView: View, ModuleListView {
    let module: Module = DiskSpace.shared

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
            usageStyle: .compat
        )
        .navigationTitle(module.moduleName)
        .navigationBarItems(trailing: PinButton(pin: AppCodableStorage(
            wrappedValue: Pin(true), String(describing: DiskSpace.self),
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

struct DiskSpaceListView_Previews: PreviewProvider {
    static var previews: some View {
        DiskSpaceListView()
            .environmentObject(HighlightedEntryKey())
    }
}
