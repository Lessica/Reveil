//
//  BasicNumeric.swift
//  Reveil
//
//  Created by Lessica on 2023/10/14.
//

import Foundation

protocol BasicNumeric: ExpressibleByIntegerLiteral, Comparable, SignedNumeric, Codable {
    static func + (_: Self, _: Self) -> Self
    static func - (_: Self, _: Self) -> Self
    static func * (_: Self, _: Self) -> Self
    static func / (_: Self, _: Self) -> Self
}

extension Double: BasicNumeric {}
extension Int64: BasicNumeric {}
