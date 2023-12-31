//
//  FailedChecks.swift
//  IOSSecuritySuite
//
//  Created by im on 06/02/23.
//  Copyright © 2023 wregula. All rights reserved.
//

import Foundation

struct FailedCheckType: Codable {
    let check: FailedCheck
    let failMessage: String
}

enum FailedCheck: CaseIterable, Codable {
    case urlSchemes
    case existenceOfSuspiciousFiles
    case suspiciousFilesCanBeOpened
    case restrictedDirectoriesWriteable
    case fork
    case symbolicLinks
    case dyld
    case openedPorts
    case pSelectFlag
    case suspiciousObjCClasses
}
