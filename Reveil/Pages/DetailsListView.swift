//
//  DetailsListView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import SwiftUI
import SwiftUIBackports

struct DetailsListView: View, FieldCellDelegate {
    let basicEntries: [BasicEntry]
    var trafficEntries: [TrafficEntry<Int64>]? = nil
    var usageEntry: UsageEntry<Double>? = nil
    var usageStyle: UsageCell.Style = .regular

    private let pasteboard = UIPasteboard.general

    @Environment(\.backportDismiss) private var dismissAction
    @EnvironmentObject private var highlightedEntryKey: HighlightedEntryKey

    @State private var selectedEntryKey: EntryKey?
    @State private var selectedEntryKeys = Set<EntryKey>()

    var body: some View {
        ScrollViewReader { proxy in
            List(selection: $selectedEntryKeys) {
                if let usageEntry {
                    Section {
                        UsageCell(entry: usageEntry, style: usageStyle)
                    }
                    .listSectionSeparator(hidden: true)
                    .listRowBackground(Color.clear)
                }

                if let trafficEntries {
                    Section {
                        ForEach(trafficEntries, id: \.key) { entry in
                            VStack {
                                TrafficCell(entry: entry)
                                if let basicChild = entry.basicChild {
                                    FieldCell(entry: basicChild, delegate: self)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .listSectionSeparator(topHidden: true)
                    .listSectionSeparator(bottomHidden: false)
                    .listRowBackground(Color.clear)
                }

                sectionGroupBuilder(basicEntries)
            }
            .listStyle(.plain)
            .frame(maxWidth: .infinity)
            .backport.overlay(alignment: .bottom) { toastOverlay() }
            .onAppear {
                if let object = highlightedEntryKey.object {
                    selectedEntryKeys.removeAll(keepingCapacity: true)

                    selectedEntryKey = object
                    selectedEntryKeys.insert(object)

                    withAnimation(.easeInOut(duration: 0.6)) {
                        proxy.scrollTo(object, anchor: .center)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        selectedEntryKey = nil
                        selectedEntryKeys.removeAll(keepingCapacity: true)
                    }
                } else {
                    selectedEntryKeys.removeAll(keepingCapacity: false)
                }
            }
        }
    }

    private struct SectionGroup: Identifiable {
        var id: ObjectIdentifier { sectionEntry.id }

        private let sectionEntry: BasicEntry
        private var nestedEntries: [BasicEntry]

        static let `default` = SectionGroup(sectionEntry: BasicEntry.emptySection)

        var title: String { sectionEntry.name }
        var entries: [BasicEntry] { nestedEntries }

        init(sectionEntry: BasicEntry) {
            self.sectionEntry = sectionEntry
            nestedEntries = []
        }

        mutating func addEntry(_ entry: BasicEntry) {
            nestedEntries.append(entry)
        }
    }

    private func makeSectionGroups(_ entries: [BasicEntry]) -> [SectionGroup] {
        var entryGroups = [SectionGroup]()
        var lastGroup = SectionGroup.default
        for entry in entries {
            if case .Section = entry.key {
                entryGroups.append(lastGroup)
                lastGroup = SectionGroup(sectionEntry: entry)
            } else {
                lastGroup.addEntry(entry)
            }
        }
        entryGroups.append(lastGroup)
        return entryGroups
    }

    @ViewBuilder
    private func sectionGroupBuilder(_ entries: [BasicEntry]) -> some View {
        ForEach(makeSectionGroups(entries), id: \.id) { entryGroup in
            if entryGroup.title.isEmpty {
                Section {
                    sectionBuilder(entryGroup.entries)
                }
                .listSectionSeparator(hidden: true)
            } else {
                Backport.Section(entryGroup.title) {
                    sectionBuilder(entryGroup.entries)
                }
                .listSectionSeparator(hidden: true)
            }
        }
    }

    @ViewBuilder
    private func sectionBuilder(_ entries: [BasicEntry]) -> some View {
        ForEach(entries, id: \.key) { entry in
            cellBuilder(entry)
        }
    }

    @ViewBuilder
    private func cellBuilder(_ entry: BasicEntry) -> some View {
        if let children = entry.children, children.count > 0 {
            NavigationLink {
                DetailsListView(basicEntries: children)
                    .environmentObject(highlightedEntryKey)
                    .navigationTitle(entry.name)
            } label: {
                FieldCell(entry: entry, delegate: self)
            }
        } else {
            Button {
                var valueToCopy: String?
                if !entry.value.isEmpty {
                    valueToCopy = entry.value
                } else if case .AllowedToCopy = entry.key {
                    valueToCopy = entry.name
                }
                if let valueToCopy {
                    pasteboard.string = valueToCopy
                    showToast(
                        message: NSLocalizedString("COPIED_TO_CLIPBOARD", comment: "Copied to clipboard"),
                        icon: "info.circle.fill"
                    )

                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }
            } label: {
                FieldCell(entry: entry, delegate: self)
            }
            .listRowBackground(selectedEntryKey == entry.key ? Color(PlatformColor.systemGray4Alias) : nil)
        }
    }

    @State private var toastShown = false
    @State private var toastTimer: Timer?
    @State private var toastLabel: String?
    @State private var toastIconName: String?

    func showToast(message: String, icon: String, dismissInterval: TimeInterval = 2) {
        toastLabel = message
        toastIconName = icon
        toastTimer?.invalidate()
        let delay = toastShown ? 0.25 : 0
        toastShown = false
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            toastShown = true
            toastTimer = Timer.scheduledTimer(
                withTimeInterval: dismissInterval,
                repeats: false,
                block: { _ in
                    toastShown = false
                }
            )
        }
    }

    @ViewBuilder
    private func toastOverlay() -> some View {
        ZStack {
            if toastShown,
               let toastLabel,
               let toastIconName
            {
                ToastView(label: toastLabel, iconName: toastIconName)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .animation(.spring(duration: 0.25, bounce: 0.2, blendDuration: 1), value: toastShown)
    }
}

// MARK: - Previews

struct DetailsListView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsListView(basicEntries: DeviceInformation.shared.basicEntries)
    }
}
