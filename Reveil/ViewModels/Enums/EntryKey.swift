//
//  EntryKey.swift
//  Reveil
//
//  Created by Lessica on 2023/10/17.
//

import Foundation

enum EntryKey: Codable, Equatable, Hashable, RawRepresentable {
    typealias RawValue = String

    // Security
    case Security

    // Device Information
    case DeviceName
    case MarketingName
    case DeviceModel
    case BootromVersion
    case RadioTech
    case HostName
    case DisplayResolution

    // Operating System
    case System
    case KernelVersion
    case KernelRelease
    case KernelMaximumVnodes
    case KernelMaximumGroups
    case OSMaxSocketBufferSize
    case OSMaxFilesPerProcess
    case KernelMaximumProcesses
    case HostID
    case Uptime

    // CPU Information
    case CPUInformation
    case CPUUsageUser
    case CPUUsageIdle
    case CPUUsageLoad
    case CPUProcessor
    case CPUArchitecture
    case CPUFamily
    case CPUNumberOfCores
    case CPUByteOrder
    case CPUCacheLine
    case CPUL1ICacheSize
    case CPUL1DCacheSize
    case CPUL2CacheSize
    case CPUTBFrequency

    // Memory Information
    case MemoryInformation
    case MemoryBytesWired
    case MemoryBytesActive
    case MemoryBytesInactive
    case MemoryBytesPurgeable
    case MemoryBytesOthers
    case MemoryBytesFree
    case MemoryPageReactivations
    case MemoryPageIns
    case MemoryPageOuts
    case MemoryPageFaults
    case MemoryPageCOWFaults
    case MemoryPageLookups
    case MemoryPageHits
    case MemoryPagePurges
    case MemoryBytesZeroFilled
    case MemoryBytesSpeculative
    case MemoryBytesDecompressed
    case MemoryBytesCompressed
    case MemoryBytesSwappedIn
    case MemoryBytesSwappedOut
    case MemoryBytesCompressor
    case MemoryBytesThrottled
    case MemoryBytesFileBacked
    case MemoryBytesAnonymous
    case MemoryBytesUncompressed
    case MemorySize
    case PhysicalMemory
    case UserMemory
    case KernelPageSize
    case PageSize

    // Disk Space
    case DiskSpace
    case DiskTotal
    case DiskUsed
    case DiskFree

    // File Systems
    case FileSystems
    case MountPoint(path: String)
    case BlockSize(path: String)
    case OptimalTransferSize(path: String)
    case FileSystemBlocks(path: String)
    case FileSystemFreeBlocks(path: String)
    case FileSystemAvailableBlocks(path: String)
    case FileSystemNodes(path: String)
    case FileSystemFreeNodes(path: String)
    case FileSystemIdentifier(path: String)
    case FileSystemOwner(path: String)
    case FileSystemType(path: String)
    case FileSystemAttributes(path: String)
    case FileSystemFlavor(path: String)
    case FileSystemDevice(path: String)

    // Network Interfaces
    case NetworkInterfaces
    case InterfaceName(name: String)
    case InterfaceMacAddress(name: String)
    case NetworkAddress(name: String, index: Int)
    case NetworkBroadcastAddress(name: String, index: Int)
    case NetworkMaskAddress(name: String, index: Int)
    case NetworkAddressCount(name: String)
    case InterfaceFlags(name: String)
    case InterfaceMTU(name: String)
    case InterfaceMetric(name: String)
    case InterfaceLineSpeed(name: String)
    case InterfacePacketsReceived(name: String)
    case InterfaceInputErrors(name: String)
    case InterfacePacketsSent(name: String)
    case InterfaceOutputErrors(name: String)
    case InterfaceCollisions(name: String)
    case InterfaceBytesReceived(name: String)
    case InterfaceBytesSent(name: String)
    case InterfaceMulticastPacketsReceived(name: String)
    case InterfaceMulticastPacketsSent(name: String)
    case InterfacePacketsDropped(name: String)
    case InterfacePacketsUnsupported(name: String)
    case InterfaceSpentReceiving(name: String)
    case InterfaceSpentXmitting(name: String)
    case InterfaceLastChange(name: String)

    // Network Usage
    case NetworkUsage
    case NetworkCategoryUsage(prefix: String)

    // Network Details
    case NetworkCategoryBytesDownload(prefix: String)
    case NetworkCategoryBytesUpload(prefix: String)

