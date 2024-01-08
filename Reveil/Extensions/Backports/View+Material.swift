//
//  View+Material.swift
//  Reveil
//
//  Created by Lessica on 2024/1/8.
//

import SwiftUI

extension View {
    @ViewBuilder
    func background(thinMaterial: Bool) -> some View {
        if #available(iOS 15.0, *), thinMaterial {
            self.background(.thinMaterial)
        } else {
            self
        }
    }
}
