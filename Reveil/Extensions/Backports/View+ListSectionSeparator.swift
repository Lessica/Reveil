//
//  View+ListSectionSeparator.swift
//  Reveil
//
//  Created by Lessica on 2024/1/8.
//

import SwiftUI

extension View {
    @ViewBuilder
    func listSectionSeparator(hidden: Bool = true) -> some View {
        if #available(iOS 15.0, *) {
            self.listSectionSeparator(hidden ? .hidden : .visible, edges: .all)
        } else {
            self
        }
    }

    @ViewBuilder
    func listSectionSeparator(topHidden: Bool = true) -> some View {
        if #available(iOS 15.0, *) {
            self.listSectionSeparator(topHidden ? .hidden : .visible, edges: .top)
        } else {
            self
        }
    }

    @ViewBuilder
    func listSectionSeparator(bottomHidden: Bool = true) -> some View {
        if #available(iOS 15.0, *) {
            self.listSectionSeparator(bottomHidden ? .hidden : .visible, edges: .bottom)
        } else {
            self
        }
    }
}
