//
//  MemoryActivity.swift
//  Reveil
//
//  Created by Lessica on 2023/10/2.
//

import Foundation

final class MemoryActivity {
    static let shared = MemoryActivity()
    private init() {}

    var usage: Double { min(1.0, 1.0 - System.memoryUsage().free / System.physicalMemory(.gigabyte)) }
}
