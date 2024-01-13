//
//  NetworkDetailsListView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/12.
//

import SwiftUI

struct NetworkDetailsListView: View, ModuleListView {
    let module: Module = NetworkDetails.shared

    init() {}

    init?(entryKey _: EntryKey) { nil }

    @Environment(\.dismiss) private var dismissAction

    @State var items: [NetworkPrefix] = []

    @ViewBuilder
    func childDetailListView(prefix: NetworkPrefix) -> some View {
        NavigationLink(prefix.description) {
            NetworkDetailListView(item: prefix)
                .environmentObject(HighlightedEntryKey())
        }
    }

    var body: some View {
        List {
            Section {
                ForEach(items, id: \.id) { item in
                    childDetailListView(prefix: item)
                }
            }
            .listSectionSeparator(hidden: true)
        }
        .listStyle(.plain)
        .frame(maxWidth: .infinity)
        .navigationTitle(module.moduleName)
        .onAppear {
            items = NetworkPrefix.categoryCases
        }
    }
}

// MARK: - Previews

struct NetworkDetailsListView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkDetailsListView()
            .environmentObject(HighlightedEntryKey())
    }
}
