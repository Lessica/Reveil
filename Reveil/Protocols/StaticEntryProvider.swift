//
//  StaticEntryProvider.swift
//  Reveil
//
//  Created by Lessica on 2023/11/8.
//

import Foundation

protocol StaticEntryProvider {
    var basicEntries: [BasicEntry] { get }
    var usageEntry: UsageEntry<Double>? { get }
}