    // Battery Information
    case BatteryInformation
    case BatteryLevel
    case BatteryUsed
    case BatteryState
    case BatteryCapacity

    // Custom
    case Custom(name: String)
    case Section(name: String)
    case AllowedToCopy(name: String)

    var isPinnable: Bool {
        switch self {
        case .CPUUsageUser: fallthrough
        case .CPUUsageIdle: fallthrough
        case .MountPoint: fallthrough
        case .BlockSize: fallthrough
        case .OptimalTransferSize: fallthrough
        case .FileSystemBlocks: fallthrough
        case .FileSystemFreeBlocks: fallthrough
        case .FileSystemAvailableBlocks: fallthrough
        case .FileSystemNodes: fallthrough
        case .FileSystemFreeNodes: fallthrough
        case .FileSystemIdentifier: fallthrough
        case .FileSystemOwner: fallthrough
        case .FileSystemType: fallthrough
        case .FileSystemAttributes: fallthrough
        case .FileSystemFlavor: fallthrough
        case .FileSystemDevice: fallthrough
        case .InterfaceName: fallthrough
        case .InterfaceMacAddress: fallthrough
        case .NetworkAddress: fallthrough
        case .NetworkBroadcastAddress: fallthrough
        case .NetworkMaskAddress: fallthrough
        case .NetworkAddressCount: fallthrough
        case .InterfaceFlags: fallthrough
        case .InterfaceMTU: fallthrough
        case .InterfaceMetric: fallthrough
        case .InterfaceLineSpeed: fallthrough
        case .InterfacePacketsReceived: fallthrough
        case .InterfaceInputErrors: fallthrough
        case .InterfacePacketsSent: fallthrough
        case .InterfaceOutputErrors: fallthrough
        case .InterfaceCollisions: fallthrough
        case .InterfaceBytesReceived: fallthrough
        case .InterfaceBytesSent: fallthrough
        case .InterfaceMulticastPacketsReceived: fallthrough
        case .InterfaceMulticastPacketsSent: fallthrough
        case .InterfacePacketsDropped: fallthrough
        case .InterfacePacketsUnsupported: fallthrough
        case .InterfaceSpentReceiving: fallthrough
        case .InterfaceSpentXmitting: fallthrough
        case .InterfaceLastChange: fallthrough
        case .BatteryLevel: fallthrough
        case .BatteryUsed: fallthrough
        case .Custom: fallthrough
        case .Section: fallthrough
        case .AllowedToCopy:
            return false
        default: break
        }
        return true
    }

