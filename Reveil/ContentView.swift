//
//  ContentView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/2.
//

import UIKit

import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var useTabs: Bool {
        if horizontalSizeClass == .compact {
            return true
        }
        if UIDevice.current.userInterfaceIdiom != .pad {
            return true
        }
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
                    .navigationBarTitleDisplayMode(.inline)
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
                    } label: {
                        Label(NSLocalizedString("DASHBOARD", comment: "Dashboard"), systemImage: "square.grid.2x2")
                    }
                }

                Section(NSLocalizedString("DETAILS", comment: "Details")) {
                    DetailsView.createDetailsList()
                }

                Section(NSLocalizedString("ABOUT", comment: "About")) {
                    NavigationLink {
                        AboutView()
                            .background(ColorfulBackground())
                    } label: {
                        Label(NSLocalizedString("ABOUT", comment: "About"), systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle(NSLocalizedString("Reveil", comment: "Reveil"))

            DashboardView()
                .navigationTitle(NSLocalizedString("DASHBOARD", comment: "Dashboard"))
                .background(ColorfulBackground())
        }
        .listStyle(SidebarListStyle())
    }
}

// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
