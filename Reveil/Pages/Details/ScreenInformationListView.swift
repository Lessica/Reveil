//
//  ScreenInformationListView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import SwiftUI

struct ScreenInformationListView: View, ModuleListView {
    let module: Module = ScreenInformation.shared
    let globalName: String = String(describing: ScreenInformation.self)

    init() {}

    init?(entryKey: EntryKey) {
        guard module.updatableEntryKeys.contains(entryKey) else {
            return nil
        }
    }

    var body: some View {
        DetailsListView(basicEntries: module.basicEntries)
            .navigationTitle(module.moduleName)
    }

    func eventOccurred(globalTimer timer: GlobalTimer) { }
}

// MARK: - Previews

struct ScreenInformationListView_Previews: PreviewProvider {
    static var previews: some View {
        ScreenInformationListView()
            .environmentObject(HighlightedEntryKey())
    }
}
