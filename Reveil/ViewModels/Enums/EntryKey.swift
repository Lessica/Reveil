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

    // Screen Information
    case DisplayResolution
    case ScreenPhysicalResolution
    case ScreenPhysicalScale
    case ScreenLogicalResolution
    case ScreenLogicalScale

    // Operating System
    case System
    case UserAgent
    case KernelVersion
    case KernelRelease
    case KernelMaximumVnodes
    case KernelMaximumGroups
    case OSMaxSocketBufferSize
    case OSMaxFilesPerProcess
    case KernelMaximumProcesses
    case HostID
    case Uptime
    case UptimeAt

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
    case BatteryLowPowerMode

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
        case "ScreenPhysicalResolution":
            self = .ScreenPhysicalResolution
        case "ScreenPhysicalScale":
            self = .ScreenPhysicalScale
        case "ScreenLogicalResolution":
            self = .ScreenLogicalResolution
        case "ScreenLogicalScale":
            self = .ScreenLogicalScale
        case "System":
            self = .System
        case "UserAgent":
            self = .UserAgent
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
        case "UptimeAt":
            self = .UptimeAt
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
        case "BatteryLowPowerMode":
            self = .BatteryLowPowerMode
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
            "Security"
        case .DeviceName:
            "DeviceName"
        case .MarketingName:
            "MarketingName"
        case .DeviceModel:
            "DeviceModel"
        case .BootromVersion:
            "BootromVersion"
        case .RadioTech:
            "RadioTech"
        case .HostName:
            "HostName"
        case .DisplayResolution:
            "DisplayResolution"
        case .ScreenPhysicalResolution:
            "ScreenPhysicalResolution"
        case .ScreenPhysicalScale:
            "ScreenPhysicalScale"
        case .ScreenLogicalResolution:
            "ScreenLogicalResolution"
        case .ScreenLogicalScale:
            "ScreenLogicalScale"
        case .System:
            "System"
        case .UserAgent:
            "UserAgent"
        case .KernelVersion:
            "KernelVersion"
        case .KernelRelease:
            "KernelRelease"
        case .KernelMaximumVnodes:
            "KernelMaximumVnodes"
        case .KernelMaximumGroups:
            "KernelMaximumGroups"
        case .OSMaxSocketBufferSize:
            "OSMaxSocketBufferSize"
        case .OSMaxFilesPerProcess:
            "OSMaxFilesPerProcess"
        case .KernelMaximumProcesses:
            "KernelMaximumProcesses"
        case .HostID:
            "HostID"
        case .Uptime:
            "Uptime"
        case .UptimeAt:
            "UptimeAt"
        case .CPUInformation:
            "CPUInformation"
        case .CPUUsageUser:
            "CPUUsageUser"
        case .CPUUsageIdle:
            "CPUUsageIdle"
        case .CPUUsageLoad:
            "CPUUsageLoad"
        case .CPUProcessor:
            "CPUProcessor"
        case .CPUArchitecture:
            "CPUArchitecture"
        case .CPUFamily:
            "CPUFamily"
        case .CPUNumberOfCores:
            "CPUNumberOfCores"
        case .CPUByteOrder:
            "CPUByteOrder"
        case .CPUCacheLine:
            "CPUCacheLine"
        case .CPUL1ICacheSize:
            "CPUL1ICacheSize"
        case .CPUL1DCacheSize:
            "CPUL1DCacheSize"
        case .CPUL2CacheSize:
            "CPUL2CacheSize"
        case .CPUTBFrequency:
            "CPUTBFrequency"
        case .MemoryInformation:
            "MemoryInformation"
        case .MemoryBytesWired:
            "MemoryBytesWired"
        case .MemoryBytesActive:
            "MemoryBytesActive"
        case .MemoryBytesInactive:
            "MemoryBytesInactive"
        case .MemoryBytesPurgeable:
            "MemoryBytesPurgeable"
        case .MemoryBytesOthers:
            "MemoryBytesOthers"
        case .MemoryBytesFree:
            "MemoryBytesFree"
        case .MemoryPageReactivations:
            "MemoryPageReactivations"
        case .MemoryPageIns:
            "MemoryPageIns"
        case .MemoryPageOuts:
            "MemoryPageOuts"
        case .MemoryPageFaults:
            "MemoryPageFaults"
        case .MemoryPageCOWFaults:
            "MemoryPageCOWFaults"
        case .MemoryPageLookups:
            "MemoryPageLookups"
        case .MemoryPageHits:
            "MemoryPageHits"
        case .MemoryPagePurges:
            "MemoryPagePurges"
        case .MemoryBytesZeroFilled:
            "MemoryBytesZeroFilled"
        case .MemoryBytesSpeculative:
            "MemoryBytesSpeculative"
        case .MemoryBytesDecompressed:
            "MemoryBytesDecompressed"
        case .MemoryBytesCompressed:
            "MemoryBytesCompressed"
        case .MemoryBytesSwappedIn:
            "MemoryBytesSwappedIn"
        case .MemoryBytesSwappedOut:
            "MemoryBytesSwappedOut"
        case .MemoryBytesCompressor:
            "MemoryBytesCompressor"
        case .MemoryBytesThrottled:
            "MemoryBytesThrottled"
        case .MemoryBytesFileBacked:
            "MemoryBytesFileBacked"
        case .MemoryBytesAnonymous:
            "MemoryBytesAnonymous"
        case .MemoryBytesUncompressed:
            "MemoryBytesUncompressed"
        case .MemorySize:
            "MemorySize"
        case .PhysicalMemory:
            "PhysicalMemory"
        case .UserMemory:
            "UserMemory"
        case .KernelPageSize:
            "KernelPageSize"
        case .PageSize:
            "PageSize"
        case .DiskSpace:
            "DiskSpace"
        case .DiskTotal:
            "DiskTotal"
        case .DiskUsed:
            "DiskUsed"
        case .DiskFree:
            "DiskFree"
        case .FileSystems:
            "FileSystems"
        case let .MountPoint(path):
            String(format: "MountPoint:%@", path)
        case let .BlockSize(path):
            String(format: "BlockSize:%@", path)
        case let .OptimalTransferSize(path):
            String(format: "OptimalTransferSize:%@", path)
        case let .FileSystemBlocks(path):
            String(format: "FileSystemBlocks:%@", path)
        case let .FileSystemFreeBlocks(path):
            String(format: "FileSystemFreeBlocks:%@", path)
        case let .FileSystemAvailableBlocks(path):
            String(format: "FileSystemAvailableBlocks:%@", path)
        case let .FileSystemNodes(path):
            String(format: "FileSystemNodes:%@", path)
        case let .FileSystemFreeNodes(path):
            String(format: "FileSystemFreeNodes:%@", path)
        case let .FileSystemIdentifier(path):
            String(format: "FileSystemIdentifier:%@", path)
        case let .FileSystemOwner(path):
            String(format: "FileSystemOwner:%@", path)
        case let .FileSystemType(path):
            String(format: "FileSystemType:%@", path)
        case let .FileSystemAttributes(path):
            String(format: "FileSystemAttributes:%@", path)
        case let .FileSystemFlavor(path):
            String(format: "FileSystemFlavor:%@", path)
        case let .FileSystemDevice(path):
            String(format: "FileSystemDevice:%@", path)
        case .NetworkInterfaces:
            "NetworkInterfaces"
        case let .InterfaceName(name):
            String(format: "InterfaceName:%@", name)
        case let .InterfaceMacAddress(name):
            String(format: "InterfaceMacAddress:%@", name)
        case let .NetworkAddress(name, index):
            String(format: "NetworkAddress:%@:%d", name, index)
        case let .NetworkBroadcastAddress(name, index):
            String(format: "NetworkBroadcastAddress:%@:%d", name, index)
        case let .NetworkMaskAddress(name, index):
            String(format: "NetworkMaskAddress:%@:%d", name, index)
        case let .NetworkAddressCount(name):
            String(format: "NetworkAddressCount:%@", name)
        case let .InterfaceFlags(name):
            String(format: "InterfaceFlags:%@", name)
        case let .InterfaceMTU(name):
            String(format: "InterfaceMTU:%@", name)
        case let .InterfaceMetric(name):
            String(format: "InterfaceMetric:%@", name)
        case let .InterfaceLineSpeed(name):
            String(format: "InterfaceLineSpeed:%@", name)
        case let .InterfacePacketsReceived(name):
            String(format: "InterfacePacketsReceived:%@", name)
        case let .InterfaceInputErrors(name):
            String(format: "InterfaceInputErrors:%@", name)
        case let .InterfacePacketsSent(name):
            String(format: "InterfacePacketsSent:%@", name)
        case let .InterfaceOutputErrors(name):
            String(format: "InterfaceOutputErrors:%@", name)
        case let .InterfaceCollisions(name):
            String(format: "InterfaceCollisions:%@", name)
        case let .InterfaceBytesReceived(name):
            String(format: "InterfaceBytesReceived:%@", name)
        case let .InterfaceBytesSent(name):
            String(format: "InterfaceBytesSent:%@", name)
        case let .InterfaceMulticastPacketsReceived(name):
            String(format: "InterfaceMulticastPacketsReceived:%@", name)
        case let .InterfaceMulticastPacketsSent(name):
            String(format: "InterfaceMulticastPacketsSent:%@", name)
        case let .InterfacePacketsDropped(name):
            String(format: "InterfacePacketsDropped:%@", name)
        case let .InterfacePacketsUnsupported(name):
            String(format: "InterfacePacketsUnsupported:%@", name)
        case let .InterfaceSpentReceiving(name):
            String(format: "InterfaceSpentReceiving:%@", name)
        case let .InterfaceSpentXmitting(name):
            String(format: "InterfaceSpentXmitting:%@", name)
        case let .InterfaceLastChange(name):
            String(format: "InterfaceLastChange:%@", name)
        case .NetworkUsage:
            "NetworkUsage"
        case let .NetworkCategoryUsage(prefix):
            String(format: "NetworkCategoryUsage:%@", prefix)
        case let .NetworkCategoryBytesDownload(prefix):
            String(format: "NetworkCategoryBytesDownload:%@", prefix)
        case let .NetworkCategoryBytesUpload(prefix):
            String(format: "NetworkCategoryBytesUpload:%@", prefix)
        case .BatteryInformation:
            "BatteryInformation"
        case .BatteryLevel:
            "BatteryLevel"
        case .BatteryUsed:
            "BatteryUsed"
        case .BatteryState:
            "BatteryState"
        case .BatteryCapacity:
            "BatteryCapacity"
        case .BatteryLowPowerMode:
            "BatteryLowPowerMode"
        case let .Custom(name):
            String(format: "Custom:%@", name)
        case let .Section(name):
            String(format: "Section:%@", name)
        case let .AllowedToCopy(name):
            String(format: "AllowedToCopy:%@", name)
        }
    }
}
