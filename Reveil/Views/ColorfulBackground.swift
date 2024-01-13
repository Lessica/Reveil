//
//  ColorfulBackground.swift
//  Reveil
//
//  Created by 秋星桥 on 2023/12/30.
//

import ColorfulX
import SwiftUI


struct ColorfulBackground: View {
    @State var isPaused: Bool = false
    @Environment(\.colorScheme) var colorScheme

    var isAnimatedBackgroundEnabled: Bool {
        StandardUserDefaults.shared.isAnimatedBackgroundEnabled && !ProcessInfo.processInfo.isLowPowerModeEnabled
    }

    var isLowFrameRateEnabled: Bool = StandardUserDefaults.shared.isLowFrameRateEnabled
    var isLegacyUIEnabled: Bool = StandardUserDefaults.shared.isLegacyUIEnabled

    var colorfulView: some View {
        if colorScheme == .light {
            return ColorfulView(
                color: .constant(ColorfulPreset.winter.colors),
                speed: isAnimatedBackgroundEnabled && !isPaused ? .constant(0.5) : .constant(0),
                frameLimit: isLowFrameRateEnabled ? 30 : 60
            )
            .opacity(0.5)
        } else {
            return ColorfulView(
                color: .constant(ColorfulPreset.aurora.colors),
                speed: isAnimatedBackgroundEnabled && !isPaused ? .constant(0.5) : .constant(0),
                frameLimit: isLowFrameRateEnabled ? 30 : 60
            )
            .opacity(0.25)
        }
    }

    var body: some View {
        Group {
            if !isLegacyUIEnabled {
                self.colorfulView
            }
        }
        .background(Color(PlatformColor.systemBackground))
        .ignoresSafeArea()
        .onAppear {
            isPaused = false
        }
        .onDisappear {
            isPaused = true
        }
    }
}
