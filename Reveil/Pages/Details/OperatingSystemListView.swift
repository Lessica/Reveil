//
//  OperatingSystemListView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import SwiftUI

struct OperatingSystemListView: View, ModuleListView {
    let module: Module = OperatingSystem.shared

    init() {}

    init?(entryKey: EntryKey) {
        guard module.updatableEntryKeys.contains(entryKey) else {
            return nil
        }
    }

    @State private var shouldTick: Bool = false

    var body: some View {
        DetailsListView(basicEntries: module.basicEntries)
            .navigationTitle(module.moduleName)
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

struct OperatingSystemListView_Previews: PreviewProvider {
    static var previews: some View {
        OperatingSystemListView()
            .environmentObject(HighlightedEntryKey())
    }
}
