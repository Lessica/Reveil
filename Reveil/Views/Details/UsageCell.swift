//
//  UsageCell.swift
//  Reveil
//
//  Created by Lessica on 2023/10/3.
//

import SwiftUI

struct UsageCell: View {
    enum Style {
        case regular
        case compat
    }

    private struct RatioItem: Identifiable, Hashable, Equatable {
        var id: Int { hashValue }

        let label: String
        let ratio: Double
        let color: Color

        init(label: String, ratio: Double, color: Color) {
            self.label = label
            self.ratio = ratio
            self.color = color
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(label)
            hasher.combine(color)
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.label == rhs.label && lhs.ratio == rhs.ratio && lhs.color == rhs.color
        }
    }

    @ObservedObject var entry: UsageEntry<Double>
    var style: Style = .regular

    private let minimumDisplayableRatio: Double = 0.001
    private let regularRowHeight: CGFloat = 24
    private let compactRowHeight: CGFloat = 18

    private var ratioItem: [RatioItem] {
        let totalValue = entry.items.reduce(0) { $0 + $1.value }
        guard !totalValue.isNaN else {
            return []
        }
        return entry.items.compactMap {
            let itemRatio = $0.value / totalValue
            if itemRatio < minimumDisplayableRatio { return nil }
            return RatioItem(label: $0.label, ratio: itemRatio, color: $0.color)
        }
    }

    var body: some View {
        GeometryReader { metrics in
            ZStack(alignment: .leading) {
                Color(PlatformColor.secondarySystemFillAlias)

                HStack(spacing: 0) {
                    ForEach(ratioItem, id: \.id) { item in
                        item.color.frame(width: metrics.size.width * item.ratio)
                            .animation(.spring(duration: 0.25, bounce: 0, blendDuration: 0.8), value: item)
                    }
                }
            }
            .frame(maxWidth: metrics.size.width)
            .cornerRadius(4)
        }
        .frame(height: style == .regular ? regularRowHeight : compactRowHeight)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Previews

struct UsageCell_Previews: PreviewProvider {
    static var previews: some View {
        UsageCell(entry: UsageEntry(
            key: .MemoryInformation,
            name: MemoryInformation.shared.moduleName,
            items: [
                UsageEntry.Item(label: "Wired", value: 0.1771, color: Color("MemoryWired")),
                UsageEntry.Item(label: "Active", value: 0.3179, color: Color("MemoryActive")),
                UsageEntry.Item(label: "Inactive", value: 0.2474, color: Color("MemoryInactive")),
                UsageEntry.Item(label: "Purgeable", value: 0.0173, color: Color("MemoryPurgeable")),
                UsageEntry.Item(label: "Others", value: 0.1195, color: Color("MemoryOthers")),
                UsageEntry.Item(label: "Free", value: 0.1208, color: Color.clear),
            ]
        ))
    }
}
