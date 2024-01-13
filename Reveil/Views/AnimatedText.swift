//
//  AnimatedText.swift
//  Reveil
//
//  Created by 秋星桥 on 2023/12/30.
//

import SwiftUI

struct AnimatedText: View {
    let text: String
    init(_ text: String) {
        self.text = text
    }

    var isAnimatedTextEnabled: Bool {
        StandardUserDefaults.shared.isAnimatedTextEnabled && !ProcessInfo.processInfo.isLowPowerModeEnabled
    }

    var isLegacyUIEnabled: Bool = StandardUserDefaults.shared.isLegacyUIEnabled

    var body: some View {
        if !isLegacyUIEnabled && isAnimatedTextEnabled {
            if #available(iOS 17.0, *) {
                #if swift(>=5.9)
                Text(text)
                    .contentTransition(.numericText())
                    .animation(.spring(duration: 0.2), value: text)
                #else
                Text(text)
                    .contentTransition(.numericText())
                    .animation(.linear(duration: 0.2), value: text)
                #endif
            } else {
                Text(text)
            }
        } else {
            Text(text)
        }
    }
}
