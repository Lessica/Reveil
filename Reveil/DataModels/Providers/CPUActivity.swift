//
//  CPUActivity.swift
//  Reveil
//
//  Created by Lessica on 2023/10/2.
//

import Foundation

final class CPUActivity {
    static let shared = CPUActivity()
    private init() {}

    private var system = System()

    func getSummary() -> System.CPUUsage {
        system.cpuUsage()
    }
}
