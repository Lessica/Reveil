//
//  ThreadState.swift
//  Reveil
//
//  Created by Lessica on 2023/10/30.
//

import Foundation

struct GeneralThreadState: Codable {
    let data: thread_state_data_t

    enum CodingKeys: CodingKey {
        case data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode(Data.self, forKey: .data).withUnsafeBytes {
            $0.bindMemory(to: thread_state_data_t.self)[0]
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(withUnsafePointer(to: data) { ptr in
            ptr.withMemoryRebound(to: natural_t.self, capacity: MemoryLayout.size(ofValue: ptr)) { pointer in
                let buffer = UnsafeBufferPointer(start: pointer, count: Mirror(reflecting: data).children.count)
                return Data(buffer: buffer)
            }
        }, forKey: .data)
    }
}

#if arch(arm64)
    struct ARM64ThreadState: Codable {
        let data: arm_thread_state64_t
    }

    typealias ARM64GeneralPurposeRegisters = (__uint64_t, __uint64_t, __uint64_t, __uint64_t, __uint64_t, __uint64_t, __uint64_t, __uint64_t, __uint64_t, __uint64_t, __uint64_t, __uint64_t, __uint64_t, __uint64_t, __uint64_t, __uint64_t, __uint64_t, __uint64_t, __uint64_t, __uint64_t, __uint64_t, __uint64_t, __uint64_t, __uint64_t, __uint64_t, __uint64_t, __uint64_t, __uint64_t, __uint64_t)

    extension arm_thread_state64_t: Codable {
        enum CodingKeys: CodingKey {
            case __x
            case __fp
            case __lr
            case __sp
            case __pc
            case __cpsr
            case __pad
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            try self.init(
                __x: container.decode(Data.self, forKey: .__x).withUnsafeBytes {
                    $0.bindMemory(to: ARM64GeneralPurposeRegisters.self)[0]
                },
                __fp: container.decode(UInt64.self, forKey: .__fp),
                __lr: container.decode(UInt64.self, forKey: .__lr),
                __sp: container.decode(UInt64.self, forKey: .__sp),
                __pc: container.decode(UInt64.self, forKey: .__pc),
                __cpsr: container.decode(UInt32.self, forKey: .__cpsr),
                __pad: container.decode(UInt32.self, forKey: .__pad)
            )
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(withUnsafePointer(to: __x) { ptr in
                ptr.withMemoryRebound(to: __uint64_t.self, capacity: MemoryLayout.size(ofValue: ptr)) { pointer in
                    let buffer = UnsafeBufferPointer(start: pointer, count: Mirror(reflecting: __x).children.count)
                    return Data(buffer: buffer)
                }
            }, forKey: .__x)
            try container.encode(__fp, forKey: .__fp)
            try container.encode(__lr, forKey: .__lr)
            try container.encode(__sp, forKey: .__sp)
            try container.encode(__pc, forKey: .__pc)
            try container.encode(__cpsr, forKey: .__cpsr)
            try container.encode(__pad, forKey: .__pad)
        }
    }
#endif
