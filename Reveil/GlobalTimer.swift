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

    lazy var timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
        guard !self.sessions.isEmpty else { return }
        Dashboard.shared.updateEntries()
    }

    private init() { timer.fire() }

    var sessions: Set<UUID> = []

    func use(session: UUID) {
        assert(Thread.isMainThread)
        sessions.insert(session)
    }

    func remove(session: UUID) {
        assert(Thread.isMainThread)
        sessions.remove(session)
    }
}
