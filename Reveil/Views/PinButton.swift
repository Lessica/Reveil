//
//  PinButton.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import SwiftUI

struct PinButton: View {
    @AppCodableStorage<Pin> var pin: Pin

    var body: some View {
        Button {
            pin = Pin(negate: pin)
        } label: {
            Image(systemName: pin.isPinned ? "pin.fill" : "pin")
                .font(Font.system(.body))
                .foregroundColor(Color(PlatformColor.labelAlias))
                .rotationEffect(.degrees(45))
        }
    }
}

// MARK: - Previews

struct PinButton_Previews: PreviewProvider {
    static var previews: some View {
        PinButton(pin: AppCodableStorage(wrappedValue: Pin(false), .Security))
    }
}
