//
//  BatteryInformationListView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import SwiftUI

struct BatteryInformationListView: View, Identifiable, ModuleListView, GlobalTimerObserver {
    let id = UUID()
    let module: Module = BatteryInformation.shared
    let globalName: String = .init(describing: BatteryInformation.self)

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
            usageStyle: .compat
        )
        .navigationTitle(module.moduleName)

        .toolbar {
            ToolbarItem {
                PinButton(pin: AppCodableStorage(
                    wrappedValue: Pin(false), .BatteryInformation,
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

struct BatteryInformationListView_Previews: PreviewProvider {
    static var previews: some View {
        BatteryInformationListView()
            .environmentObject(HighlightedEntryKey())
    }
}
