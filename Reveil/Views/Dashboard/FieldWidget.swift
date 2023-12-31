//
//  FieldWidget.swift
//  Reveil
//
//  Created by Lessica on 2023/10/3.
//

import SwiftUI

struct FieldWidget: View {
    @StateObject var entry: BasicEntry

    var body: some View {
        VStack(spacing: 8) {
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

            HStack {
                Text(entry.value)
                    .font(Font.system(.body).weight(.regular).monospacedDigit())
                    .foregroundColor(Color(PlatformColor.secondaryLabelAlias))
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Previews

struct FieldWidget_Previews: PreviewProvider {
    static var previews: some View {
        FieldWidget(entry: BasicEntry(
            key: .KernelVersion,
            name: "Kernel version",
            value: "Darwin Kernel Version 21.4.0: Mon Feb 21 21:27:55 PST 2022; root:xnu-8020.102.3~1/RELEASE_ARM64_T8101"
        ))
        .padding(.all)
    }
}
