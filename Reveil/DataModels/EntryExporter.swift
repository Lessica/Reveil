//
//  EntryExporter.swift
//  Reveil
//
//  Created by Lessica on 2023/10/18.
//

import Foundation

struct EntryExporter: Encodable {
    let moduleClass: String
    let moduleName: String
    let basicEntries: [BasicEntry]
    let usageEntry: UsageEntry<Double>?

    init(module: Module) {
        module.updateEntries()
        moduleClass = String(describing: module)
        moduleName = module.moduleName
        basicEntries = module.basicEntries
        usageEntry = module.usageEntry
    }

    init(provider: StaticEntryProvider & Explainable) {
        moduleClass = String(describing: provider)
        moduleName = provider.description
        basicEntries = provider.basicEntries
        usageEntry = provider.usageEntry
    }
}
