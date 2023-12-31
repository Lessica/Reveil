//
//  HighlightedEntryKey.swift
//  Reveil
//
//  Created by Lessica on 2023/10/23.
//

import Foundation

final class HighlightedEntryKey: ObservableObject {
    @Published var object: EntryKey?

    init() {
        object = nil
    }

    init(object: EntryKey) {
        self.object = object
    }
}
