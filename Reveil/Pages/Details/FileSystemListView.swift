//
//  FileSystemListView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import SwiftUI

struct FileSystemListView: View, ModuleListView {
    let module: Module = FileSystems.shared
    let globalName: String = String(describing: FileSystems.self)

    init?(entryKey _: EntryKey) { nil }

    init(item: FileSystem) {
        self.item = item
    }

    let item: FileSystem

    @State var entries: [BasicEntry] = []

    var body: some View {
        DetailsListView(basicEntries: entries)
            .navigationTitle(item.path)
            .onAppear {
                entries = FileSystems.shared.entries(fs: item)
            }
    }

    func eventOccurred(globalTimer timer: GlobalTimer) { }
}

// MARK: - Previews

struct FileSystemListView_Previews: PreviewProvider {
    static var previews: some View {
        FileSystemListView(item: FileSystem(path: "/"))
            .environmentObject(HighlightedEntryKey())
    }
}
