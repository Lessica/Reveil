//
//  UsageWidget.swift
//  Reveil
//
//  Created by Lessica on 2023/10/2.
//

import SwiftUI

struct UsageWidget: View {
    @StateObject var entry: UsageEntry<Double>

    private let rowHeight: CGFloat = 18

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

            HStack(alignment: .lastTextBaseline) {
                AnimatedText(String(format: "%.2f%%", (entry.firstRatio ?? 0.0) * 100.0))
                    .font(Font.system(.title).weight(.medium))
                    .foregroundColor(.accentColor)
                    .lineLimit(1)
                Spacer()

                if let lastDescription = entry.lastDescription {
                    Text(lastDescription)
                        .font(Font.system(.body).weight(.regular))
                        .foregroundColor(Color(PlatformColor.secondaryLabelAlias))
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)
                .frame(height: 8)

            GeometryReader { metrics in
                ZStack(alignment: .leading) {
                    Color(PlatformColor.secondarySystemFillAlias)

                    Color.accentColor
                        .frame(width: metrics.size.width * (entry.firstRatio ?? 0.0))
                }
                .frame(maxWidth: metrics.size.width)
                .cornerRadius(4)
            }
            .frame(height: rowHeight)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Previews

struct UsageWidget_Previews: PreviewProvider {
    static var previews: some View {
        UsageWidget(entry: UsageEntry(key: .DiskSpace, name: "Usage", items: [
            UsageEntry.Item(
                label: "Used",
                value: 124.37,
                color: Color.accentColor
            ),
            UsageEntry.Item(
                label: "Free",
                value: 78.42,
                color: Color.clear,
                description: "THIS IS A LONG DESCRIPTION."
            ),
        ]))
        .padding(.all)
    }
}
