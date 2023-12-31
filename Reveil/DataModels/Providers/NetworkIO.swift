//
//  NetworkIO.swift
//  Reveil
//
//  Created by Lessica on 2023/10/13.
//

import Foundation

struct NetworkIO: Codable {
    init(received: Int64, sent: Int64, receivedDelta: Int64 = 0, sentDelta: Int64 = 0) {
        self.received = received
        self.sent = sent
        self.receivedDelta = receivedDelta
        self.sentDelta = sentDelta
    }

    let received: Int64
    let sent: Int64
    let receivedDelta: Int64
    let sentDelta: Int64
}
