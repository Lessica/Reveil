//
//  OperatingSystemListView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import SwiftUI

struct OperatingSystemListView: View, Identifiable, ModuleListView {
    let id = UUID()
    let module: Module = OperatingSystem.shared

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
}

extension OperatingSystemListView: GlobalTimerObserver, Hashable {
    static func == (lhs: OperatingSystemListView, rhs: OperatingSystemListView) -> Bool {
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

struct OperatingSystemListView_Previews: PreviewProvider {
    static var previews: some View {
        OperatingSystemListView()
            .environmentObject(HighlightedEntryKey())
    }
}
