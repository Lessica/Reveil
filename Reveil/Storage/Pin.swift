//
//  Pin.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import Foundation

struct Pin: PropertyListRepresentable {
    let isPinned: Bool
    let lastChange: TimeInterval

    init(_ isPinned: Bool) {
        self.isPinned = isPinned
        lastChange = Date.now.timeIntervalSinceReferenceDate
    }

    init(negate pin: Self) {
        self.init(!pin.isPinned)
    }

    enum CodingKeys: CodingKey {
        case isPinned
        case lastChange
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isPinned = try container.decode(Bool.self, forKey: .isPinned)
        lastChange = try container.decode(TimeInterval.self, forKey: .lastChange)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isPinned, forKey: .isPinned)
        try container.encode(lastChange, forKey: .lastChange)
    }
}
