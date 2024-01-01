//
//  PropertyListRepresentable.swift
//  Reveil
//
//  Created by Lessica on 2023/10/14.
//

import DictionaryCoder
import Foundation

protocol PropertyListRepresentable: Codable {
    init(propertyList: Any) throws
    var propertyListValue: Any { get throws }
}

private let plistDecoder = DictionaryDecoder()
private let plistEncoder = DictionaryEncoder()

/// Default implementation of PropertyListRepresentable for objects that are Decobable.
extension PropertyListRepresentable where Self: Decodable {
    init(propertyList: Any) throws {
        self = try plistDecoder.decode(Self.self, from: propertyList as! [String: Any])
    }
}

/// Default implementation of PropertyListRepresentable for objects that are Encodable.
extension PropertyListRepresentable where Self: Encodable {
    var propertyListValue: Any {
        get throws {
            /// Encode to plist, decode :(
            /// We can copy https://github.com/apple/swift-corelibs-foundation/blob/main/Darwin/Foundation-swiftoverlay/PlistEncoder.swift
            /// to fix this, just not slow enough afaik.
            try plistEncoder.encode(self)
        }
    }
}
