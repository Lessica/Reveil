//
//  NetworkInterfacesListView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/6.
//

import SwiftUI

struct NetworkInterfacesListView: View, ModuleListView {
    let module: Module = NetworkInterfaces.shared
    let globalName: String = .init(describing: NetworkInterfaces.self)

    init() {}

    init?(entryKey: EntryKey) {
        guard module.updatableEntryKeys.contains(entryKey) else {
            return nil
        }
    }

    @Environment(\.dismiss) private var dismissAction

    @State var items: [NetworkInterface] = []

    var body: some View {
        List {
            Section {
                ForEach(items, id: \.id) { entry in
                    NavigationLink(entry.alias) {
                        NetworkInterfaceListView(item: entry)
                            .environmentObject(HighlightedEntryKey())
                    }
                    .buttonStyle(.plain)
                }
            }
            .listSectionSeparator(hidden: true)
        }
        .listStyle(.plain)
        .frame(maxWidth: .infinity)
        .navigationTitle(module.moduleName)
        .toolbar {
            ToolbarItem {
                PinButton(pin: AppCodableStorage(
                    wrappedValue: Pin(false), .NetworkInterfaces,
                    store: PinStorage.shared.userDefaults
                ))
            }
        }
        .onAppear {
            NetworkInterfaces.shared.reloadData()
            items = NetworkInterfaces.shared.items
        }
    }

    func eventOccurred(globalTimer _: GlobalTimer) {}
}

// MARK: - Previews

struct NetworkInterfacesListView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkInterfacesListView()
            .environmentObject(HighlightedEntryKey())
    }
}
