/*

 Copyright 2015 HiHex Ltd.

 Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in
 compliance with the License. You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under the License is
 distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
 implied. See the License for the specific language governing permissions and limitations under the
 License.

 */

// MARK: IPAddress

import Foundation

extension in_addr: Codable {
    enum CodingKeys: CodingKey {
        case s_addr
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(s_addr: container.decode(in_addr_t.self, forKey: .s_addr))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(s_addr, forKey: .s_addr)
    }
}

extension in6_addr: Codable {
    enum CodingKeys: CodingKey {
        case __u6_addr
    }

    enum u6CodingKeys: CodingKey {
        case __u6_addr32_0
        case __u6_addr32_1
        case __u6_addr32_2
        case __u6_addr32_3
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let u6Container = try container.nestedContainer(keyedBy: u6CodingKeys.self, forKey: .__u6_addr)
        try self.init(__u6_addr: __Unnamed_union___u6_addr(__u6_addr32: (
            u6Container.decode(__uint32_t.self, forKey: .__u6_addr32_0),
            u6Container.decode(__uint32_t.self, forKey: .__u6_addr32_1),
            u6Container.decode(__uint32_t.self, forKey: .__u6_addr32_2),
            u6Container.decode(__uint32_t.self, forKey: .__u6_addr32_3)
        )))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var u6Container = container.nestedContainer(keyedBy: u6CodingKeys.self, forKey: .__u6_addr)
        try u6Container.encode(__u6_addr.__u6_addr32.0, forKey: .__u6_addr32_0)
        try u6Container.encode(__u6_addr.__u6_addr32.1, forKey: .__u6_addr32_1)
        try u6Container.encode(__u6_addr.__u6_addr32.2, forKey: .__u6_addr32_2)
        try u6Container.encode(__u6_addr.__u6_addr32.3, forKey: .__u6_addr32_3)
    }
}

/// Represents an IP address
enum IPAddress: Hashable, Equatable, Strideable, CustomStringConvertible, Codable {
    typealias Stride = Int

    /// An IPv4 address.
    case IPv4(in_addr)

    /// An IPv6 address.
    case IPv6(in6_addr, scopeId: UInt32)

    /// Refers to the localhost (127.0.0.1) in IPv4.
    static let localhost = IPAddress.IPv4(in_addr(s_addr: UInt32(0x7F00_0001).bigEndian))

    /// Refers to the IPv4 address 0.0.0.0.
    static let zero = IPAddress.IPv4(in_addr(s_addr: 0))

    /// Constructs an IPv4 address from the raw C structure.
    init(_ addr: in_addr) {
        self = .IPv4(addr)
    }

    /// Constructs an IPv6 address from the raw C structure.
    init(_ addr: in6_addr, scopeId: UInt32 = 0) {
        self = .IPv6(addr, scopeId: scopeId)
    }

    /// Parse the IP in the canonical string representation using `inet_pton(3)`. The strings should
    /// be in the form `192.168.6.11` for IPv4, or `fe80::1234:5678:9abc:def0%4` for IPv6.
    ///
    /// This method will not consult DNS (so host names like `www.example.com` will return nil here),
    /// nor will it parse the interface name (so you should use `%1` instead of `%lo0`).
    init?(string: String) {
        let conversionResult: Int32
        if string.contains(":") {
            var scopeId: UInt32 = 0
            var addr = in6_addr()
            if let percentRange = string.range(of: "%") {
                scopeId = UInt32(string[percentRange.upperBound...]) ?? 0
            }
            conversionResult = inet_pton(AF_INET6, string, &addr)
            self = .IPv6(addr, scopeId: scopeId)
        } else {
            var addr = in_addr()
            conversionResult = inet_pton(AF_INET, string, &addr)
            self = .IPv4(addr)
        }
        if conversionResult != 1 {
            return nil
        }
    }

    /// Creates an IPv4 address from a 32-bit *network-endian* number.
    init(IPv4Number number: UInt32) {
        let addr = in_addr(s_addr: number)
        self.init(addr)
    }

    /// Gets the string representation of the network address.
    var stringValue: String {
        let callNToP = { (addrPtr: UnsafeRawPointer, family: CInt, len: Int32) -> String in
            var buffer = [CChar](repeating: 0, count: Int(len))
            inet_ntop(family, addrPtr, &buffer, socklen_t(len))
            return String(cString: buffer)
        }

        switch self {
        case var .IPv4(addr):
            return callNToP(&addr, AF_INET, INET_ADDRSTRLEN)
        case .IPv6(var addr, let scopeId):
            let s = callNToP(&addr, AF_INET6, INET6_ADDRSTRLEN)
            if scopeId == 0 {
                return s
            } else {
                return "\(s)%\(scopeId)"
            }
        }
    }

