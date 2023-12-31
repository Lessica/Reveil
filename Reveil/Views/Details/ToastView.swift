//
//  ToastView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import SwiftUI

struct ToastView: View {
    let label: String
    let iconName: String

    var body: some View {
        VStack {
            HStack {
                Image(systemName: iconName)
                Text(label)
                    .font(Font.system(.footnote).bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.thinMaterial)
            .cornerRadius(8)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Previews

struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        ToastView(
            label: "Copied to clipboard",
            iconName: "info.circle.fill"
        )

        ToastView(
            label: "Unpinned Radio Tech",
            iconName: "pin"
        )

        ToastView(
            label: "Pinned Radio Tech",
            iconName: "pin.fill"
        )
    }
}
