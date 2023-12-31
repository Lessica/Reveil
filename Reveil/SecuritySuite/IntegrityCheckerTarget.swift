//
//  IntegrityCheckerTarget.swift
//  Reveil
//
//  Created by Lessica on 2023/10/29.
//

import Foundation

enum IntegrityCheckerTarget {
    // Default image
    case `default`

    // Main executable
    case main

    // Custom image with a specified name
    case customImage(String)

    // Custom executable with a specified path
    case customExecutable(URL)
}
