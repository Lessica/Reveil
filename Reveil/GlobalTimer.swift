//
//  GlobalTimer.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import Combine
import Foundation

final class GlobalTimer: ObservableObject {
    static let shared = GlobalTimer()

    @Published var tick: UInt64 = 0

    lazy var timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in self.tick += 1 }

    private init() { timer.fire() }
}
