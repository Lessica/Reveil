//
//  ObjCClassItem.swift
//  Reveil
//
//  Created by Lessica on 2023/11/7.
//

import Foundation

struct ObjCClassItem: Codable {
    let className: String
    let selectorName: String

    enum MethodType: Codable {
        case clazz
        case instance
    }

    let methodType: MethodType

    var description: String { (methodType == .clazz ? "+ [" : "- [") + className + " " + selectorName + "]" }
}
