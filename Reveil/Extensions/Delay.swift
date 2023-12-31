//
//  Delay.swift
//  Reveil
//
//  Created by Lessica on 2023/10/4.
//

import SwiftUI

extension TimeInterval {
    var nanoseconds: UInt64 {
        UInt64((self * 1_000_000_000).rounded())
    }
}

extension Task where Success == Never, Failure == Never {
    static func sleep(_ duration: TimeInterval) async throws {
        try await Task.sleep(nanoseconds: duration.nanoseconds)
    }
}

extension View {
    func onAppear(delay: TimeInterval, action: @escaping () -> Void) -> some View {
        task {
            do {
                try await Task.sleep(delay)
            } catch { // Task canceled
                return
            }

            await MainActor.run {
                action()
            }
        }
    }
}