    var description: String {
        stringValue
    }

    func stringValue(withBrackets: Bool) -> String {
        if case .IPv6 = self {
            if withBrackets {
                return "[\(stringValue)]"
            }
        }
        return stringValue
    }

    /// Applies a network mask to this address, e.g. `192.168.6.22 & 255.255.255.0 ⇒ 192.168.6.0`
    func mask(netmask: IPAddress) -> IPAddress? {
        switch (self, netmask) {
        case let (.IPv4(local), .IPv4(mask)):
            return .IPv4(in_addr(s_addr: local.s_addr & mask.s_addr))

        case let (.IPv6(local, scopeId: scopeId), .IPv6(mask, _)):
            let (local1, local2) = unsafeBitCast(local, to: (UInt64, UInt64).self)
            let (mask1, mask2) = unsafeBitCast(mask, to: (UInt64, UInt64).self)
            let result = unsafeBitCast((local1 & mask1, local2 & mask2), to: in6_addr.self)
            return .IPv6(result, scopeId: scopeId)

        default:
            return nil
        }
    }

    func broadcastAddress(netmask: IPAddress) -> IPAddress? {
        switch (self, netmask) {
        case let (.IPv4(local), .IPv4(mask)):
            return .IPv4(in_addr(s_addr: local.s_addr | ~mask.s_addr))
        default:
            return nil
        }
    }

    /// Compute thes size of subnet of this network mask IP. For instance, the subnet size of
    /// `255.255.254.0` is 512.
    ///
    /// The IP must be like `255.255.255.0` or `ffff:ffff:ffff:ffff::`, otherwise the output will be
    /// undefined. If the subnet size is too large to fit in an `Int`, this property will return
    /// `Int.max`.
    var subnetSize: Int {
        switch self {
        case let .IPv4(addr):
            return Int(1 + ~UInt32(bigEndian: addr.s_addr))
        case let .IPv6(addr, _):
            let (loBig, _) = unsafeBitCast(addr, to: (UInt64, UInt64).self)
            let lo = ~UInt64(bigEndian: loBig)
            if lo >= UInt64(Int.max) {
                return Int.max
            } else {
                return Int(lo + 1)
            }
        }
    }

    func successor() -> IPAddress {
        advanced(by: 1)
    }

    func advanced(by n: Int) -> IPAddress {
        switch self {
        case let .IPv4(addr):
            let nextIP: UInt32 = .init(bigEndian: addr.s_addr).advanced(by: n)
            return .IPv4(in_addr(s_addr: nextIP.bigEndian))
        case let .IPv6(addr, scopeId: scopeId):
            let (loBig, hiBig) = unsafeBitCast(addr, to: (UInt64, UInt64).self)
            let (hi, lo) = (UInt64(bigEndian: hiBig), UInt64(bigEndian: loBig))
            let newLo: UInt64, overflow: Bool, overflowValue: UInt64
            if n >= 0 {
                (newLo, overflow: overflow) = lo.addingReportingOverflow(UInt64(n))
                overflowValue = overflow ? 1 : 0
            } else {
                (newLo, overflow: overflow) = lo.subtractingReportingOverflow(UInt64(-n))
                overflowValue = overflow ? ~0 : 0
            }
            let newHi = hi &+ overflowValue
            let newAddr = unsafeBitCast((newLo.bigEndian, newHi.bigEndian), to: in6_addr.self)
            return .IPv6(newAddr, scopeId: scopeId)
        }
    }

    func distance(to other: IPAddress) -> Int {
        switch (self, other) {
        case let (.IPv4(addr1), .IPv4(addr2)):
            let (a1, a2) = (UInt32(bigEndian: addr1.s_addr), UInt32(bigEndian: addr2.s_addr))
            return Int(a2 &- a1)
        case let (.IPv6(addr1, _), .IPv6(addr2, _)):
            let (lo1, hi1) = unsafeBitCast(addr1, to: (UInt64, UInt64).self)
            let (lo2, hi2) = unsafeBitCast(addr2, to: (UInt64, UInt64).self)
            let (lo, overflow1) = lo2.subtractingReportingOverflow(lo1)
            let (hi, overflow2) = hi2.subtractingReportingOverflow(hi1)
            if overflow1 || overflow2 {
                return Int.max
            } else {
                return Int(hi &* UInt64(UInt32.max)) &+ Int(lo)
            }
        default:
            return Int.max
        }
    }

