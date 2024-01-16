//
//  NetworkDetailListView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/12.
//

import SwiftUI

struct NetworkDetailListView: View, Identifiable, ModuleListView, GlobalTimerObserver {
    let id = UUID()
    let module: Module = NetworkDetails.shared
    let globalName: String = .init(describing: NetworkDetails.self)

    init?(entryKey: EntryKey) {
        switch entryKey {
        case let .NetworkCategoryBytesDownload(prefix): fallthrough
        case let .NetworkCategoryBytesUpload(prefix):
            guard let pfx = NetworkPrefix(rawValue: prefix) else {
                return nil
            }
            item = pfx
        default:
            return nil
        }
    }

    init(item: NetworkPrefix) {
        self.item = item
    }

    let item: NetworkPrefix

    @State var entries: [BasicEntry] = []
    @State var trafficEntries: [TrafficEntry<Int64>] = []

    var body: some View {
        DetailsListView(
            basicEntries: entries,
            trafficEntries: trafficEntries
        )
        .navigationTitle(item.description)
        .onAppear {
            if let module = module as? NetworkDetails {
                entries = module.entries(prefix: item)
                trafficEntries = module.trafficEntries(prefix: item)
                trafficEntries.forEach { $0.invalidate() }
            }
            GlobalTimer.shared.addObserver(self)
        }
        .onDisappear {
            GlobalTimer.shared.removeObserver(self)
        }
    }

    func eventOccurred(globalTimer _: GlobalTimer) {
        if let module = module as? NetworkDetails {
            module.update(prefix: item)
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
