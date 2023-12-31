//
//  TrafficWidget.swift
//  Reveil
//
//  Created by Lessica on 2023/10/2.
//

import SwiftUI

private let gTrafficFormatter: ByteCountFormatter = {
    let formatter = ByteCountFormatter()
    formatter.countStyle = .memory
    formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
    return formatter
}()

struct TrafficWidget: View {
    enum Style {
        case regular
        case compat
    }

    let label: String
    let style: Style

    @StateObject var receivedEntry: TrafficEntry<Int64>
    @StateObject var sentEntry: TrafficEntry<Int64>

    private let columnWidth: CGFloat = 2
    private let minColumnSpacing: CGFloat = 3

    private let rowHeight: CGFloat = 24

    private func limitedReceivedValues(metricWidth: CGFloat) -> [(offset: Int, element: Double)] {
        let limitedCount = Int((metricWidth - columnWidth) / (columnWidth + minColumnSpacing))
        let beginIndex = max(0, receivedEntry.values.count - limitedCount)
        let limitedItems = Array(receivedEntry.values[beginIndex...])
        let missingItems = Array(repeating: Int64(0), count: max(0, limitedCount - receivedEntry.values.count))
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

    private func limitedSentValues(metricWidth: CGFloat) -> [(offset: Int, element: Double)] {
        let limitedCount = Int((metricWidth - columnWidth) / (columnWidth + minColumnSpacing))
        let beginIndex = max(0, sentEntry.values.count - limitedCount)
        let limitedItems = Array(sentEntry.values[beginIndex...])
        let missingItems = Array(repeating: Int64(0), count: max(0, limitedCount - sentEntry.values.count))
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

    private var receivedDescription: String {
        gTrafficFormatter.string(fromByteCount: abs(receivedEntry.values.last ?? 0))
    }

    private var sentDescription: String {
        gTrafficFormatter.string(fromByteCount: abs(sentEntry.values.last ?? 0))
    }

    @ViewBuilder
    private func receivedView(_ metrics: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            ForEach(limitedReceivedValues(metricWidth: style == .regular ? metrics.size.width : metrics.size.width / 2), id: \.offset) { value in
                Spacer(minLength: minColumnSpacing)
                VStack {
                    Spacer(minLength: 0)
                    Rectangle()
                        .foregroundColor(.secondary
                            .opacity(value.element > 0 ? 1.0 : 0.5))
                        .frame(width: columnWidth,
                               height: max(metrics.size.height * min(abs(value.element), 1), 1))
                }
            }
        }
        .frame(maxWidth: style == .regular ? metrics.size.width : metrics.size.width / 2)
    }

    @ViewBuilder
    private func sentView(_ metrics: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            ForEach(limitedSentValues(
                metricWidth: style == .regular ? metrics.size.width : metrics.size.width / 2), id: \.offset)
            { value in
                Spacer(minLength: minColumnSpacing)
                VStack {
                    Spacer(minLength: 0)
                    Rectangle()
                        .foregroundColor(.secondary
                            .opacity(value.element > 0 ? 1.0 : 0.5))
                        .frame(width: columnWidth,
                               height: max(metrics.size.height * min(abs(value.element), 1), 1))
                }
            }
        }
        .frame(maxWidth: style == .regular ? metrics.size.width : metrics.size.width / 2)
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(label.uppercased())
                    .font(Font.system(.body))
                    .fontWeight(.bold)
                    .foregroundColor(Color(PlatformColor.labelAlias))
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(Font.system(.body).weight(.regular))
                    .foregroundColor(Color(PlatformColor.tertiaryLabelAlias))
            }

            GeometryReader { metrics in
                HStack(alignment: .bottom) {
                    HStack {
                        Image(systemName: "arrow.down.backward")
                            .font(Font.system(.body).weight(.regular))
                            .foregroundColor(Color(PlatformColor.secondaryLabelAlias))

                        AnimatedText(receivedDescription)
                            .font(Font.system(.body).weight(.regular))
                            .foregroundColor(Color(PlatformColor.secondaryLabelAlias))
                            .lineLimit(1)
                    }

                    Spacer()

                    if style == .compat {
                        receivedView(metrics)
                    }
                }
            }
            .frame(height: rowHeight)

            if style == .regular {
                GeometryReader { metrics in
                    receivedView(metrics)
                }
                .frame(height: rowHeight)

                Spacer(minLength: 0)
                    .frame(height: 0)
            }

            GeometryReader { metrics in
                HStack(alignment: .bottom) {
                    HStack {
                        Image(systemName: "arrow.up.forward")
                            .font(Font.system(.body).weight(.regular))
                            .foregroundColor(Color(PlatformColor.secondaryLabelAlias))

                        AnimatedText(sentDescription)
                            .font(Font.system(.body).weight(.regular))
                            .foregroundColor(Color(PlatformColor.secondaryLabelAlias))
                            .lineLimit(1)
                    }

                    Spacer()

                    if style == .compat {
                        sentView(metrics)
                    }
                }
            }
            .frame(height: rowHeight)

            if style == .regular {
                GeometryReader { metrics in
                    sentView(metrics)
                }
                .frame(height: rowHeight)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Previews

struct TrafficWidget_Previews: PreviewProvider {
    static let inValues: [Int64] = [
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0,
        0, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0,
        0, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0,
        0, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,
    ]
    static let outValues: [Int64] = [
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0,
        0, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0,
        0, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0,
        0, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0,
    ]
    static var previews: some View {
        TrafficWidget(
            label: "Usage",
            style: .compat,
            receivedEntry: TrafficEntry(
                child: BasicEntry(
                    key: .InterfaceBytesReceived(name: "en0"),
                    name: "Received"
                ), values: inValues
            ),
            sentEntry: TrafficEntry(
                child: BasicEntry(
                    key: .InterfaceBytesSent(name: "en0"),
                    name: "Sent"
                ), values: outValues
            )
        )
        .padding(.all)
    }
}
