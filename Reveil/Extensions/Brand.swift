//
//  Brand.swift
//  Reveil
//
//  Created by 秋星桥 on 2023/12/30.
//

import Foundation
import SwiftUI

extension View {
    func navigationBarAttachBrand() -> some View {
        navigationTitle(NSLocalizedString("Reveil", comment: "Reveil"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("IconShape")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.accentColor)
                }
            }
    }
}
