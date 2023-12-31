//
//  Created by Mateusz Matrejek
//

import Foundation
import MachO

final class EntitlementsReader {
    enum Error: Swift.Error {
        case binaryOpeningError
        case unknownBinaryFormat
        case codeSignatureCommandMissing
        case signatureReadingError
        case unsupportedFatBinary

        var localizedDescription: String {
            switch self {
            case .binaryOpeningError:
                "Error while opening application binary for reading"
            case .unknownBinaryFormat:
                "The binary format is not supported"
            case .codeSignatureCommandMissing:
                "Unable to find code signature load command"
            case .signatureReadingError:
                "Signature reading error occurred"
            case .unsupportedFatBinary:
                "Fat application binaries are unsupported"
            }
        }
    }

    private struct CSSuperBlob {
        var magic: UInt32
        var lentgh: UInt32
        var count: UInt32
    }

    private struct CSBlob {
        var type: UInt32
        var offset: UInt32
    }

    private enum CSMagic {
        static let embeddedSignature: UInt32 = 0xFADE_0CC0
        static let embededEntitlements: UInt32 = 0xFADE_7171
    }

    private enum BinaryType {
        struct HeaderData {
            let headerSize: Int
            let commandCount: Int
        }

        case singleArch(headerInfo: HeaderData)
        case fat(header: fat_header)
    }

    private let binary: ApplicationBinary

    init(_ binaryPath: String) throws {
        guard let binary = ApplicationBinary(binaryPath) else {
            throw Error.binaryOpeningError
        }
        self.binary = binary
    }

    private func getBinaryType(fromSliceStartingAt offset: UInt64 = 0) -> BinaryType? {
        binary.seek(to: offset)
        let header: mach_header = binary.read()
        let commandCount = Int(header.ncmds)
        switch header.magic {
        case MH_MAGIC:
            let data = BinaryType.HeaderData(headerSize: MemoryLayout<mach_header>.size,
                                             commandCount: commandCount)
            return .singleArch(headerInfo: data)
        case MH_MAGIC_64:
            let data = BinaryType.HeaderData(headerSize: MemoryLayout<mach_header_64>.size,
                                             commandCount: commandCount)
            return .singleArch(headerInfo: data)
        default:
            binary.seek(to: 0)
            let fatHeader: fat_header = binary.read()
            return CFSwapInt32(fatHeader.magic) == FAT_MAGIC ? .fat(header: fatHeader) : nil
        }
    }

    func readEntitlements() throws -> Entitlements {
        switch getBinaryType() {
        case let .singleArch(headerInfo):
            let headerSize = headerInfo.headerSize
            let commandCount = headerInfo.commandCount
            return try readEntitlementsFromBinarySlice(startingAt: headerSize, cmdCount: commandCount)
        case .fat:
            return try readEntitlementsFromFatBinary()
        case .none:
            throw Error.unknownBinaryFormat
        }
    }

    private func readEntitlementsFromBinarySlice(startingAt offset: Int, cmdCount: Int) throws -> Entitlements {
        binary.seek(to: UInt64(offset))
        for _ in 0 ..< cmdCount {
            let command: load_command = binary.read()
            if command.cmd == LC_CODE_SIGNATURE {
                let signatureOffset: UInt32 = binary.read()
                return try readEntitlementsFromSignature(startingAt: signatureOffset)
            }
            binary.seek(to: binary.currentOffset + UInt64(command.cmdsize - UInt32(MemoryLayout<load_command>.size)))
        }
        throw Error.codeSignatureCommandMissing
    }

    private func readEntitlementsFromFatBinary() throws -> Entitlements {
        throw Error.unsupportedFatBinary
    }

    private func readEntitlementsFromSignature(startingAt offset: UInt32) throws -> Entitlements {
        binary.seek(to: UInt64(offset))
        let metaBlob: CSSuperBlob = binary.read()
        if CFSwapInt32(metaBlob.magic) == CSMagic.embeddedSignature {
            let metaBlobSize = UInt32(MemoryLayout<CSSuperBlob>.size)
            let blobSize = UInt32(MemoryLayout<CSBlob>.size)
            let itemCount = CFSwapInt32(metaBlob.count)
            for index in 0 ..< itemCount {
                let readOffset = UInt64(offset + metaBlobSize + index * blobSize)
                binary.seek(to: readOffset)
                let blob: CSBlob = binary.read()
                binary.seek(to: UInt64(offset + CFSwapInt32(blob.offset)))
                let blobMagic = CFSwapInt32(binary.read())
                if blobMagic == CSMagic.embededEntitlements {
                    let signatureLength = CFSwapInt32(binary.read())
                    let signatureData = binary.readData(ofLength: Int(signatureLength) - 8)
                    return Entitlements.entitlements(from: signatureData)
                }
            }
        }
        throw Error.signatureReadingError
    }
}
