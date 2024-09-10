// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

class NetworkDataUsage {

    static let shared = NetworkDataUsage()

    private var dataUsage: DataUsageInfo?

    init() { }

    var speedValue: Speed {
        let newDataUsage = DataUsage.getDataUsage()
        guard let dataUsage = self.dataUsage else {
            self.dataUsage = newDataUsage
            return Speed.init()
        }

        let diffBytesWifiReceived = newDataUsage.wifiReceived - dataUsage.wifiReceived
        let diffBytesWirelessReceived = newDataUsage.wirelessWanDataReceived - dataUsage.wirelessWanDataReceived

        let diffBytesWifiSent = newDataUsage.wifiSent - dataUsage.wifiSent
        let diffBytesWirelesSent = newDataUsage.wirelessWanDataSent - dataUsage.wirelessWanDataSent

        let realDiffReceived = Int(diffBytesWifiReceived > 0 ? diffBytesWifiReceived : diffBytesWirelessReceived) * 8
        let realDiffSent = Int(diffBytesWifiSent > 0 ? diffBytesWifiSent : diffBytesWirelesSent) * 8

        self.dataUsage = newDataUsage

//        print("realDiffReceived: \(realDiffReceived)")
//        print("realDiffReceived to text: \((realDiffReceived).descriptionAsDataUnit)")

        return Speed.init(download: realDiffReceived, upload: realDiffSent)
    }

    func reset() {
        self.dataUsage = nil
    }
}

class Speed {
    var download: String = ""
    var upload: String = ""

    init() {
        self.download = 0.descriptionAsDataUnit
        self.upload = 0.descriptionAsDataUnit
    }

    init(download: String, upload: String) {
        self.download = download
        self.upload = upload
    }

    init(download: Int, upload: Int) {
        self.download = download.descriptionAsDataUnit
        self.upload = upload.descriptionAsDataUnit
    }
}

struct DataUsageInfo {
    var wifiReceived: UInt64 = 0
    var wifiSent: UInt64 = 0
    var wirelessWanDataReceived: UInt64 = 0
    var wirelessWanDataSent: UInt64 = 0

    mutating func updateInfoByAdding(info: DataUsageInfo) {
        wifiSent += info.wifiSent
        wifiReceived += info.wifiReceived
        wirelessWanDataSent += info.wirelessWanDataSent
        wirelessWanDataReceived += info.wirelessWanDataReceived
    }
}

class DataUsage {

    private static let wwanInterfacePrefix = "pdp_ip"
    private static let wifiInterfacePrefix = "en"

    class func getDataUsage() -> DataUsageInfo {
        var interfaceAddresses: UnsafeMutablePointer<ifaddrs>? = nil

        var dataUsageInfo = DataUsageInfo()

        guard getifaddrs(&interfaceAddresses) == 0 else { return dataUsageInfo }

        var pointer = interfaceAddresses
        while pointer != nil {
            guard let info = getDataUsageInfo(from: pointer!) else {
                pointer = pointer!.pointee.ifa_next
                continue
            }
            dataUsageInfo.updateInfoByAdding(info: info)
            pointer = pointer!.pointee.ifa_next
        }

        freeifaddrs(interfaceAddresses)

        return dataUsageInfo
    }

    private class func getDataUsageInfo(from infoPointer: UnsafeMutablePointer<ifaddrs>) -> DataUsageInfo? {
        let pointer = infoPointer

        let name: String! = String(cString: infoPointer.pointee.ifa_name)
        let addr = pointer.pointee.ifa_addr.pointee
        guard addr.sa_family == UInt8(AF_LINK) else { return nil }

        return dataUsageInfo(from: pointer, name: name)
    }

    private class func dataUsageInfo(from pointer: UnsafeMutablePointer<ifaddrs>, name: String) -> DataUsageInfo {
        var networkData: UnsafeMutablePointer<if_data>? = nil
        var dataUsageInfo = DataUsageInfo()

        if name.hasPrefix(wifiInterfacePrefix) {
            networkData = unsafeBitCast(pointer.pointee.ifa_data, to: UnsafeMutablePointer<if_data>.self)
            dataUsageInfo.wifiSent += UInt64(networkData?.pointee.ifi_obytes ?? 0)
            dataUsageInfo.wifiReceived += UInt64(networkData?.pointee.ifi_ibytes ?? 0)
        } else if name.hasPrefix(wwanInterfacePrefix) {
            networkData = unsafeBitCast(pointer.pointee.ifa_data, to: UnsafeMutablePointer<if_data>.self)
            dataUsageInfo.wirelessWanDataSent += UInt64(networkData?.pointee.ifi_obytes ?? 0)
            dataUsageInfo.wirelessWanDataReceived += UInt64(networkData?.pointee.ifi_ibytes ?? 0)
        }

        return dataUsageInfo
    }
}
public enum DataUnit: UInt, CustomStringConvertible {
    case byte = 1,
         kilobyte = 1024,
         megabyte = 1048576,
         gigabyte = 1073741824

    fileprivate var showsDecimals: Bool {
        return switch self {
        case .byte, .kilobyte:  true
        case .megabyte, .gigabyte: true
        }
    }

    fileprivate var boundary: UInt {
//        return UInt(0.1 * Double(rawValue))
        return UInt(Double(rawValue))
    }

    // MARK: CustomStringConvertible

    public var description: String {
        return switch self {
        case .byte: "B"
        case .kilobyte: "KB"
        case .megabyte: "MB"
        case .gigabyte: "GB"
        }
    }
}

/// Supports being represented in data unit.
public protocol DataUnitRepresentable {

    /// Returns self expressed in bytes, kB, MB, GB.
    var descriptionAsDataUnit: String { get }
}

extension UInt: DataUnitRepresentable {
    private static let allUnits: [DataUnit] = [
        .gigabyte,
        .megabyte,
        .kilobyte,
        .byte
    ]

    public var descriptionAsDataUnit: String {
        if self == 0 {
            return "0 B/s"
        }
        for u in Self.allUnits {
            if self >= u.boundary {
                if !u.showsDecimals {
                    return "\(self / u.rawValue) \(u)/s"
                }
                let count = Double(self) / Double(u.rawValue)
                return String(format: "%.1f%", count) + " \(u.description)/s"
            }
        }
        fatalError("Number is negative")
    }
}

extension Int: DataUnitRepresentable {
    public var descriptionAsDataUnit: String {
        return UInt(self).descriptionAsDataUnit
    }
}
