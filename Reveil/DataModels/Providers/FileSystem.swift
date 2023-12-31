//
//  FileSystem.swift
//  Reveil
//
//  Created by Lessica on 2023/10/6.
//

import Foundation

struct FileSystem: Identifiable, Codable {
    let id: UUID
    let path: String

    init(path: String) {
        id = UUID()
        self.path = path
    }

    struct Attribute: Codable {
        let name: String
        let description: String
    }

    enum CodingKeys: CodingKey {
        case path
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(path: container.decode(String.self, forKey: .path))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(path, forKey: .path)
    }
}
