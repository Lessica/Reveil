//
//  ModuleListView.swift
//  Reveil
//
//  Created by Lessica on 2023/10/14.
//

import SwiftUI

protocol ModuleListView: View {
    var module: Module { get }
    init?(entryKey: EntryKey)
}
