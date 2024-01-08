//
//  View+ForegroundStyle.swift
//  Reveil
//
//  Created by Lessica on 2024/1/8.
//

import SwiftUI

extension View {
    @ViewBuilder
    func foregroundStyle(accent: Bool) -> some View {
        if #available(iOS 15.0, *), accent {
            self.foregroundStyle(.accent)
        } else {
            self
        }
    }
}
