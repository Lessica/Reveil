//
//  ActivityWidget.swift
//  Reveil
//
//  Created by Lessica on 2023/10/2.
//

import SwiftUI

struct ActivityWidget: View {
    @StateObject var entry: ActivityEntry

    private let columnWidth: CGFloat = 2
    private let minColumnSpacing: CGFloat = 3
    private let rowHeight: CGFloat = 24

    private func limitedValues(metricWidth: CGFloat) -> [(offset: Int, element: Double)] {
        let entryValues = entry.values
        let limitedCount = Int((metricWidth - columnWidth) / (columnWidth + minColumnSpacing))
        let beginIndex = max(0, entryValues.count - limitedCount)
        let limitedItems = Array(entryValues[beginIndex...])
        let missingItems = Array(repeating: 0.0, count: max(0, limitedCount - entryValues.count))
        let fulfilledItems = missingItems + limitedItems
        let enumatedItems = Array(fulfilledItems.enumerated())
        return enumatedItems
    }

    var body: some View {
        VStack {
            HStack {
                Text(entry.name.uppercased())
                    .font(Font.system(.body))
                    .fontWeight(.bold)
                    .foregroundColor(Color(PlatformColor.labelAlias))
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(Font.system(.body).weight(.regular))
                    .foregroundColor(Color(PlatformColor.tertiaryLabelAlias))
            }

            Spacer(minLength: 2)
                .frame(height: 2)

            HStack {
                AnimatedText(String(format: "%.2f%%", Double(entry.values.last ?? 0) * 100.0))
                    .font(Font.system(.title).weight(.medium))
                    .foregroundColor(.accentColor)
                    .lineLimit(1)
                Spacer()
            }

            Spacer(minLength: 8)
                .frame(height: 8)

            GeometryReader { metrics in
                HStack(spacing: 0) {
                    ForEach(limitedValues(metricWidth: metrics.size.width), id: \.offset) { value in
                        Spacer(minLength: minColumnSpacing)
                        VStack {
                            Spacer(minLength: 0)
                            Rectangle()
                                .foregroundColor(.secondary)
                                .frame(width: columnWidth,
                                       height: max(metrics.size.height * min(value.element, 1), 1))
                        }
                    }
                }
                .frame(maxWidth: metrics.size.width)
            }
            .frame(height: rowHeight)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Previews

struct ActivityWidget_Previews: PreviewProvider {
    static let values = [
        0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0,
        1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0.0,
        0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0,
        1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0.0,
        0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0,
        1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0.0,
    ]
    static var previews: some View {
        ActivityWidget(entry: ActivityEntry(
            child: BasicEntry(key: .CPUUsageLoad, name: "Usage"),
            values: values
        ))
        .padding(.all)
    }
}
