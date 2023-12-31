//
//  SecurityCheckType.swift
//  Reveil
//
//  Created by Lessica on 2023/11/6.
//

import Foundation

enum SecurityCheckType: String, CaseIterable, Codable, Equatable, Hashable {
    case debuggerEmulator
    case staticIntegrity
    case dynamicIntegrity
    case jailbreakEnvironment
    case sandboxViolation
    case networkProxy
}
