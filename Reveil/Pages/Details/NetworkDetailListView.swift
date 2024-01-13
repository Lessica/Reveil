//
//  NetworkDetailListView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/12.
//

import SwiftUI

struct NetworkDetailListView: View, ModuleListView {
    let module: Module = NetworkDetails.shared

    init?(entryKey: EntryKey) {
        switch entryKey {
        case let .NetworkCategoryBytesDownload(prefix): fallthrough
        case let .NetworkCategoryBytesUpload(prefix):
            guard let pfx = NetworkPrefix(rawValue: prefix) else {
                return nil
            }
            self.item = pfx
        default:
            return nil
        }
    }

    init(item: NetworkPrefix) {
        self.item = item
    }

    @State private var shouldTick: Bool = false

    let item: NetworkPrefix

    @State var entries: [BasicEntry] = []
    @State var trafficEntries: [TrafficEntry<Int64>] = []

    var body: some View {
        DetailsListView(
            basicEntries: entries,
            trafficEntries: trafficEntries
        )
        .navigationTitle(item.description)
        .onReceive(GlobalTimer.shared.$tick) { _ in
            if shouldTick, let module = module as? NetworkDetails {
                module.update(prefix: item)
            }
        }
        .onAppear {
            if let module = module as? NetworkDetails {
                entries = module.entries(prefix: item)
                trafficEntries = module.trafficEntries(prefix: item)
                trafficEntries.forEach { $0.invalidate() }
            }
            shouldTick = true
        }
        .onDisappear {
            shouldTick = false
        }
    }
}

// MARK: - Previews

struct NetworkDetailListView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkDetailListView(item: NetworkPrefix.en)
            .environmentObject(HighlightedEntryKey())
    }
}