    /// Gets the address family of this instance. Returns either `AF_INET` or `AF_INET6`.
    var family: Int32 {
        switch self {
        case .IPv4: AF_INET
        case .IPv6: AF_INET6
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case let .IPv4(addr):
            hasher.combine(4)
            hasher.combine(addr.s_addr)
        case let .IPv6(addr, scopeId):
            let (lo, hi) = unsafeBitCast(addr, to: (UInt64, UInt64).self)
            hasher.combine(6)
            hasher.combine(lo)
            hasher.combine(hi)
            hasher.combine(scopeId)
        }
    }

    /// Constructs a new socket address at a given port.
    func withPort(port: UInt16) -> SocketAddress {
        .Internet(host: self, port: port)
    }

    static func == (lhs: IPAddress, rhs: IPAddress) -> Bool {
        switch (lhs, rhs) {
        case let (.IPv4(l), .IPv4(r)):
            return l.s_addr == r.s_addr
        case let (.IPv6(la, ls), .IPv6(ra, rs)):
            let (ll, lh) = unsafeBitCast(la, to: (UInt64, UInt64).self)
            let (rl, rh) = unsafeBitCast(ra, to: (UInt64, UInt64).self)
            return ll == rl && lh == rh && ls == rs
        default:
            return false
        }
    }

    enum CodingKeys: CodingKey {
        case IPv4
        case IPv6
    }

    enum IPv4CodingKeys: CodingKey {
        case _0
    }

    enum IPv6CodingKeys: CodingKey {
        case _0
        case scopeId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            let v4container = try container.nestedContainer(keyedBy: IPv4CodingKeys.self, forKey: .IPv4)
            try self.init(v4container.decode(in_addr.self, forKey: ._0))
        } catch {
            let v6container = try container.nestedContainer(keyedBy: IPv6CodingKeys.self, forKey: .IPv6)
            try self.init(
                v6container.decode(in6_addr.self, forKey: ._0),
                scopeId: v6container.decode(UInt32.self, forKey: .scopeId)
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .IPv4(in_addr):
            var v4Container = container.nestedContainer(keyedBy: IPv4CodingKeys.self, forKey: .IPv4)
            try v4Container.encode(in_addr, forKey: ._0)
        case let .IPv6(in6_addr, scopeId):
            var v6Container = container.nestedContainer(keyedBy: IPv6CodingKeys.self, forKey: .IPv6)
            try v6Container.encode(in6_addr, forKey: ._0)
            try v6Container.encode(scopeId, forKey: .scopeId)
        }
    }
}

// MARK: - Socket address

@discardableResult
private func withUnsafeMutablePointers<A, B, Result>(_ a: inout A, _ b: inout B, body: (UnsafeMutablePointer<A>, UnsafeMutablePointer<B>) throws -> Result) rethrows -> Result {
    try withUnsafeMutablePointer(to: &a) { (a: UnsafeMutablePointer<A>) throws -> Result in
        try withUnsafeMutablePointer(to: &b) { (b: UnsafeMutablePointer<B>) throws -> Result in
            try body(a, b)
        }
    }
}

/// A wrapper of the C `sockaddr` structure.
enum SocketAddress: Hashable, Equatable, Codable {
    /// An internet address.
    case Internet(host: IPAddress, port: UInt16)
    case Link(address: String, type: UInt8)

    /// Creates an internet address.
    init(host: IPAddress, port: UInt16) {
        self = .Internet(host: host, port: port)
    }

    /// Converts an IPv4 `sockaddr_in` structure to a SocketAddress.
    init(_ addr: sockaddr_in) {
        let host = IPAddress(addr.sin_addr)
        let port = UInt16(bigEndian: addr.sin_port)
        self = .Internet(host: host, port: port)
    }

    /// Converts an IPv6 `sockaddr_in6` structure to a SocketAddress.
    init(_ addr: sockaddr_in6) {
        let host = IPAddress(addr.sin6_addr, scopeId: addr.sin6_scope_id)
        let port = UInt16(bigEndian: addr.sin6_port)
        self = .Internet(host: host, port: port)
    }

