//
//  FileSystemsListView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/6.
//

import SwiftUI

struct FileSystemsListView: View, ModuleListView {
    let module: Module = FileSystems.shared
    let globalName: String = String(describing: FileSystems.self)

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
            .listSectionSeparator(hidden: true)
        }
        .listStyle(.plain)
        .frame(maxWidth: .infinity)
        .navigationTitle(module.moduleName)
        .navigationBarItems(
            trailing: PinButton(pin: AppCodableStorage(
                wrappedValue: Pin(false), .FileSystems,
                store: PinStorage.shared.userDefaults
            ))
        )
        .onAppear {
            FileSystems.shared.reloadData()
            items = FileSystems.shared.items
        }
    }

    func eventOccurred(globalTimer timer: GlobalTimer) { }
}

// MARK: - Previews

struct FileSystemsListView_Previews: PreviewProvider {
    static var previews: some View {
        FileSystemsListView()
            .environmentObject(HighlightedEntryKey())
    }
}
