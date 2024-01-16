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
        #if os(macOS)
        .buttonStyle(.plain)
        #endif
    }

    static func createDetailsList() -> some View {
        Group {
            Group {
                createEntry(title: DeviceInformation.shared.moduleName, icon: "desktopcomputer") {
                    prepareContent {
                        DeviceInformationListView()
                    }
                }
                createEntry(title: Security.shared.moduleName, icon: "lock.shield") {
                    prepareContent {
                        SecurityView()
                    }
                }
                createEntry(title: OperatingSystem.shared.moduleName, icon: "gearshape") {
                    prepareContent {
                        OperatingSystemListView()
                    }
                }
                createEntry(title: CPUInformation.shared.moduleName, icon: "cpu") {
                    prepareContent {
                        CPUInformationListView()
                    }
                }
            }
            Group {
                createEntry(title: MemoryInformation.shared.moduleName, icon: "memorychip") {
                    prepareContent {
                        MemoryInformationListView()
                    }
                }
                createEntry(title: DiskSpace.shared.moduleName, icon: "externaldrive") {
                    prepareContent {
                        DiskSpaceListView()
                    }
                }
                createEntry(title: FileSystems.shared.moduleName, icon: "folder") {
                    prepareContent {
                        FileSystemsListView()
                    }
                }
            }
            Group {
                createEntry(title: NetworkInterfaces.shared.moduleName, icon: "network") {
                    prepareContent {
                        NetworkInterfacesListView()
                    }
                }
                createEntry(title: NetworkDetails.shared.moduleName, icon: "antenna.radiowaves.left.and.right") {
                    prepareContent {
                        NetworkDetailsListView()
                    }
                }
                createEntry(title: NetworkUsage.shared.moduleName, icon: "waveform.path.ecg") {
                    prepareContent {
                        NetworkUsageListView()
                    }
                }
            }
            Group {
                createEntry(title: BatteryInformation.shared.moduleName, icon: "battery.100") {
                    prepareContent {
                        BatteryInformationListView()
                    }
                }
            }
        }
        .listSectionSeparator(topHidden: true)
    }

    private static func prepareContent(_ input: @escaping () -> some View) -> some View {
        #if canImport(AppKit)
        return GeometryReader { r in
            NavigationView {
                input()
                    .frame(width: r.size.width / 2)
                Text(NSLocalizedString("Reveil", comment: "Reveil"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .limitMinSize()
        #endif
        #if canImport(UIKit)
        return input()
        #endif
    }

    var body: some View {
        List {
            Self.createDetailsList()
        }
        .listStyle(.plain)
        .listSectionSeparator(hidden: true)
    }
}

#if os(macOS)
fileprivate extension View {
    @ViewBuilder
    func limitMinSize() -> some View {
        frame(minWidth: 550, minHeight: 350)
    }
}
#endif

// MARK: - Previews

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView()
    }
}
