//
//  SecurityView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/25.
//

import SwiftUI

struct SecurityView: View {
    @ObservedObject private var securityModel = Security.shared

    @Environment(\.dismiss) private var dismissAction

    var body: some View {
        DetailsListView(basicEntries: securityModel.basicEntries)
            .navigationTitle(NSLocalizedString("SECURITY", comment: "Security"))
        #if os(macOS)

        #else
                .toolbar {
                    ToolbarItem {
                        PinButton(pin: AppCodableStorage(
                            wrappedValue: Pin(true), .Security,
                            store: PinStorage.shared.userDefaults
                        ))
                    }
                }
        #endif
    }
}
