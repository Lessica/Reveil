//
//  URLSchemeItem.swift
//  Reveil
//
//  Created by Lessica on 2023/11/7.
//

import Foundation

struct URLSchemeItem: Comparable, Codable, Hashable {
    static func < (lhs: URLSchemeItem, rhs: URLSchemeItem) -> Bool {
        lhs.description < rhs.description
    }

    let scheme: String
    let description: String
}
