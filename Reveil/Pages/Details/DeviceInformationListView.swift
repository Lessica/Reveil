//
//  DeviceInformationListView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import SwiftUI

struct DeviceInformationListView: View, ModuleListView {
    let module: Module = DeviceInformation.shared
    let globalName: String = .init(describing: DeviceInformation.self)

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

    func eventOccurred(globalTimer _: GlobalTimer) {}
}

// MARK: - Previews

struct DeviceInformationListView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceInformationListView()
            .environmentObject(HighlightedEntryKey())
    }
}
