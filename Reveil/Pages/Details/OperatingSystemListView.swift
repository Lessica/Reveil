//
//  OperatingSystemListView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import SwiftUI

struct OperatingSystemListView: View, Identifiable, ModuleListView, GlobalTimerObserver {
    let id = UUID()
    let module: Module = OperatingSystem.shared
    let globalName: String = .init(describing: OperatingSystem.self)

    init() {}

    init?(entryKey: EntryKey) {
        guard module.updatableEntryKeys.contains(entryKey) else {
            return nil
        }
    }

    var body: some View {
        DetailsListView(basicEntries: module.basicEntries)
            .navigationTitle(module.moduleName)
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

struct OperatingSystemListView_Previews: PreviewProvider {
    static var previews: some View {
        OperatingSystemListView()
            .environmentObject(HighlightedEntryKey())
    }
}
