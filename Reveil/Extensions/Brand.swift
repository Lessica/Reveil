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
                    if #available(iOS 15.0, *) {
                        Image("IconShape")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.accentColor)
                    } else {
                        Image("IconShape")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.accentColor)
                            .frame(width: 44, height: 44)
                    }
                }
            }
    }
}
