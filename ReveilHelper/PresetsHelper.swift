//
//  PresetsHelper.swift
//  ReveilHelper
//
//  Created by Lessica on 2023/12/28.
//

import ArgumentParser
import Foundation

@main
struct PresetsHelper: ParsableCommand {
    @Argument(help: "The path to protect with security presets.")
    var bundlePath: String? = nil

    @Option(name: [.customShort("e"), .customLong("example")], help: "A path where example presets profile written to.")
    var examplePath: String? = nil

    func validate() throws {
        if bundlePath == nil, examplePath == nil {
            throw ValidationError("")
        }
    }

    mutating func run() throws {
        if let examplePath {
            let exampleURL = URL(fileURLWithPath: examplePath)
            try SecurityPresets.default.writeAhead(to: exampleURL)
            throw ExitCode.success
        }

        if let bundlePath {
            let bundleURL = URL(fileURLWithPath: bundlePath)
            let updatedPresets = try SecurityPresets(bundleURL: bundleURL)
            var targetURL: URL
            let contentsURL = bundleURL.appendingPathComponent("Contents/Resources")
            if contentsURL.directoryExists {
                targetURL = contentsURL
            } else {
                targetURL = bundleURL
            }
            targetURL = targetURL.appendingPathComponent(
                String(describing: SecurityPresets.self).components(separatedBy: ".").last!)
                .appendingPathExtension("plist")
            try updatedPresets.writeAhead(to: targetURL)
        }

        throw ExitCode.success
    }
}
