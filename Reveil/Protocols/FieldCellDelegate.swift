//
//  FieldCellDelegate.swift
//  Reveil
//
//  Created by Lessica on 2023/10/14.
//

import Foundation

protocol FieldCellDelegate {
    func showToast(message: String, icon: String, dismissInterval: TimeInterval)
}
