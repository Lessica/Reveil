//
//  Color.swift
//  Reveil
//
//  Created by Lessica on 2023/10/25.
//

import SwiftUI

extension Color {
    #if os(iOS)
    static let labelAlias = Color(UIColor.label)
    static let secondaryLabelAlias = Color(UIColor.secondaryLabel)
    static let tertiaryLabelAlias = Color(UIColor.tertiaryLabel)
    static let secondarySystemBackgroundAlias = Color(UIColor.secondarySystemBackground)
    static let secondarySystemFillAlias = Color(UIColor.secondarySystemFill)
    static let separatorAlias = Color(UIColor.separator)
    static let systemGray4Alias = Color(UIColor.systemGray4)
    static let systemBackground = Color(UIColor.systemBackground)
    #endif

    #if os(macOS)
    static let labelAlias = Color("COLOR_LABEL")
    static let secondaryLabelAlias = Color("COLOR_SECONDARYLABEL")
    static let tertiaryLabelAlias = Color("COLOR_TERTIARYLABEL")
    static let secondarySystemBackgroundAlias = Color("COLOR_SECONDARYSYSTEMBACKGROUND")
    static let secondarySystemFillAlias = Color("COLOR_SECONDARYSYSTEMFILL")
    static let separatorAlias = Color("COLOR_SEPARATOR")
    static let systemGray4Alias = Color("COLOR_SYSTEMGRAY4")
    static let systemBackground = Color("COLOR_SYSTEMBACKGROUND")
    #endif
}