    init(_ addr: sockaddr_dl) {
        let macAddress: String
        if addr.sdl_alen == 0 {
            macAddress = String()
        } else {
            var sdlData = addr.sdl_data
            macAddress = withUnsafePointer(to: &sdlData) { ptr in
                ptr.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: ptr)) { pointer in
                    let buffer = UnsafeBufferPointer(start: pointer.advanced(by: Int(addr.sdl_nlen)), count: Int(addr.sdl_alen))
                    return buffer.map { String(format: "%02x", $0) }.joined(separator: ":")
                }
            }
        }
        self = .Link(address: macAddress, type: addr.sdl_type)
    }

    /// Converts a generic `sockaddr` structure to a SocketAddress.
    init?(_ addr: UnsafePointer<sockaddr>?) {
        guard let addr else { return nil }

        switch Int32(addr.pointee.sa_family) {
        case AF_INET:
            self.init(addr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee })
        case AF_INET6:
            self.init(addr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { $0.pointee })
        case AF_LINK:
            self.init(addr.withMemoryRebound(to: sockaddr_dl.self, capacity: 1) { $0.pointee })
        default:
            return nil
        }
    }

    init?(_ addr: NSData) {
        guard addr.length >= MemoryLayout<sockaddr>.size else { return nil }

        switch Int32(addr.bytes.assumingMemoryBound(to: sockaddr.self).pointee.sa_family) {
        case AF_INET where addr.length >= MemoryLayout<sockaddr_in>.size:
            self.init(addr.bytes.assumingMemoryBound(to: sockaddr_in.self).pointee)
        case AF_INET6 where addr.length >= MemoryLayout<sockaddr_in6>.size:
            self.init(addr.bytes.assumingMemoryBound(to: sockaddr_in6.self).pointee)
        case AF_LINK where addr.length >= MemoryLayout<sockaddr_dl>.size:
            self.init(addr.bytes.assumingMemoryBound(to: sockaddr_dl.self).pointee)
        default:
            return nil
        }
    }

    init?(_ addr: Data) {
        guard addr.count >= MemoryLayout<sockaddr>.size else { return nil }

        guard let saFamily = addr.withUnsafeBytes({ ptr in
            ptr.baseAddress!.withMemoryRebound(to: sockaddr.self, capacity: 1) { pointer in
                pointer.pointee.sa_family
            }
        }) else {
            return nil
        }

        switch Int32(saFamily) {
        case AF_INET where addr.count >= MemoryLayout<sockaddr_in>.size:
            self.init(addr.withUnsafeBytes { $0.baseAddress!.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { pointer in
                pointer.pointee
            } })
        case AF_INET6 where addr.count >= MemoryLayout<sockaddr_in6>.size:
            self.init(addr.withUnsafeBytes { $0.baseAddress!.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { pointer in
                pointer.pointee
            } })
        case AF_LINK where addr.count >= MemoryLayout<sockaddr_dl>.size:
            self.init(addr.withUnsafeBytes { $0.baseAddress!.withMemoryRebound(to: sockaddr_dl.self, capacity: 1) { pointer in
                pointer.pointee
            } })
        default:
            return nil
        }
    }

    /// Converts a generic `sockaddr_storage` structure to a SocketAddress.
    init?(_ addr: sockaddr_storage) {
        var storage = addr
        let ptr = withUnsafePointer(to: &storage) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { pointer in
                pointer
            }
        }
        self.init(ptr)
    }

    /// Extracts the host and port part of the URL.
    init?(url: NSURL) {
        guard let hostString = url.host,
              let host = IPAddress(string: hostString),
              let port = url.port?.uint16Value else { return nil }
        self.init(host: host, port: port)
    }

    init?(url: URL) {
        guard let hostString = url.host,
              let host = IPAddress(string: hostString),
              let port = url.port else { return nil }
        self.init(host: host, port: UInt16(port))
    }

    /// Obtains a SocketAddress instance from a function that outputs `sockaddr` structures. For
    /// example:
    ///
    /// ```swift
    /// let (addr, res) = SocketAddress.receive { accept(sck, $0, $1) }
    /// ```
    static func receive<R>(closure: (UnsafeMutablePointer<sockaddr>, UnsafeMutablePointer<socklen_t>) throws -> R) rethrows -> (SocketAddress?, R) {
        var storage = sockaddr_storage()
        var length = socklen_t(MemoryLayout<sockaddr_storage>.size)
        let result = try withUnsafeMutablePointers(&storage, &length) { storagePtr, lengthPtr in
            try storagePtr.withMemoryRebound(to: sockaddr.self, capacity: 1) { pointer in
                try closure(pointer, lengthPtr)
            }
        }
        let address = SocketAddress(storage)
        return (address, result)
    }

    var stringValue: String {
        switch self {
        case let .Internet(host, port):
            "\(host.stringValue(withBrackets: true)):\(port)"
        case let .Link(address, _):
            "\(address)"
        }
    }

    /// Converts this address into a `sockaddr_in` structure. If the address is not IPv4, it will
    /// return nil.
    func toIPv4() -> sockaddr_in? {
        guard case let .Internet(.IPv4(h), port) = self else { return nil }

        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        addr.sin_addr = h
        addr.sin_port = port.bigEndian
        return addr
    }

    /// Converts this address into a `sockaddr_in` structure. If the address is not IPv6, it will
    /// return nil.
    func toIPv6() -> sockaddr_in6? {
        guard case let .Internet(.IPv6(h, scopeId), port) = self else { return nil }

        var addr = sockaddr_in6()
        addr.sin6_family = sa_family_t(AF_INET6)
        addr.sin6_len = UInt8(MemoryLayout<sockaddr_in6>.size)
        addr.sin6_addr = h
        addr.sin6_port = port.bigEndian
        addr.sin6_scope_id = scopeId
        return addr
    }

    /// Converts this address into a `sockaddr` structure and performs some operation with it. For
    /// example:
    ///
    /// ```swift
    /// let address = IPAddress.localhost.withPort(80)
    /// let result = address.withSockaddr { connect(sck, $0, $1) }
    /// ```
    @discardableResult
    func withSockaddr<R>(closure: (UnsafePointer<sockaddr>, socklen_t) throws -> R) rethrows -> R {
        switch self {
        case .Internet(.IPv4, _):
            var addr = toIPv4()!
            return try withUnsafePointer(to: &addr) {
                try $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { pointer in
                    try closure(pointer, socklen_t(MemoryLayout<sockaddr_in>.size))
                }
            }
        case .Internet(.IPv6, _):
            var addr = toIPv6()!
            return try withUnsafePointer(to: &addr) {
                try $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { pointer in
                    try closure(pointer, socklen_t(MemoryLayout<sockaddr_in6>.size))
                }
            }
        case .Link:
            fatalError("invalid address type")
        }
    }

    /// Converts this address to a `sockaddr_storage` structure.
    func toStorage() -> sockaddr_storage {
        var storage = sockaddr_storage()
        withSockaddr {
            memcpy(&storage, $0, Int($1))
        }
        return storage
    }

    /// Converts this address to a `sockaddr` structure and store into an NSData object.
    func toNSData() -> NSData {
        withSockaddr { NSData(bytes: $0, length: Int($1)) }
    }

    func toData() -> Data {
        withSockaddr { Data(bytes: $0, count: Int($1)) }
    }

    /// If the SocketAddress is an internet address, unpack into an IP address and port.
    func toHostAndPort() -> (host: IPAddress, port: UInt16)? {
        switch self {
        case let .Internet(host, port):
            return (host, port)
        case .Link:
            return nil
        }
    }

    /// If the SocketAddress is an internet address, obtains the host.
    var host: IPAddress? {
        switch self {
        case let .Internet(host, _):
            return host
        case .Link:
            return nil
        }
    }

    /// Treats this SocketAddress as the host of an HTTP server, and convert to a URL.
    ///
    /// - Important:
    ///   The `path` must begin with a slash, e.g. `"/query?t=1"`.
    func toNSURL(path: String, scheme: String = "http") -> NSURL? {
        switch self {
        case .Internet:
            return NSURL(string: "\(scheme)://\(stringValue)\(path)")
        case .Link:
            return nil
        }
    }

    func toURL(path: String, scheme: String = "http") -> URL? {
        switch self {
        case .Internet:
            return URL(string: "\(scheme)://\(stringValue)\(path)")
        case .Link:
            return nil
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case let .Internet(host, port):
            hasher.combine(0)
            hasher.combine(host)
            hasher.combine(port)
        case let .Link(address, type):
            hasher.combine(1)
            hasher.combine(address)
            hasher.combine(type)
        }
    }

    /// Obtains the socket address family (e.g. AF_INET).
    var family: Int32 {
        switch self {
        case let .Internet(host, _):
            host.family
        case .Link:
            AF_LINK
        }
    }

    static func == (lhs: SocketAddress, rhs: SocketAddress) -> Bool {
        switch (lhs, rhs) {
        case let (.Internet(lh, lp), .Internet(rh, rp)):
            lp == rp && lh == rh
        case let (.Link(la, lt), .Link(ra, rt)):
            la == ra && lt == rt
        default:
            false
        }
    }
}
