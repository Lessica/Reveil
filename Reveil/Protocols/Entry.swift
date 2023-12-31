//
//  Entry.swift
//  Reveil
//
//  Created by Lessica on 2023/10/19.
//

import Foundation

protocol Entry: Identifiable, ObservableObject, Codable, Hashable {
    var key: EntryKey { get }
    var name: String { get }
}
