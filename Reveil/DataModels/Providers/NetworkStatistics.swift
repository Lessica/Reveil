//
//  NetworkStatistics.swift
//  Reveil
//
//  Created by Lessica on 2023/10/13.
//

import QuartzCore

private let gBufferFormatter: ByteCountFormatter = {
    let formatter = ByteCountFormatter()
    formatter.countStyle = .memory
    formatter.allowedUnits = [.useAll]
    return formatter
}()

struct NetworkStatistics: Codable {
    let dictionary: [NetworkPrefix: NetworkIO]
    let stamp: TimeInterval
}

extension NetworkStatistics {
    func io(prefix: NetworkPrefix) -> NetworkIO? {
        dictionary[prefix]
    }

    func ratio(prefix: NetworkPrefix) -> Double? {
        guard let io = dictionary[prefix], let allIO = dictionary[.all] else {
            return nil
        }
        return Double(io.received &+ io.sent) / Double(allIO.received &+ allIO.sent)
    }

    func receivedBytes(prefix: NetworkPrefix) -> Int64? {
        guard let io = dictionary[prefix] else {
            return nil
        }
        return io.received
    }

    func sentBytes(prefix: NetworkPrefix) -> Int64? {
        guard let io = dictionary[prefix] else {
            return nil
        }
        return io.sent
    }

    func allBytes(prefix: NetworkPrefix) -> Int64? {
        guard let io = dictionary[prefix] else {
            return nil
        }
        return io.received &+ io.sent
    }

    func entryValue(prefix: NetworkPrefix, style: ValueStyle = .detailed) -> String {
        var pfxValue: String
        if let categoryBytes = allBytes(prefix: prefix), let totalBytes = allBytes(prefix: .all) {
            if style == .dashboard {
                pfxValue = gBufferFormatter.string(fromByteCount: categoryBytes)
            } else {
                let ratio = Swift.min(1.0, Double(categoryBytes) / Double(totalBytes)) * 100.0
                pfxValue = String(format: "%@\n%.2f%%", gBufferFormatter.string(fromByteCount: categoryBytes), ratio)
            }
        } else {
            if style == .dashboard {
                pfxValue = gBufferFormatter.string(fromByteCount: 0)
            } else {
                pfxValue = String(format: "%@\n%.2f%%", gBufferFormatter.string(fromByteCount: 0), 0.0)
            }
        }
        return pfxValue
    }

    var isOverDue: Bool { CACurrentMediaTime() - stamp > 1.5 }
}