    init?(rawValue: String) {
        switch rawValue {
        case "Security":
            self = .Security
        case "DeviceName":
            self = .DeviceName
        case "MarketingName":
            self = .MarketingName
        case "DeviceModel":
            self = .DeviceModel
        case "BootromVersion":
            self = .BootromVersion
        case "RadioTech":
            self = .RadioTech
        case "HostName":
            self = .HostName
        case "DisplayResolution":
            self = .DisplayResolution
        case "System":
            self = .System
        case "KernelVersion":
            self = .KernelVersion
        case "KernelRelease":
            self = .KernelRelease
        case "KernelMaximumVnodes":
            self = .KernelMaximumVnodes
        case "KernelMaximumGroups":
            self = .KernelMaximumGroups
        case "OSMaxSocketBufferSize":
            self = .OSMaxSocketBufferSize
        case "OSMaxFilesPerProcess":
            self = .OSMaxFilesPerProcess
        case "KernelMaximumProcesses":
            self = .KernelMaximumProcesses
        case "HostID":
            self = .HostID
        case "Uptime":
            self = .Uptime
        case "CPUInformation":
            self = .CPUInformation
        case "CPUUsageUser":
            self = .CPUUsageUser
        case "CPUUsageIdle":
            self = .CPUUsageIdle
        case "CPUUsageLoad":
            self = .CPUUsageLoad
        case "CPUProcessor":
            self = .CPUProcessor
        case "CPUArchitecture":
            self = .CPUArchitecture
        case "CPUFamily":
            self = .CPUFamily
        case "CPUNumberOfCores":
            self = .CPUNumberOfCores
        case "CPUByteOrder":
            self = .CPUByteOrder
        case "CPUCacheLine":
            self = .CPUCacheLine
        case "CPUL1ICacheSize":
            self = .CPUL1ICacheSize
        case "CPUL1DCacheSize":
            self = .CPUL1DCacheSize
        case "CPUL2CacheSize":
            self = .CPUL2CacheSize
        case "CPUTBFrequency":
            self = .CPUTBFrequency
        case "MemoryInformation":
            self = .MemoryInformation
        case "MemoryBytesWired":
            self = .MemoryBytesWired
        case "MemoryBytesActive":
            self = .MemoryBytesActive
        case "MemoryBytesInactive":
            self = .MemoryBytesInactive
        case "MemoryBytesPurgeable":
            self = .MemoryBytesPurgeable
        case "MemoryBytesOthers":
            self = .MemoryBytesOthers
        case "MemoryBytesFree":
            self = .MemoryBytesFree
        case "MemoryPageReactivations":
            self = .MemoryPageReactivations
        case "MemoryPageIns":
            self = .MemoryPageIns
        case "MemoryPageOuts":
            self = .MemoryPageOuts
        case "MemoryPageFaults":
            self = .MemoryPageFaults
        case "MemoryPageCOWFaults":
            self = .MemoryPageCOWFaults
        case "MemoryPageLookups":
            self = .MemoryPageLookups
        case "MemoryPageHits":
            self = .MemoryPageHits
        case "MemoryPagePurges":
            self = .MemoryPagePurges
        case "MemoryBytesZeroFilled":
            self = .MemoryBytesZeroFilled
        case "MemoryBytesSpeculative":
            self = .MemoryBytesSpeculative
        case "MemoryBytesDecompressed":
            self = .MemoryBytesDecompressed
        case "MemoryBytesCompressed":
            self = .MemoryBytesCompressed
        case "MemoryBytesSwappedIn":
            self = .MemoryBytesSwappedIn
        case "MemoryBytesSwappedOut":
            self = .MemoryBytesSwappedOut
        case "MemoryBytesCompressor":
            self = .MemoryBytesCompressor
        case "MemoryBytesThrottled":
            self = .MemoryBytesThrottled
        case "MemoryBytesFileBacked":
            self = .MemoryBytesFileBacked
        case "MemoryBytesAnonymous":
            self = .MemoryBytesAnonymous
        case "MemoryBytesUncompressed":
            self = .MemoryBytesUncompressed
        case "MemorySize":
            self = .MemorySize
        case "PhysicalMemory":
            self = .PhysicalMemory
        case "UserMemory":
            self = .UserMemory
        case "KernelPageSize":
            self = .KernelPageSize
        case "PageSize":
            self = .PageSize
        case "DiskSpace":
            self = .DiskSpace
        case "DiskTotal":
            self = .DiskTotal
        case "DiskUsed":
            self = .DiskUsed
        case "DiskFree":
            self = .DiskFree
        case "FileSystems":
            self = .FileSystems
        case "NetworkInterfaces":
            self = .NetworkInterfaces
        case "NetworkUsage":
            self = .NetworkUsage
        case "BatteryInformation":
            self = .BatteryInformation
        case "BatteryLevel":
            self = .BatteryLevel
        case "BatteryUsed":
            self = .BatteryUsed
        case "BatteryState":
            self = .BatteryState
        case "BatteryCapacity":
            self = .BatteryCapacity
        default:
            let comps = rawValue.components(separatedBy: ":")
            guard let compKey = comps.first else {
                return nil
            }
            if compKey == "Custom" || compKey == "Section" || compKey == "AllowedToCopy" {
                let compVal = comps.dropFirst().joined(separator: ":")
                if compKey == "Custom" {
                    self = .Custom(name: compVal)
                } else if compKey == "Section" {
                    self = .Section(name: compVal)
                } else {
                    self = .AllowedToCopy(name: compVal)
                }
            } else if comps.count == 2 {
                switch compKey {
                case "MountPoint":
                    self = .MountPoint(path: comps[1])
                case "BlockSize":
                    self = .BlockSize(path: comps[1])
                case "OptimalTransferSize":
                    self = .OptimalTransferSize(path: comps[1])
                case "FileSystemBlocks":
                    self = .FileSystemBlocks(path: comps[1])
                case "FileSystemFreeBlocks":
                    self = .FileSystemFreeBlocks(path: comps[1])
                case "FileSystemAvailableBlocks":
                    self = .FileSystemAvailableBlocks(path: comps[1])
                case "FileSystemNodes":
                    self = .FileSystemNodes(path: comps[1])
                case "FileSystemFreeNodes":
                    self = .FileSystemFreeNodes(path: comps[1])
                case "FileSystemIdentifier":
                    self = .FileSystemIdentifier(path: comps[1])
                case "FileSystemOwner":
                    self = .FileSystemOwner(path: comps[1])
                case "FileSystemType":
                    self = .FileSystemType(path: comps[1])
                case "FileSystemAttributes":
                    self = .FileSystemAttributes(path: comps[1])
                case "FileSystemFlavor":
                    self = .FileSystemFlavor(path: comps[1])
                case "FileSystemDevice":
                    self = .FileSystemDevice(path: comps[1])
                case "InterfaceName":
                    self = .InterfaceName(name: comps[1])
                case "InterfaceMacAddress":
                    self = .InterfaceMacAddress(name: comps[1])
                case "NetworkAddressCount":
                    self = .NetworkAddressCount(name: comps[1])
                case "InterfaceFlags":
                    self = .InterfaceFlags(name: comps[1])
                case "InterfaceMTU":
                    self = .InterfaceMTU(name: comps[1])
                case "InterfaceMetric":
                    self = .InterfaceMetric(name: comps[1])
                case "InterfaceLineSpeed":
                    self = .InterfaceLineSpeed(name: comps[1])
                case "InterfacePacketsReceived":
                    self = .InterfacePacketsReceived(name: comps[1])
                case "InterfaceInputErrors":
                    self = .InterfaceInputErrors(name: comps[1])
                case "InterfacePacketsSent":
                    self = .InterfacePacketsSent(name: comps[1])
                case "InterfaceOutputErrors":
                    self = .InterfaceOutputErrors(name: comps[1])
                case "InterfaceCollisions":
                    self = .InterfaceCollisions(name: comps[1])
                case "InterfaceBytesReceived":
                    self = .InterfaceBytesReceived(name: comps[1])
                case "InterfaceBytesSent":
                    self = .InterfaceBytesSent(name: comps[1])
                case "InterfaceMulticastPacketsReceived":
                    self = .InterfaceMulticastPacketsReceived(name: comps[1])
                case "InterfaceMulticastPacketsSent":
                    self = .InterfaceMulticastPacketsSent(name: comps[1])
                case "InterfacePacketsDropped":
                    self = .InterfacePacketsDropped(name: comps[1])
                case "InterfacePacketsUnsupported":
                    self = .InterfacePacketsUnsupported(name: comps[1])
                case "InterfaceSpentReceiving":
                    self = .InterfaceSpentReceiving(name: comps[1])
                case "InterfaceSpentXmitting":
                    self = .InterfaceSpentXmitting(name: comps[1])
                case "InterfaceLastChange":
                    self = .InterfaceLastChange(name: comps[1])
                case "NetworkCategoryUsage":
                    self = .NetworkCategoryUsage(prefix: comps[1])
                case "NetworkCategoryBytesDownload":
                    self = .NetworkCategoryBytesDownload(prefix: comps[1])
                case "NetworkCategoryBytesUpload":
                    self = .NetworkCategoryBytesUpload(prefix: comps[1])
                default:
                    return nil
                }
            } else if comps.count == 3 {
                switch compKey {
                case "NetworkAddress":
                    self = .NetworkAddress(name: comps[1], index: Int(comps[2]) ?? 0)
                case "NetworkBroadcastAddress":
                    self = .NetworkBroadcastAddress(name: comps[1], index: Int(comps[2]) ?? 0)
                case "NetworkMaskAddress":
                    self = .NetworkMaskAddress(name: comps[1], index: Int(comps[2]) ?? 0)
                default:
                    return nil
                }
            } else {
                return nil
            }
        }
    }

