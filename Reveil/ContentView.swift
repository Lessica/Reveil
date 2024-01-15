//
//  ContentView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/2.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var useTabs: Bool {
        if horizontalSizeClass == .compact {
            return true
        }
        #if canImport(UIKit)
            if UIDevice.current.userInterfaceIdiom != .pad {
                return true
            }
        #endif
        return false
    }

    var body: some View {
        if useTabs {
            TabsView()
        } else {
            SidebarView()
        }
    }
}

struct TabsView: View {
    var body: some View {
        TabView {
            NavigationView {
                DashboardView()
                    .navigationBarAttachBrand()
                    .background(ColorfulBackground())
            }
            .tabItem {
                Label(NSLocalizedString("DASHBOARD", comment: "Dashboard"), systemImage: "square.grid.2x2")
            }

            NavigationView {
                DetailsView()
                    .navigationBarAttachBrand()
            }
            .tabItem {
                Label(NSLocalizedString("DETAILS", comment: "Details"), systemImage: "doc.text")
            }

            NavigationView {
                AboutView()
                #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                #endif
                    .background(ColorfulBackground())
            }
            .tabItem {
                Label(NSLocalizedString("ABOUT", comment: "About"), systemImage: "info.circle")
            }
        }
    }
}

struct SidebarView: View {
    var body: some View {
        NavigationView {
            List {
                Section(NSLocalizedString("DASHBOARD", comment: "Dashboard")) {
                    NavigationLink {
                        DashboardView()
                            .navigationTitle(NSLocalizedString("DASHBOARD", comment: "Dashboard"))
                            .background(ColorfulBackground())
                            .limitMinSize()
                    } label: {
                        Label(NSLocalizedString("DASHBOARD", comment: "Dashboard"), systemImage: "square.grid.2x2")
                    }
                    .buttonStyle(.plain)
                }

                Section(NSLocalizedString("DETAILS", comment: "Details")) {
                    DetailsView.createDetailsList()
                }

                Section(NSLocalizedString("ABOUT", comment: "About")) {
                    NavigationLink {
                        AboutView()
                            .background(ColorfulBackground())
                            .limitMinSize()
                    } label: {
                        Label(NSLocalizedString("ABOUT", comment: "About"), systemImage: "info.circle")
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle(NSLocalizedString("Reveil", comment: "Reveil"))

            DashboardView()
                .navigationTitle(NSLocalizedString("DASHBOARD", comment: "Dashboard"))
                .background(ColorfulBackground())
                .limitMinSize()
        }
        .listStyle(SidebarListStyle())
        #if canImport(AppKit)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button {
                        NSApp.sendAction(#selector(NSSplitViewController.toggleSidebar(_:)), to: nil, from: nil)
                    } label: {
                        Label("Toggle Sidebar", systemImage: "sidebar.leading")
                    }
                }
            }
        #endif
    }
}

extension View {
    @ViewBuilder
    func limitMinSize() -> some View {
        frame(minWidth: 550, minHeight: 350)
    }
}

// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
