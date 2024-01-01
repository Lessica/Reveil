//
//  StandardUserDefaults.swift
//  Reveil
//
//  Created by Lessica on 2024/1/1.
//

import Foundation

private let gDefaultsKeyAnimatedText = "AnimatedText"
private let gDefaultsKeyAnimatedBackground = "AnimatedBackground"
private let gDefaultsKeyLowFrameRate = "LowFrameRate"

class StandardUserDefaults {
    static let shared = StandardUserDefaults()

    private init() {
        UserDefaults.standard.register(defaults: [
            gDefaultsKeyAnimatedText: true,
            gDefaultsKeyAnimatedBackground: true,
            gDefaultsKeyLowFrameRate: false,
        ])
    }

    lazy var isAnimatedTextEnabled: Bool = {
        UserDefaults.standard.bool(forKey: gDefaultsKeyAnimatedText)
    }()

    lazy var isAnimatedBackgroundEnabled: Bool = {
        UserDefaults.standard.bool(forKey: gDefaultsKeyAnimatedBackground)
    }()

    lazy var isLowFrameRateEnabled: Bool = {
        UserDefaults.standard.bool(forKey: gDefaultsKeyLowFrameRate)
    }()
}