    var rawValue: String {
        switch self {
        case .Security:
            return "Security"
        case .DeviceName:
            return "DeviceName"
        case .MarketingName:
            return "MarketingName"
        case .DeviceModel:
            return "DeviceModel"
        case .BootromVersion:
            return "BootromVersion"
        case .RadioTech:
            return "RadioTech"
        case .HostName:
            return "HostName"
        case .DisplayResolution:
            return "DisplayResolution"
        case .System:
            return "System"
        case .KernelVersion:
            return "KernelVersion"
        case .KernelRelease:
            return "KernelRelease"
        case .KernelMaximumVnodes:
            return "KernelMaximumVnodes"
        case .KernelMaximumGroups:
            return "KernelMaximumGroups"
        case .OSMaxSocketBufferSize:
            return "OSMaxSocketBufferSize"
        case .OSMaxFilesPerProcess:
            return "OSMaxFilesPerProcess"
        case .KernelMaximumProcesses:
            return "KernelMaximumProcesses"
        case .HostID:
            return "HostID"
        case .Uptime:
            return "Uptime"
        case .CPUInformation:
            return "CPUInformation"
        case .CPUUsageUser:
            return "CPUUsageUser"
        case .CPUUsageIdle:
            return "CPUUsageIdle"
        case .CPUUsageLoad:
            return "CPUUsageLoad"
        case .CPUProcessor:
            return "CPUProcessor"
        case .CPUArchitecture:
            return "CPUArchitecture"
        case .CPUFamily:
            return "CPUFamily"
        case .CPUNumberOfCores:
            return "CPUNumberOfCores"
        case .CPUByteOrder:
            return "CPUByteOrder"
        case .CPUCacheLine:
            return "CPUCacheLine"
        case .CPUL1ICacheSize:
            return "CPUL1ICacheSize"
        case .CPUL1DCacheSize:
            return "CPUL1DCacheSize"
        case .CPUL2CacheSize:
            return "CPUL2CacheSize"
        case .CPUTBFrequency:
            return "CPUTBFrequency"
        case .MemoryInformation:
            return "MemoryInformation"
        case .MemoryBytesWired:
            return "MemoryBytesWired"
        case .MemoryBytesActive:
            return "MemoryBytesActive"
        case .MemoryBytesInactive:
            return "MemoryBytesInactive"
        case .MemoryBytesPurgeable:
            return "MemoryBytesPurgeable"
        case .MemoryBytesOthers:
            return "MemoryBytesOthers"
        case .MemoryBytesFree:
            return "MemoryBytesFree"
        case .MemoryPageReactivations:
            return "MemoryPageReactivations"
        case .MemoryPageIns:
            return "MemoryPageIns"
        case .MemoryPageOuts:
            return "MemoryPageOuts"
        case .MemoryPageFaults:
            return "MemoryPageFaults"
        case .MemoryPageCOWFaults:
            return "MemoryPageCOWFaults"
        case .MemoryPageLookups:
            return "MemoryPageLookups"
        case .MemoryPageHits:
            return "MemoryPageHits"
        case .MemoryPagePurges:
            return "MemoryPagePurges"
        case .MemoryBytesZeroFilled:
            return "MemoryBytesZeroFilled"
        case .MemoryBytesSpeculative:
            return "MemoryBytesSpeculative"
        case .MemoryBytesDecompressed:
            return "MemoryBytesDecompressed"
        case .MemoryBytesCompressed:
            return "MemoryBytesCompressed"
        case .MemoryBytesSwappedIn:
            return "MemoryBytesSwappedIn"
        case .MemoryBytesSwappedOut:
            return "MemoryBytesSwappedOut"
        case .MemoryBytesCompressor:
            return "MemoryBytesCompressor"
        case .MemoryBytesThrottled:
            return "MemoryBytesThrottled"
        case .MemoryBytesFileBacked:
            return "MemoryBytesFileBacked"
        case .MemoryBytesAnonymous:
            return "MemoryBytesAnonymous"
        case .MemoryBytesUncompressed:
            return "MemoryBytesUncompressed"
        case .MemorySize:
            return "MemorySize"
        case .PhysicalMemory:
            return "PhysicalMemory"
        case .UserMemory:
            return "UserMemory"
        case .KernelPageSize:
            return "KernelPageSize"
        case .PageSize:
            return "PageSize"
        case .DiskSpace:
            return "DiskSpace"
        case .DiskTotal:
            return "DiskTotal"
        case .DiskUsed:
            return "DiskUsed"
        case .DiskFree:
            return "DiskFree"
        case .FileSystems:
            return "FileSystems"
        case let .MountPoint(path):
            return String(format: "MountPoint:%@", path)
        case let .BlockSize(path):
            return String(format: "BlockSize:%@", path)
        case let .OptimalTransferSize(path):
            return String(format: "OptimalTransferSize:%@", path)
        case let .FileSystemBlocks(path):
            return String(format: "FileSystemBlocks:%@", path)
        case let .FileSystemFreeBlocks(path):
            return String(format: "FileSystemFreeBlocks:%@", path)
        case let .FileSystemAvailableBlocks(path):
            return String(format: "FileSystemAvailableBlocks:%@", path)
        case let .FileSystemNodes(path):
            return String(format: "FileSystemNodes:%@", path)
        case let .FileSystemFreeNodes(path):
            return String(format: "FileSystemFreeNodes:%@", path)
        case let .FileSystemIdentifier(path):
            return String(format: "FileSystemIdentifier:%@", path)
        case let .FileSystemOwner(path):
            return String(format: "FileSystemOwner:%@", path)
        case let .FileSystemType(path):
            return String(format: "FileSystemType:%@", path)
        case let .FileSystemAttributes(path):
            return String(format: "FileSystemAttributes:%@", path)
        case let .FileSystemFlavor(path):
            return String(format: "FileSystemFlavor:%@", path)
        case let .FileSystemDevice(path):
            return String(format: "FileSystemDevice:%@", path)
        case .NetworkInterfaces:
            return "NetworkInterfaces"
        case let .InterfaceName(name):
            return String(format: "InterfaceName:%@", name)
        case let .InterfaceMacAddress(name):
            return String(format: "InterfaceMacAddress:%@", name)
        case let .NetworkAddress(name, index):
            return String(format: "NetworkAddress:%@:%d", name, index)
        case let .NetworkBroadcastAddress(name, index):
            return String(format: "NetworkBroadcastAddress:%@:%d", name, index)
        case let .NetworkMaskAddress(name, index):
            return String(format: "NetworkMaskAddress:%@:%d", name, index)
        case let .NetworkAddressCount(name):
            return String(format: "NetworkAddressCount:%@", name)
        case let .InterfaceFlags(name):
            return String(format: "InterfaceFlags:%@", name)
        case let .InterfaceMTU(name):
            return String(format: "InterfaceMTU:%@", name)
        case let .InterfaceMetric(name):
            return String(format: "InterfaceMetric:%@", name)
        case let .InterfaceLineSpeed(name):
            return String(format: "InterfaceLineSpeed:%@", name)
        case let .InterfacePacketsReceived(name):
            return String(format: "InterfacePacketsReceived:%@", name)
        case let .InterfaceInputErrors(name):
            return String(format: "InterfaceInputErrors:%@", name)
        case let .InterfacePacketsSent(name):
            return String(format: "InterfacePacketsSent:%@", name)
        case let .InterfaceOutputErrors(name):
            return String(format: "InterfaceOutputErrors:%@", name)
        case let .InterfaceCollisions(name):
            return String(format: "InterfaceCollisions:%@", name)
        case let .InterfaceBytesReceived(name):
            return String(format: "InterfaceBytesReceived:%@", name)
        case let .InterfaceBytesSent(name):
            return String(format: "InterfaceBytesSent:%@", name)
        case let .InterfaceMulticastPacketsReceived(name):
            return String(format: "InterfaceMulticastPacketsReceived:%@", name)
        case let .InterfaceMulticastPacketsSent(name):
            return String(format: "InterfaceMulticastPacketsSent:%@", name)
        case let .InterfacePacketsDropped(name):
            return String(format: "InterfacePacketsDropped:%@", name)
        case let .InterfacePacketsUnsupported(name):
            return String(format: "InterfacePacketsUnsupported:%@", name)
        case let .InterfaceSpentReceiving(name):
            return String(format: "InterfaceSpentReceiving:%@", name)
        case let .InterfaceSpentXmitting(name):
            return String(format: "InterfaceSpentXmitting:%@", name)
        case let .InterfaceLastChange(name):
            return String(format: "InterfaceLastChange:%@", name)
        case .NetworkUsage:
            return "NetworkUsage"
        case let .NetworkCategoryUsage(prefix):
            return String(format: "NetworkCategoryUsage:%@", prefix)
        case let .NetworkCategoryBytesDownload(prefix):
            return String(format: "NetworkCategoryBytesDownload:%@", prefix)
        case let .NetworkCategoryBytesUpload(prefix):
            return String(format: "NetworkCategoryBytesUpload:%@", prefix)
        case .BatteryInformation:
            return "BatteryInformation"
        case .BatteryLevel:
            return "BatteryLevel"
        case .BatteryUsed:
            return "BatteryUsed"
        case .BatteryState:
            return "BatteryState"
        case .BatteryCapacity:
            return "BatteryCapacity"
        case let .Custom(name):
            return String(format: "Custom:%@", name)
        case let .Section(name):
            return String(format: "Section:%@", name)
        case let .AllowedToCopy(name):
            return String(format: "AllowedToCopy:%@", name)
        }
    }
}
