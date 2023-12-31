//
//  FileIntegrityCheckResult.swift
//  Reveil
//
//  Created by Lessica on 2023/10/29.
//

import Foundation

struct FileIntegrityCheckResult: Codable {
    let result: Bool
    let hitChecks: [FileIntegrityCheck]
}
