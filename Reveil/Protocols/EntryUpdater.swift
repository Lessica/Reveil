//
//  EntryUpdater.swift
//  Reveil
//
//  Created by Lessica on 2023/11/8.
//

import Foundation

protocol EntryUpdater {
    func updateEntries()
    func updateBasicEntry(_ entry: BasicEntry, style: ValueStyle)
    func updateUsageEntry(_ entry: UsageEntry<Double>, style: ValueStyle)
    func updateTrafficEntryIO(_ entry: TrafficEntryIO, style: ValueStyle)
}
