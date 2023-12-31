//
//  NetworkTraffic.swift
//  Reveil
//
//  Created by Lessica on 2023/10/2.
//

import QuartzCore

final class NetworkTraffic {
    static let shared = NetworkTraffic()
    private init() {}

    private var lastStatistics: NetworkStatistics?

    func getStatistics() -> NetworkStatistics {
        let isOverDue = lastStatistics?.isOverDue ?? true
        var result = [NetworkPrefix: NetworkIO]()
        let ifaddrs = System.interfaceAddresses()
        var allReceived: Int64 = 0
        var allSent: Int64 = 0
        ifaddrs.forEach { addrs in
            guard addrs.ifa_addr?.family == AF_LINK else {
                return
            }
            let name = addrs.ifa_name
            var prefix = NetworkPrefix(rawValue: name)
            if prefix == nil {
                prefix = NetworkPrefix.others
            }
            guard let prefix else {
                return
            }
            guard let networkData = addrs.ifa_data else {
                return
            }
            var received = Int64(networkData.ifi_ibytes)
            var sent = Int64(networkData.ifi_obytes)
            allReceived &+= received
            allSent &+= sent
            if let prevIO = result[prefix] {
                received &+= prevIO.received
                sent &+= prevIO.sent
            }

            let lastReceived = (lastStatistics?.io(prefix: prefix)?.received ?? 0)
            let lastSent = (lastStatistics?.io(prefix: prefix)?.sent ?? 0)
            result[prefix] = NetworkIO(
                received: received, sent: sent,
                receivedDelta: isOverDue ? Int64.max : received - lastReceived,
                sentDelta: isOverDue ? Int64.max : sent - lastSent
            )
        }
        let lastAllReceived = (lastStatistics?.io(prefix: .all)?.received ?? 0)
        let lastAllSent = (lastStatistics?.io(prefix: .all)?.sent ?? 0)
        result[.all] = NetworkIO(
            received: allReceived, sent: allSent,
            receivedDelta: isOverDue ? Int64.max : allReceived - lastAllReceived,
            sentDelta: isOverDue ? Int64.max : allSent - lastAllSent
        )
        let netStats = NetworkStatistics(dictionary: result, stamp: CACurrentMediaTime())
        lastStatistics = netStats
        return netStats
    }
}
