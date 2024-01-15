//
//  DashboardView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/2.
//

import SwiftUI

struct DashboardView: View, GlobalTimerObserver {
    let id = UUID()
    let globalName: String = .init(describing: Dashboard.self)

    @ObservedObject private var viewModel = Dashboard.shared
    @ObservedObject private var securityModel = Security.shared
    @State private var isNavigationLinkActive = false

    var body: some View {
        ScrollView(.vertical) {
            VStack {
                #if !os(macOS)
                    if PinStorage.shared.isPinned(forKey: .Security) {
                        Section { CheckmarkWidget() }
                    }
                #endif

                ForEach(viewModel.entries, id: \.key) { entry in
                    Section {
                        widgetBuilder(entry)
                            .padding(.all, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .foregroundColor(Color.secondarySystemBackgroundAlias)
                                    .opacity(0.2)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.separatorAlias, lineWidth: 1)
                            }
                            .overlay { navigationLinkBuilder(entry) }
                    }
                    .padding(entry === viewModel.entries.last ? .bottom : [], 8)
                    .listSectionSeparator(hidden: true)
                }
            }
            .padding()
        }
        .onAppear {
            GlobalTimer.shared.addObserver(self)
        }
        .onDisappear {
            GlobalTimer.shared.removeObserver(self)
        }
    }

    @ViewBuilder
    private func widgetBuilder(_ entry: any Entry) -> some View {
        if let basicEntry = entry as? BasicEntry {
            fieldWidgetBuilder(basicEntry)
        } else if let usageEntry = entry as? UsageEntry<Double> {
            usageWidgetBuilder(usageEntry)
        } else if let activityEntry = entry as? ActivityEntry {
            activityWidgetBuilder(activityEntry)
        } else if let trafficEntryIO = entry as? TrafficEntryIO {
            trafficWidgetBuilder(trafficEntryIO)
        }
    }

    @ViewBuilder
    private func fieldWidgetBuilder(_ entry: BasicEntry) -> some View {
        FieldWidget(entry: entry)
    }

    @ViewBuilder
    private func activityWidgetBuilder(_ entry: ActivityEntry) -> some View {
        ActivityWidget(entry: entry)
    }

    @ViewBuilder
    private func usageWidgetBuilder(_ entry: UsageEntry<Double>) -> some View {
        UsageWidget(entry: entry)
    }

    @ViewBuilder
    private func trafficWidgetBuilder(_ entry: TrafficEntryIO) -> some View {
        TrafficWidget(label: entry.name, style: .compat, receivedEntry: entry.download, sentEntry: entry.upload)
    }

    @ViewBuilder
    private func navigationLinkBuilder(_ entry: any Entry) -> some View {
        NavigationLink(destination: {
            viewModel.anyListView(key: entry.key)
                .environmentObject(HighlightedEntryKey(object: entry.key))
        }, label: { Color.clear })
            .buttonStyle(.plain)
            .contentShape(Rectangle())
    }

    func eventOccurred(globalTimer _: GlobalTimer) {
        viewModel.updateEntries()
    }
}

// MARK: - Previews

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
