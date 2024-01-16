//
//  NetworkInterfaceListView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/6.
//

import SwiftUI

struct NetworkInterfaceListView: View, ModuleListView {
    let module: Module = NetworkInterfaces.shared
    let globalName: String = .init(describing: NetworkInterfaces.self)

    init?(entryKey _: EntryKey) { nil }

    init(item: NetworkInterface) {
        self.item = item
    }

    let item: NetworkInterface

    @State var entries: [BasicEntry] = []

    var body: some View {
        DetailsListView(basicEntries: entries)
            .navigationTitle(item.alias)
            .onAppear {
                entries = NetworkInterfaces.shared.entries(interface: item)
            }
    }

    func eventOccurred(globalTimer _: GlobalTimer) {}
}

// MARK: - Previews

struct NetworkInterfaceListView_Previews: PreviewProvider {
    static var previews: some View {
        if let ethernetStructs = System.interfaceAddresses(name: "en0").first {
            NetworkInterfaceListView(item: NetworkInterface(rawValue: ethernetStructs))
                .environmentObject(HighlightedEntryKey())
        }
    }
}
