//
//  NetworkInterface.swift
//  Reveil
//
//  Created by Lessica on 2023/10/6.
//

import Foundation

struct NetworkInterface: Identifiable, Codable {
    private static func aliasByPrefix(_ name: String) -> String {
        var prefix = NetworkPrefix(rawValue: name)
        if prefix == nil {
            prefix = NetworkPrefix.others
        }
        guard let prefix else {
            return BasicEntry.unknownValue
        }
        return prefix.description
    }

    let id: UUID
    let name: String
    let alias: String
    let rawValue: ifaddrs_safe

    init(name: String, alias: String, rawValue: ifaddrs_safe) {
        id = UUID()
        self.name = name
        self.alias = alias
        self.rawValue = rawValue
    }

    init(rawValue: ifaddrs_safe) {
        id = UUID()
        name = rawValue.ifa_name
        alias = Self.aliasByPrefix(rawValue.ifa_name)
        self.rawValue = rawValue
    }

    enum CodingKeys: CodingKey {
        case name
        case alias
        case rawValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            name: container.decode(String.self, forKey: .name),
            alias: container.decode(String.self, forKey: .alias),
            rawValue: container.decode(ifaddrs_safe.self, forKey: .rawValue)
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(alias, forKey: .alias)
        try container.encode(rawValue, forKey: .rawValue)
    }

    struct Attribute: Codable {
        let name: String
        let description: String
    }
}
