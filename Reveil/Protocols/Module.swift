//
//  Module.swift
//  Reveil
//
//  Created by Lessica on 2023/10/14.
//

import Foundation

typealias ModuleName = String

protocol Module: StaticEntryProvider, DynamicEntryProvider, EntryUpdater {
    static var shared: Self { get }
    var moduleName: ModuleName { get }

    func reloadData()
}
