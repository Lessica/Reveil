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

    var body: some View {
        if #available(iOS 16.0, *) {
            Text(text)
                .contentTransition(.numericText())
                .animation(.spring(duration: 0.2), value: text)
        } else {
            Text(text)
        }
    }
}
