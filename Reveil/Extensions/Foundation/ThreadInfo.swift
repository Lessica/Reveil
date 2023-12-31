//
//  ThreadInfo.swift
//  Reveil
//
//  Created by Lessica on 2023/10/30.
//

import Foundation

struct ThreadInfo: Codable {
    let label: String
    let basic: thread_basic_info
    let identifier: thread_identifier_info
    let extended: thread_extended_info
}

extension time_value: Codable {
    enum CodingKeys: CodingKey {
        case seconds
        case microseconds
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(seconds: container.decode(Int32.self, forKey: .seconds), microseconds: container.decode(Int32.self, forKey: .microseconds))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(seconds, forKey: .seconds)
        try container.encode(microseconds, forKey: .microseconds)
    }
}

extension thread_basic_info: Codable {
    enum CodingKeys: CodingKey {
        case user_time
        case system_time
        case cpu_usage
        case policy
        case run_state
        case flags
        case suspend_count
        case sleep_time
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            user_time: container.decode(time_value_t.self, forKey: .user_time),
            system_time: container.decode(time_value_t.self, forKey: .system_time),
            cpu_usage: container.decode(Int32.self, forKey: .cpu_usage),
            policy: container.decode(Int32.self, forKey: .policy),
            run_state: container.decode(Int32.self, forKey: .run_state),
            flags: container.decode(Int32.self, forKey: .flags),
            suspend_count: container.decode(Int32.self, forKey: .suspend_count),
            sleep_time: container.decode(Int32.self, forKey: .sleep_time)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(user_time, forKey: .user_time)
        try container.encode(system_time, forKey: .system_time)
        try container.encode(cpu_usage, forKey: .cpu_usage)
        try container.encode(policy, forKey: .policy)
        try container.encode(run_state, forKey: .run_state)
        try container.encode(flags, forKey: .flags)
        try container.encode(suspend_count, forKey: .suspend_count)
        try container.encode(sleep_time, forKey: .sleep_time)
    }
}

extension thread_identifier_info: Codable {
    enum CodingKeys: CodingKey {
        case thread_id
        case thread_handle
        case dispatch_qaddr
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            thread_id: container.decode(UInt64.self, forKey: .thread_id),
            thread_handle: container.decode(UInt64.self, forKey: .thread_handle),
            dispatch_qaddr: container.decode(UInt64.self, forKey: .dispatch_qaddr)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(thread_id, forKey: .thread_id)
        try container.encode(thread_handle, forKey: .thread_handle)
        try container.encode(dispatch_qaddr, forKey: .dispatch_qaddr)
    }
}

typealias ThreadName = (CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar, CChar)

extension thread_extended_info: Codable {
    enum CodingKeys: CodingKey {
        case pth_user_time
        case pth_system_time
        case pth_cpu_usage
        case pth_policy
        case pth_run_state
        case pth_flags
        case pth_sleep_time
        case pth_curpri
        case pth_priority
        case pth_maxpriority
        case pth_name
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            pth_user_time: container.decode(UInt64.self, forKey: .pth_user_time),
            pth_system_time: container.decode(UInt64.self, forKey: .pth_system_time),
            pth_cpu_usage: container.decode(Int32.self, forKey: .pth_cpu_usage),
            pth_policy: container.decode(Int32.self, forKey: .pth_policy),
            pth_run_state: container.decode(Int32.self, forKey: .pth_run_state),
            pth_flags: container.decode(Int32.self, forKey: .pth_flags),
            pth_sleep_time: container.decode(Int32.self, forKey: .pth_sleep_time),
            pth_curpri: container.decode(Int32.self, forKey: .pth_curpri),
            pth_priority: container.decode(Int32.self, forKey: .pth_priority),
            pth_maxpriority: container.decode(Int32.self, forKey: .pth_maxpriority),
            pth_name: container.decode(String.self, forKey: .pth_name).utf8CString.withUnsafeBytes {
                $0.bindMemory(to: ThreadName.self)[0]
            }
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(pth_user_time, forKey: .pth_user_time)
        try container.encode(pth_system_time, forKey: .pth_system_time)
        try container.encode(pth_cpu_usage, forKey: .pth_cpu_usage)
        try container.encode(pth_policy, forKey: .pth_policy)
        try container.encode(pth_run_state, forKey: .pth_run_state)
        try container.encode(pth_flags, forKey: .pth_flags)
        try container.encode(pth_sleep_time, forKey: .pth_sleep_time)
        try container.encode(pth_curpri, forKey: .pth_curpri)
        try container.encode(pth_priority, forKey: .pth_priority)
        try container.encode(pth_maxpriority, forKey: .pth_maxpriority)
        try container.encode(withUnsafePointer(to: pth_name) { ptr in
            ptr.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: ptr)) { pointer in
                let buffer = UnsafeBufferPointer(start: pointer, count: Mirror(reflecting: pth_name).children.count)
                return String(cString: buffer.map { $0 })
            }
        }, forKey: .pth_name)
    }
}
