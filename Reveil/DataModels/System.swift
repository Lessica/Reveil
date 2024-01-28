//
// System.swift
// SystemKit
//
// The MIT License
//
// Copyright (C) 2014-2017  beltex <https://github.com/beltex>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Darwin
import Darwin.POSIX
import Foundation

// ------------------------------------------------------------------------------

// MARK: PRIVATE PROPERTIES

// ------------------------------------------------------------------------------

// As defined in <mach/tash_info.h>

private let HOST_BASIC_INFO_COUNT: mach_msg_type_number_t =
    UInt32(MemoryLayout<host_basic_info_data_t>.size / MemoryLayout<integer_t>.size)
private let HOST_LOAD_INFO_COUNT: mach_msg_type_number_t =
    UInt32(MemoryLayout<host_load_info_data_t>.size / MemoryLayout<integer_t>.size)
private let HOST_CPU_LOAD_INFO_COUNT: mach_msg_type_number_t =
    UInt32(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)
private let HOST_VM_INFO64_COUNT: mach_msg_type_number_t =
    UInt32(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
private let HOST_SCHED_INFO_COUNT: mach_msg_type_number_t =
    UInt32(MemoryLayout<host_sched_info_data_t>.size / MemoryLayout<integer_t>.size)
private let PROCESSOR_BASIC_INFO_COUNT: mach_msg_type_number_t =
    UInt32(MemoryLayout<processor_basic_info_data_t>.size / MemoryLayout<integer_t>.size)
private let PROCESSOR_SET_LOAD_INFO_COUNT: mach_msg_type_number_t =
    UInt32(MemoryLayout<processor_set_load_info_data_t>.size / MemoryLayout<natural_t>.size)

struct System {
    // --------------------------------------------------------------------------

    // MARK: PUBLIC PROPERTIES

    // --------------------------------------------------------------------------

    /**
     System page size.

     - Can check this via pagesize shell command as well
     - C lib function getpagesize()
     - host_page_size()

     TODO: This should be static right?
     */
    static let PAGE_SIZE = vm_page_size
    static let KERNEL_PAGE_SIZE = vm_kernel_page_size
    typealias CPUUsage = (system: Double, user: Double, idle: Double, nice: Double)

    // --------------------------------------------------------------------------

    // MARK: PUBLIC ENUMS

    // --------------------------------------------------------------------------

    /**
     Unit options for method data returns.

     TODO: Pages?
     */
    enum Unit: Double {
        // For going from byte to -
        case byte = 1
        case kilobyte = 1024
        case megabyte = 1_048_576
        case gigabyte = 1_073_741_824
    }

    /// Options for loadAverage()
    enum LOAD_AVG {
        /// 5, 30, 60 second samples
        case short

        /// 1, 5, 15 minute samples
        case long
    }

    /// For thermalLevel()
    enum ThermalLevel: String {
        // Comments via <IOKit/pwr_mgt/IOPM.h>

        /// Under normal operating conditions
        case Normal
        /// Thermal pressure may cause system slowdown
        case Danger
        /// Thermal conditions may cause imminent shutdown
        case Crisis
        /// Thermal warning level has not been published
        case NotPublished = "Not Published"
        /// The platform may define additional thermal levels if necessary
        case Unknown
    }

    // --------------------------------------------------------------------------

    // MARK: PRIVATE PROPERTIES

    // --------------------------------------------------------------------------

    fileprivate static let machHost = mach_host_self()
    private var loadPrevious = host_cpu_load_info()
    private var timePrevious = clock_gettime_nsec_np(CLOCK_UPTIME_RAW)
    private var cpuUsagePrevious = CPUUsage(system: 0, user: 0, idle: 0, nice: 0)

    // --------------------------------------------------------------------------

    // MARK: PUBLIC INITIALIZERS

    // --------------------------------------------------------------------------

    init() {}

    // --------------------------------------------------------------------------

    // MARK: PUBLIC METHODS

    // --------------------------------------------------------------------------

    /**
     Get CPU usage (system, user, idle, nice). Determined by the delta between
     the current and last call. Thus, first call will always be inaccurate.
     */
    mutating func cpuUsage() -> CPUUsage {
        let now = clock_gettime_nsec_np(CLOCK_UPTIME_RAW)
        if now - timePrevious < NSEC_PER_MSEC {
            return cpuUsagePrevious
        }

        let load = System.hostCPULoadInfo()

        let userDiff = load.cpu_ticks.0 - loadPrevious.cpu_ticks.0
        let sysDiff = load.cpu_ticks.1 - loadPrevious.cpu_ticks.1
        let idleDiff = load.cpu_ticks.2 - loadPrevious.cpu_ticks.2
        let niceDiff = load.cpu_ticks.3 - loadPrevious.cpu_ticks.3

        let totalTicks = sysDiff + userDiff + niceDiff + idleDiff
        if totalTicks == 0 {
            return cpuUsagePrevious
        }

        let totalTicksDouble = Double(totalTicks)

        let sys = Double(sysDiff) / totalTicksDouble
        let user = Double(userDiff) / totalTicksDouble
        let idle = Double(idleDiff) / totalTicksDouble
        let nice = Double(niceDiff) / totalTicksDouble

        loadPrevious = load
        timePrevious = now
        cpuUsagePrevious = (sys, user, idle, nice)

        return cpuUsagePrevious
    }

    // --------------------------------------------------------------------------

    // MARK: PUBLIC STATIC METHODS

    // --------------------------------------------------------------------------

    /// Get the model name of this machine. Same as "sysctl hw.model"
    static func modelName() -> String {
        let name: String
        var mib = [CTL_HW, HW_MODEL]

        // Max model name size not defined by sysctl. Instead we use io_name_t
        // via I/O Kit which can also get the model name
        var size = MemoryLayout<io_name_t>.size

        let ptr = UnsafeMutablePointer<io_name_t>.allocate(capacity: 1)
        let result = sysctl(&mib, u_int(mib.count), ptr, &size, nil, 0)

        if result == 0 { name = String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self)) }
        else { name = String() }

        ptr.deallocate()

        #if DEBUG
            if result != 0 {
                print("ERROR - \(#file):\(#function) - errno = "
                    + "\(result)")
            }
        #endif

        return name
    }

    /**
     sysname       Name of the operating system implementation.
     nodename      Network name of this machine.
     release       Release level of the operating system.
     version       Version level of the operating system.
     machine       Machine hardware platform.

     Via uname(3) manual page.
     */
    static func uname() -> (sysname: String,
                            nodename: String,
                            release: String,
                            version: String,
                            machine: String)
    {
        var systemInfo = utsname()
        let result = Darwin.uname(&systemInfo)

        repeat {
            guard result == 0 else {
                break
            }

            guard let sysname = withUnsafePointer(to: &systemInfo.sysname, {
                $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                    ptr in String(validatingUTF8: ptr)
                }
            }) else {
                break
            }

            guard let nodename = withUnsafePointer(to: &systemInfo.nodename, {
                $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                    ptr in String(validatingUTF8: ptr)
                }
            }) else {
                break
            }

            guard let release = withUnsafePointer(to: &systemInfo.release, {
                $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                    ptr in String(validatingUTF8: ptr)
                }
            }) else {
                break
            }

            guard let version = withUnsafePointer(to: &systemInfo.version, {
                $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                    ptr in String(validatingUTF8: ptr)
                }
            }) else {
                break
            }

            guard let machine = withUnsafePointer(to: &systemInfo.machine, {
                $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                    ptr in String(validatingUTF8: ptr)
                }
            }) else {
                break
            }

            return (sysname, nodename, release, version, machine)
        } while false

        return ("", "", "", "", "")
    }

    /// Number of physical cores on this machine.
    static func physicalCores() -> Int {
        Int(System.hostBasicInfo().physical_cpu)
    }

    /**
     Number of logical cores on this machine. Will be equal to physicalCores()
     unless it has hyper-threading, in which case it will be double.

     https://en.wikipedia.org/wiki/Hyper-threading
     */
    static func logicalCores() -> Int {
        Int(System.hostBasicInfo().logical_cpu)
    }

    /**
     System load average at 3 intervals.

     "Measures the average number of threads in the run queue."

     - via hostinfo manual page

     https://en.wikipedia.org/wiki/Load_(computing)
     */
    static func loadAverage(_ type: LOAD_AVG = .long) -> [Double] {
        var avg = [Double](repeating: 0, count: 3)

        switch type {
        case .short:
            let result = System.hostLoadInfo().avenrun
            avg = [Double(result.0) / Double(LOAD_SCALE),
                   Double(result.1) / Double(LOAD_SCALE),
                   Double(result.2) / Double(LOAD_SCALE)]
        case .long:
            getloadavg(&avg, 3)
        }

        return avg
    }

    /**
     System mach factor at 3 intervals.

     "A variant of the load average which measures the processing resources
     available to a new thread. Mach factor is based on the number of CPUs
     divided by (1 + the number of runnablethreads) or the number of CPUs minus
     the number of runnable threads when the number of runnable threads is less
     than the number of CPUs. The closer the Mach factor value is to zero, the
     higher the load. On an idle system with a fixed number of active processors,
     the mach factor will be equal to the number of CPUs."

     - via hostinfo manual page
     */
    static func machFactor() -> [Double] {
        let result = System.hostLoadInfo().mach_factor

        return [Double(result.0) / Double(LOAD_SCALE),
                Double(result.1) / Double(LOAD_SCALE),
                Double(result.2) / Double(LOAD_SCALE)]
    }

    /// Total number of processes & threads
    static func processCounts() -> (processCount: Int, threadCount: Int) {
        let data = System.processorLoadInfo()
        return (Int(data.task_count), Int(data.thread_count))
    }

    /// Size of physical memory on this machine
    static func physicalMemory(_ unit: Unit = .gigabyte) -> Double {
        Double(System.hostBasicInfo().max_mem) / unit.rawValue
    }

    /**
     System memory usage (free, active, inactive, wired, compressed).
     */
    static func memoryUsage() -> (free: Double,
                                  active: Double,
                                  inactive: Double,
                                  wired: Double,
                                  purgeable: Double,
                                  compressed: Double)
    {
        let stats = System.VMStatistics64()

        let free = Double(stats.free_count) * Double(PAGE_SIZE) / Unit.gigabyte.rawValue
        let active = Double(stats.active_count) * Double(PAGE_SIZE) / Unit.gigabyte.rawValue
        let inactive = Double(stats.inactive_count) * Double(PAGE_SIZE) / Unit.gigabyte.rawValue
        let wired = Double(stats.wire_count) * Double(PAGE_SIZE) / Unit.gigabyte.rawValue
        let purgeable = Double(stats.purgeable_count) * Double(PAGE_SIZE) / Unit.gigabyte.rawValue

        // Result of the compression. This is what you see in Activity Monitor
        let compressed = Double(stats.compressor_page_count) * Double(PAGE_SIZE) / Unit.gigabyte.rawValue

        return (free, active, inactive, wired, purgeable, compressed)
    }

    static func kernelMaximumVnodes() -> Int32 {
        var maxVnodes: Int32 = 0
        var mib = [CTL_KERN, KERN_MAXVNODES]
        var size = MemoryLayout<Int32>.stride
        let result = sysctl(&mib, u_int(mib.count), &maxVnodes, &size, nil, 0)

        if result != 0 {
            #if DEBUG
                print("ERROR - \(#file):\(#function) - errno = " + "\(result)")
            #endif

            return 0
        }

        return maxVnodes
    }

    static func kernelMaximumFilesPerProc() -> Int32 {
        var maxFiles: Int32 = 0
        var mib = [CTL_KERN, KERN_MAXFILESPERPROC]
        var size = MemoryLayout<Int32>.stride
        let result = sysctl(&mib, u_int(mib.count), &maxFiles, &size, nil, 0)

        if result != 0 {
            #if DEBUG
                print("ERROR - \(#file):\(#function) - errno = " + "\(result)")
            #endif

            return 0
        }

        return maxFiles
    }

    static func kernelMaximumProcesses() -> Int32 {
        var maxProcs: Int32 = 0
        var mib = [CTL_KERN, KERN_MAXPROC]
        var size = MemoryLayout<Int32>.stride
        let result = sysctl(&mib, u_int(mib.count), &maxProcs, &size, nil, 0)

        if result != 0 {
            #if DEBUG
                print("ERROR - \(#file):\(#function) - errno = " + "\(result)")
            #endif

            return 0
        }

        return maxProcs
    }

    static func kernelHostID() -> Int32 {
        var hostID: Int32 = 0
        var mib = [CTL_KERN, KERN_HOSTID]
        var size = MemoryLayout<Int32>.stride
        let result = sysctl(&mib, u_int(mib.count), &hostID, &size, nil, 0)

        if result != 0 {
            #if DEBUG
                print("ERROR - \(#file):\(#function) - errno = " + "\(result)")
            #endif

            return 0
        }

        return hostID
    }

    static func kernelMaximumSocketBufferSize() -> Int32 {
        var maxSockBuf: Int32 = 0
        var mib = [CTL_KERN, KERN_IPC, KIPC_MAXSOCKBUF]
        var size = MemoryLayout<Int32>.stride
        let result = sysctl(&mib, u_int(mib.count), &maxSockBuf, &size, nil, 0)

        if result != 0 {
            #if DEBUG
                print("ERROR - \(#file):\(#function) - errno = " + "\(result)")
            #endif

            return 0
        }

        return maxSockBuf
    }

    static func hardwareCPUFamily() -> UInt32 {
        var cpuFamily: UInt32 = 0
        var size = MemoryLayout<UInt32>.stride

        let result = sysctlbyname("hw.cpufamily", &cpuFamily, &size, nil, 0)
        if result != 0 {
            #if DEBUG
                print("ERROR - \(#file):\(#function) - errno = " + "\(result)")
            #endif

            return 0
        }

        return cpuFamily
    }

    static func hardwareCPUSubFamily() -> Int32 {
        var cpuSubFamily: Int32 = 0
        var size = MemoryLayout<Int32>.stride

        let result = sysctlbyname("hw.cpusubfamily", &cpuSubFamily, &size, nil, 0)
        if result != 0 {
            #if DEBUG
                print("ERROR - \(#file):\(#function) - errno = " + "\(result)")
            #endif

            return 0
        }

        return cpuSubFamily
    }

    static func hardwareCacheLineSize() -> Int32 {
        var lineSize: Int32 = 0
        var mib = [CTL_HW, HW_CACHELINE]
        var size = MemoryLayout<Int32>.stride
        let result = sysctl(&mib, u_int(mib.count), &lineSize, &size, nil, 0)

        if result != 0 {
            #if DEBUG
                print("ERROR - \(#file):\(#function) - errno = " + "\(result)")
            #endif

            return 0
        }

        return lineSize
    }

    static func hardwareLevel1InstructionCacheSize() -> Int32 {
        var cacheSize: Int32 = 0
        var mib = [CTL_HW, HW_L1ICACHESIZE]
        var size = MemoryLayout<Int32>.stride
        let result = sysctl(&mib, u_int(mib.count), &cacheSize, &size, nil, 0)

        if result != 0 {
            #if DEBUG
                print("ERROR - \(#file):\(#function) - errno = " + "\(result)")
            #endif

            return 0
        }

        return cacheSize
    }

    static func hardwareLevel1DataCacheSize() -> Int32 {
        var cacheSize: Int32 = 0
        var mib = [CTL_HW, HW_L1DCACHESIZE]
        var size = MemoryLayout<Int32>.stride
        let result = sysctl(&mib, u_int(mib.count), &cacheSize, &size, nil, 0)

        if result != 0 {
            #if DEBUG
                print("ERROR - \(#file):\(#function) - errno = " + "\(result)")
            #endif

            return 0
        }

        return cacheSize
    }

    static func hardwareLevel2CacheSize() -> Int32 {
        var cacheSize: Int32 = 0
        var mib = [CTL_HW, HW_L2CACHESIZE]
        var size = MemoryLayout<Int32>.stride
        let result = sysctl(&mib, u_int(mib.count), &cacheSize, &size, nil, 0)

        if result != 0 {
            #if DEBUG
                print("ERROR - \(#file):\(#function) - errno = " + "\(result)")
            #endif

            return 0
        }

        return cacheSize
    }

    static func hardwareTBFrequency() -> Int32 {
        var tbFreq: Int32 = 0
        var mib = [CTL_HW, HW_TB_FREQ]
        var size = MemoryLayout<Int32>.stride
        let result = sysctl(&mib, u_int(mib.count), &tbFreq, &size, nil, 0)

        if result != 0 {
            #if DEBUG
                print("ERROR - \(#file):\(#function) - errno = " + "\(result)")
            #endif

            return 0
        }

        return tbFreq
    }

    static func hardwareLevel3CacheSize() -> Int32 {
        var cacheSize: Int32 = 0
        var mib = [CTL_HW, HW_L3CACHESIZE]
        var size = MemoryLayout<Int32>.stride
        let result = sysctl(&mib, u_int(mib.count), &cacheSize, &size, nil, 0)

        if result != 0 {
            #if DEBUG
                print("ERROR - \(#file):\(#function) - errno = " + "\(result)")
            #endif

            return 0
        }

        return cacheSize
    }

    static func hardwareMemorySize() -> UInt64 {
        var userMem: UInt64 = 0
        var mib = [CTL_HW, HW_MEMSIZE]
        var size = MemoryLayout<UInt64>.stride
        let result = sysctl(&mib, u_int(mib.count), &userMem, &size, nil, 0)

        if result != 0 {
            #if DEBUG
                print("ERROR - \(#file):\(#function) - errno = " + "\(result)")
            #endif

            return 0
        }

        return userMem
    }

    /// How long has the system been up?
    static func uptime() -> (absolute: Int, days: Int, hrs: Int, mins: Int, secs: Int) {
        var currentTime = time_t()
        var bootTime = timeval()
        var mib = [CTL_KERN, KERN_BOOTTIME]

        // NOTE: Use strideof(), NOT sizeof() to account for data structure
        // alignment (padding)
        // http://stackoverflow.com/a/27640066
        // https://devforums.apple.com/message/1086617#1086617
        var size = MemoryLayout<timeval>.stride

        let result = sysctl(&mib, u_int(mib.count), &bootTime, &size, nil, 0)

        if result != 0 {
            #if DEBUG
                print("ERROR - \(#file):\(#function) - errno = " + "\(result)")
            #endif

            return (0, 0, 0, 0, 0)
        }

        // Since we don't need anything more than second level accuracy, we use
        // time() rather than say gettimeofday(), or something else. uptime
        // command does the same
        time(&currentTime)

        var uptime = currentTime - bootTime.tv_sec

        let days = uptime / 86400 // Number of seconds in a day
        uptime %= 86400

        let hrs = uptime / 3600 // Number of seconds in a hour
        uptime %= 3600

        let mins = uptime / 60
        let secs = uptime % 60

        return (bootTime.tv_sec, days, hrs, mins, secs)
    }

    // --------------------------------------------------------------------------

    // MARK: PRIVATE METHODS

    // --------------------------------------------------------------------------

    static func hostBasicInfo() -> host_basic_info {
        // TODO: Why is host_basic_info.max_mem val different from sysctl?

        var size = HOST_BASIC_INFO_COUNT
        let hostInfo = host_basic_info_t.allocate(capacity: 1)

        let result = hostInfo.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
            host_info(machHost, HOST_BASIC_INFO, $0, &size)
        }

        let data = hostInfo.move()
        hostInfo.deallocate()

        #if DEBUG
            if result != KERN_SUCCESS {
                print("ERROR - \(#file):\(#function) - kern_result_t = " + "\(result)")
            }
        #endif

        return data
    }

    static func hostLoadInfo() -> host_load_info {
        var size = HOST_LOAD_INFO_COUNT
        let hostInfo = host_load_info_t.allocate(capacity: 1)

        let result = hostInfo.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
            host_statistics(machHost, HOST_LOAD_INFO,
                            $0,
                            &size)
        }

        let data = hostInfo.move()
        hostInfo.deallocate()

        #if DEBUG
            if result != KERN_SUCCESS {
                print("ERROR - \(#file):\(#function) - kern_result_t = " + "\(result)")
            }
        #endif

        return data
    }

    static func hostCPULoadInfo() -> host_cpu_load_info {
        var size = HOST_CPU_LOAD_INFO_COUNT
        let hostInfo = host_cpu_load_info_t.allocate(capacity: 1)

        let result = hostInfo.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
            host_statistics(machHost, HOST_CPU_LOAD_INFO, $0, &size)
        }

        let data = hostInfo.move()
        hostInfo.deallocate()

        #if DEBUG
            if result != KERN_SUCCESS {
                print("ERROR - \(#file):\(#function) - kern_result_t = " + "\(result)")
            }
        #endif

        return data
    }

    static func processorLoadInfo() -> processor_set_load_info {
        // NOTE: Duplicate load average and mach factor here

        var pset = processor_set_name_t()
        var result = processor_set_default(machHost, &pset)

        if result != KERN_SUCCESS {
            #if DEBUG
                print("ERROR - \(#file):\(#function) - kern_result_t = " + "\(result)")
            #endif

            return processor_set_load_info()
        }

        var count = PROCESSOR_SET_LOAD_INFO_COUNT
        let info_out = processor_set_load_info_t.allocate(capacity: 1)

        result = info_out.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
            processor_set_statistics(pset,
                                     PROCESSOR_SET_LOAD_INFO,
                                     $0,
                                     &count)
        }

        #if DEBUG
            if result != KERN_SUCCESS {
                print("ERROR - \(#file):\(#function) - kern_result_t = " + "\(result)")
            }
        #endif

        // This is isn't mandatory as I understand it, just helps keep the ref
        // count correct. This is because the port is to the default processor
        // set which should exist by default as long as the machine is running
        mach_port_deallocate(mach_task_self_, pset)

        let data = info_out.move()
        info_out.deallocate()

        return data
    }

    /**
     64-bit virtual memory statistics. This should apply to all Mac's that run
     10.9 and above. For iOS, iPhone 5S, iPad Air & iPad Mini 2 and on.

     Swift runs on 10.9 and above, and 10.9 is x86_64 only. On iOS though its 7
     and above, with both ARM & ARM64.
     */
    static func VMStatistics64() -> vm_statistics64 {
        var size = HOST_VM_INFO64_COUNT
        let hostInfo = vm_statistics64_t.allocate(capacity: 1)

        let result = hostInfo.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
            host_statistics64(machHost,
                              HOST_VM_INFO64,
                              $0,
                              &size)
        }

        let data = hostInfo.move()
        hostInfo.deallocate()

        #if DEBUG
            if result != KERN_SUCCESS {
                print("ERROR - \(#file):\(#function) - kern_result_t = " + "\(result)")
            }
        #endif

        return data
    }

    static func mountedVolumes() -> [statfs] {
        var vols: [statfs] = []
        var ptr: UnsafeMutablePointer<statfs>?
        let cnt = getmntinfo(&ptr, MNT_WAIT)
        guard let ptr, cnt > 0 else {
            return []
        }
        for i in 0 ..< Int(cnt) {
            ptr.advanced(by: i).withMemoryRebound(to: statfs.self, capacity: 1) { pointer in
                vols.append(pointer.pointee)
            }
        }
        return vols
    }

    static func mountedVolume(url: URL) -> statfs? {
        var value = statfs()
        let result = statfs(url.path, &value)
        guard result == 0 else {
            return nil
        }
        return value
    }

    static func userName(uid: uid_t) -> String? {
        guard let passwd = getpwuid(uid) else {
            return nil
        }
        return String(cString: passwd.pointee.pw_name)
    }

    static func interfaceAddresses() -> [ifaddrs_safe] {
        var result: [ifaddrs_safe] = []
        var addrsPointer: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&addrsPointer) == 0 else {
            return []
        }
        var pointer = addrsPointer
        while pointer != nil {
            guard let addrs = pointer?.pointee else {
                break
            }
            result.append(ifaddrs_safe(addrs: addrs))
            pointer = addrs.ifa_next
        }
        freeifaddrs(addrsPointer)
        return result
    }

    static func interfaceAddresses(name: String) -> [ifaddrs_safe] {
        interfaceAddresses().filter { $0.ifa_name == name }
    }

    // will return localhost after iOS 17
    static func hostName() -> String? {
        let ptr = UnsafeMutablePointer<CChar>.allocate(capacity: Int(MAXHOSTNAMELEN))
        let ret = gethostname(ptr, Int(MAXHOSTNAMELEN))
        var name: String?
        if ret == 0 {
            name = String(cString: ptr)
        }
        ptr.deallocate()
        return name
    }

    static func getAllThreadInfo() -> [ThreadInfo] {
        var thread_list: thread_act_array_t?
        var thread_count = mach_msg_type_number_t()
        defer {
            if let thread_list {
                vm_deallocate(mach_task_self_, vm_address_t(bitPattern: thread_list), vm_size_t(Int(thread_count) * MemoryLayout<thread_t>.stride))
            }
        }

        let err = task_threads(mach_task_self_, &thread_list, &thread_count)
        guard err == KERN_SUCCESS, let thread_list else {
            return []
        }

        var basicInfoArray = [ThreadInfo]()
        for j in 0 ..< Int(thread_count) {
            var thread_info_count: mach_msg_type_number_t
            let thread_info_obj = thread_info_t.allocate(capacity: Int(THREAD_INFO_MAX))
            defer {
                thread_info_obj.deallocate()
            }

            let thread_id = thread_list[j]
            var kr: kern_return_t

            thread_info_count = mach_msg_type_number_t(THREAD_INFO_MAX)
            kr = thread_info(thread_id, thread_flavor_t(THREAD_BASIC_INFO), thread_info_obj, &thread_info_count)
            guard kr == KERN_SUCCESS else {
                continue
            }

            let thread_basic_info_obj = thread_info_obj.withMemoryRebound(to: thread_basic_info.self, capacity: 1) { pointer in
                pointer.pointee
            }

            thread_info_count = mach_msg_type_number_t(THREAD_INFO_MAX)
            kr = thread_info(thread_id, thread_flavor_t(THREAD_IDENTIFIER_INFO), thread_info_obj, &thread_info_count)
            guard kr == KERN_SUCCESS else {
                continue
            }

            let thread_identifier_info_obj = thread_info_obj.withMemoryRebound(to: thread_identifier_info.self, capacity: 1) { pointer in
                pointer.pointee
            }

            thread_info_count = mach_msg_type_number_t(THREAD_INFO_MAX)
            kr = thread_info(thread_id, thread_flavor_t(THREAD_EXTENDED_INFO), thread_info_obj, &thread_info_count)
            guard kr == KERN_SUCCESS else {
                continue
            }

            let thread_extended_info_obj = thread_info_obj.withMemoryRebound(to: thread_extended_info.self, capacity: 1) { pointer in
                pointer.pointee
            }

            let pth_name = thread_extended_info_obj.pth_name
            let thread_label = withUnsafePointer(to: pth_name) { ptr in
                ptr.withMemoryRebound(to: CChar.self, capacity: MemoryLayout.size(ofValue: ptr)) { pointer in
                    let buffer = UnsafeBufferPointer(start: pointer, count: Mirror(reflecting: pth_name).children.count)
                    return String(cString: buffer.map { $0 })
                }
            }

            basicInfoArray.append(ThreadInfo(
                label: thread_label,
                basic: thread_basic_info_obj,
                identifier: thread_identifier_info_obj,
                extended: thread_extended_info_obj
            ))
        }

        return basicInfoArray
    }
}
