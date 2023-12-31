//
//  DynamicEntryProvider.swift
//  Reveil
//
//  Created by Lessica on 2023/11/8.
//

import Foundation

protocol DynamicEntryProvider {
    var updatableEntryKeys: [EntryKey] { get }
    func basicEntry(key: EntryKey, style: ValueStyle) -> BasicEntry?
    func usageEntry(key: EntryKey, style: ValueStyle) -> UsageEntry<Double>?
    func trafficEntryIO(key: EntryKey, style: ValueStyle) -> TrafficEntryIO?
}
