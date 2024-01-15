//
//  StandardUserDefaults.swift
//  Reveil
//
//  Created by Lessica on 2024/1/1.
//

import Foundation

private let gDefaultsKeyLegacyUI = "LegacyUI"
private let gDefaultsKeyAnimatedText = "AnimatedText"
private let gDefaultsKeyAnimatedBackground = "AnimatedBackground"
private let gDefaultsKeyLowFrameRate = "LowFrameRate"
private let gDefaultsKeyResetLayouts = "ResetLayouts"

class StandardUserDefaults {
    static let shared = StandardUserDefaults()

    private init() {
        UserDefaults.standard.register(defaults: [
            gDefaultsKeyLegacyUI: false,
            gDefaultsKeyAnimatedText: true,
            gDefaultsKeyAnimatedBackground: true,
            gDefaultsKeyLowFrameRate: false,
            gDefaultsKeyResetLayouts: false,
        ])
    }

    lazy var isLegacyUIEnabled: Bool = {
        UserDefaults.standard.bool(forKey: gDefaultsKeyLegacyUI)
    }()

    lazy var isAnimatedTextEnabled: Bool = {
        UserDefaults.standard.bool(forKey: gDefaultsKeyAnimatedText)
    }()

    lazy var isAnimatedBackgroundEnabled: Bool = {
        UserDefaults.standard.bool(forKey: gDefaultsKeyAnimatedBackground)
    }()

    lazy var isLowFrameRateEnabled: Bool = {
        UserDefaults.standard.bool(forKey: gDefaultsKeyLowFrameRate)
    }()

    lazy var shouldResetLayouts: Bool = {
        UserDefaults.standard.bool(forKey: gDefaultsKeyResetLayouts)
    }()

    func didResetLayouts() {
        UserDefaults.standard.removeObject(forKey: gDefaultsKeyResetLayouts)
    }
}
