//
//  FileSystemsListView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/6.
//

import SwiftUI

struct FileSystemsListView: View, ModuleListView {
    let module: Module = FileSystems.shared

    init() {}

    init?(entryKey: EntryKey) {
        guard module.updatableEntryKeys.contains(entryKey) else {
            return nil
        }
    }

    @Environment(\.dismiss) private var dismissAction

    @State var items: [FileSystem] = []

    var body: some View {
        List {
            Section {
                ForEach(items, id: \.id) { entry in
                    NavigationLink(entry.path) {
                        FileSystemListView(item: entry)
                            .environmentObject(HighlightedEntryKey())
                    }
                }
            }
            .listSectionSeparator(.hidden)
        }
        .listStyle(.plain)
        .frame(maxWidth: .infinity)
        .navigationTitle(module.moduleName)
        .navigationBarItems(
            trailing: PinButton(pin: AppCodableStorage(
                wrappedValue: Pin(false), String(describing: FileSystems.self),
                store: PinStorage.shared.userDefaults
            ))
        )
        .onAppear {
            FileSystems.shared.reloadData()
            items = FileSystems.shared.items
        }
    }
}

// MARK: - Previews

struct FileSystemsListView_Previews: PreviewProvider {
    static var previews: some View {
        FileSystemsListView()
            .environmentObject(HighlightedEntryKey())
    }
}
