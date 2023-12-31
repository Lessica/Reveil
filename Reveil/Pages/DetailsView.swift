//
//  DetailsView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/2.
//

import SwiftUI

struct DetailsView: View {
    static func createEntry(title: String, icon: String, view: () -> (some View)) -> some View {
        NavigationLink {
            view()
                .environmentObject(HighlightedEntryKey())
        } label: {
            Label(title, systemImage: icon)
        }
    }

    static func createDetailsList() -> some View {
        Group {
            Group {
                createEntry(title: DeviceInformation.shared.moduleName, icon: "desktopcomputer") {
                    DeviceInformationListView()
                }
                createEntry(title: Security.shared.moduleName, icon: "lock.shield") {
                    SecurityView()
                }
                createEntry(title: OperatingSystem.shared.moduleName, icon: "gearshape") {
                    OperatingSystemListView()
                }
                createEntry(title: CPUInformation.shared.moduleName, icon: "cpu") {
                    CPUInformationListView()
                }
            }
            Group {
                createEntry(title: MemoryInformation.shared.moduleName, icon: "memorychip") {
                    MemoryInformationListView()
                }
                createEntry(title: DiskSpace.shared.moduleName, icon: "externaldrive") {
                    DiskSpaceListView()
                }
                createEntry(title: FileSystems.shared.moduleName, icon: "folder") {
                    FileSystemsListView()
                }
            }
            Group {
                createEntry(title: NetworkInterfaces.shared.moduleName, icon: "network") {
                    NetworkInterfacesListView()
                }
                createEntry(title: NetworkDetails.shared.moduleName, icon: "antenna.radiowaves.left.and.right") {
                    NetworkDetailsListView()
                }
                createEntry(title: NetworkUsage.shared.moduleName, icon: "waveform.path.ecg") {
                    NetworkUsageListView()
                }
            }
            Group {
                createEntry(title: BatteryInformation.shared.moduleName, icon: "battery.100") {
                    BatteryInformationListView()
                }
            }
        }
        .listSectionSeparator(.hidden, edges: .top)
    }

    var body: some View {
        List {
            Self.createDetailsList()
        }
        .listStyle(.plain)
        .listSectionSeparator(.hidden)
    }
}

// MARK: - Previews

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView()
    }
}
