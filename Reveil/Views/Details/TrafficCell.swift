//
//  TrafficCell.swift
//  Reveil
//
//  Created by Lessica on 2023/10/3.
//

import SwiftUI

struct TrafficCell: View {
    @ObservedObject var entry: TrafficEntry<Int64>

    private let columnWidth: CGFloat = 2
    private let minColumnSpacing: CGFloat = 3
    private let rowHeight: CGFloat = 36

    private func limitedValues(metricWidth: CGFloat) -> [(offset: Int, element: Double)] {
        let limitedCount = Int((metricWidth - columnWidth) / (columnWidth + minColumnSpacing))
        let beginIndex = max(0, entry.values.count - limitedCount)
        let limitedItems = Array(entry.values[beginIndex...])
        let missingItems = Array(repeating: Int64(0), count: max(0, limitedCount - entry.values.count))
        let fulfilledItems = missingItems + limitedItems
        let maxItem = fulfilledItems.map { abs($0) }.max() ?? 0
        var maxValue = Double(maxItem)
        if maxItem == 0 {
            maxValue = Double.infinity
        }
        let enumatedItems = Array(fulfilledItems.map {
            Double($0) / maxValue
        }.enumerated())
        return enumatedItems
    }

    var body: some View {
        VStack {
            GeometryReader { metrics in
                HStack(spacing: 0) {
                    ForEach(limitedValues(metricWidth: metrics.size.width), id: \.offset) { value in
                        Spacer(minLength: minColumnSpacing)
                        Rectangle()
                            .foregroundColor(.secondary
                                .opacity(value.element > 0 ? 1.0 : 0.5))
                            .frame(
                                width: columnWidth,
                                height: max(metrics.size.height * min(abs(value.element), 1), 1)
                            )
                            .frame(maxHeight: .infinity, alignment: .bottom)
                    }
                }
                .frame(maxWidth: metrics.size.width)
            }
            .frame(height: rowHeight)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.top, .bottom])
    }
}

// MARK: - Previews

struct TrafficCell_Previews: PreviewProvider {
    static var previews: some View {
        TrafficCell(
            entry: TrafficEntry(
                child: BasicEntry(
                    key: .NetworkCategoryBytesDownload(prefix: NetworkPrefix.en.rawValue),
                    name: "Download",
                    value: "0 Bps\n0 B"
                ),
                values: [
                    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0,
                    0, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,
                    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0,
                    0, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,
                    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0,
                    0, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,
                ]
            )
        )
        .padding([.leading, .trailing])
        .previewLayout(.sizeThatFits)
    }
}
