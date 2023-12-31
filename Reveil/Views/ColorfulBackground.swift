//
//  ColorfulBackground.swift
//  Reveil
//
//  Created by 秋星桥 on 2023/12/30.
//

import ColorfulX
import SwiftUI

struct ColorfulBackground: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Group {
            if colorScheme == .light { // recreate pls
                ColorfulView(
                    color: .constant(ColorfulPreset.winter.colors),
                    speed: .constant(0.5),
                    frameLimit: 60
                )
                .opacity(0.5)
            } else {
                ColorfulView(
                    color: .constant(ColorfulPreset.aurora.colors),
                    speed: .constant(0.5),
                    frameLimit: 60
                )
                .opacity(0.25)
            }
        }
        .background(Color(PlatformColor.systemBackground))
        .ignoresSafeArea()
    }
}
