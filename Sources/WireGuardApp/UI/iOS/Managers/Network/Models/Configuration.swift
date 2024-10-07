// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import SwiftyJSON

class AwgContainer {
    var h1: String = ""
    var h2: String = ""
    var h3: String = ""
    var h4: String = ""
    var jc: String = ""
    var jMax: String = ""
    var jMin: String = ""
    var s1: String = ""
    var s2: String = ""
    var clientIp: String = ""
    var clientPrivateKey: String = ""
    var clientPublicKey: String = ""
    var address: String = ""
    var port: String = ""
    var allowedIps: String = ""
    var endPoint: String = ""
    var pskKey: String = ""
    var serverPubKey: String = ""
    var keepALive: String = ""

    init() { }

    init(fromDictionary: [String: JSON]) {
        if let h1 = fromDictionary["H1"]?.stringValue {
            self.h1 = h1
        }
        if let h2 = fromDictionary["H2"]?.stringValue {
            self.h2 = h2
        }
        if let h3 = fromDictionary["H3"]?.stringValue {
            self.h3 = h3
        }
        if let h4 = fromDictionary["H4"]?.stringValue {
            self.h4 = h4
        }
        if let jc = fromDictionary["Jc"]?.stringValue {
            self.jc = jc
        }
        if let jMax = fromDictionary["Jmax"]?.stringValue {
            self.jMax = jMax
        }
        if let jMin = fromDictionary["Jmin"]?.stringValue {
            self.jMin = jMin
        }
        if let s1 = fromDictionary["S1"]?.stringValue {
            self.s1 = s1
        }
        if let s2 = fromDictionary["S2"]?.stringValue {
            self.s2 = s2
        }
        if let port = fromDictionary["port"]?.intValue {
            self.port = "\(port)"
        }
        if let lastConfig = fromDictionary["last_config"]?.stringValue {
            let json = JSON.init(parseJSON: lastConfig)
            self.clientIp = json["client_ip"].stringValue
            self.clientPrivateKey = json["client_priv_key"].stringValue
            self.clientPublicKey = json["client_pub_key"].stringValue

            let config = json["config"].stringValue
            let arrayConfig = config.components(separatedBy: "\n")
            arrayConfig.forEach { conf in
                if conf.contains("Address") {
                    self.address = conf.getValueByEqualSymbol
                }
                if conf.contains("AllowedIPs") {
                    let strValue = conf.getValueByEqualSymbol
                    if let allowedIPs = strValue.components(separatedBy: ",").first {
                        self.allowedIps = String(allowedIPs)
                    }
                }
                if conf.contains("Endpoint") {
                    self.endPoint = conf.getValueByEqualSymbol
                }
                if conf.contains("Address") {
                    self.address = conf.getValueByEqualSymbol
                }
                if conf.contains("PresharedKey") {
                    self.pskKey = conf.getValueByEqualSymbol
                }
                if conf.contains("PublicKey") {
                    self.serverPubKey = conf.getValueByEqualSymbol
                }
                if conf.contains("PersistentKeepalive") {
                    self.keepALive = conf.getValueByEqualSymbol
                }
            }
        }
    }

    var parsedData: String {
        var text = "AwgContainer: \n"
        text += "h1: \(self.h1) \n"
        text += "h2: \(self.h2) \n"
        text += "h3: \(self.h3) \n"
        text += "h4: \(self.h4) \n"
        text += "jc: \(self.jc) \n"
        text += "jMax: \(self.jMax) \n"
        text += "jMin: \(self.jMin) \n"
        text += "s1: \(self.s1) \n"
        text += "s2: \(self.s2) \n"
        text += "clientIp: \(self.clientIp) \n"
        text += "clientPrivateKey: \(self.clientPrivateKey) \n"
        text += "clientPublicKey: \(self.clientPublicKey) \n"
        text += "address: \(self.address) \n"
        text += "port: \(self.port) \n"
        text += "allowedIps: \(self.allowedIps) \n"
        text += "endPoint: \(self.endPoint) \n"
        text += "pskKey: \(self.pskKey) \n"
        text += "serverPubKey: \(self.serverPubKey) \n"
        text += "keepALive: \(self.keepALive) \n"
        text += "------\n"
        return text
    }
}

class XRayContainer {
    var port: Int = 0
    var transportProto: String = ""

    var loglevel: String = ""

    var inboundListen: String = ""
    var inboundPort: Int = 0
    var inboundProtocol: String = ""
    var inboundUdp = false

    var outboundProtocol = ""
    var outboundAddress = ""
    var outboundPort: Int = 0
    var outboundUserId = ""
    var outboundFlow = ""
    var outboundEncryption = ""

    var outboundNetwork = ""
    var outboundSecurity = ""
    var outboundFingerprint = ""
    var outboundServername = ""
    var outboundPublicKey = ""
    var outboundShortId = ""
    var outboundSpiderX = ""

    init() { }

    init(fromDictionary: [String: JSON]) {
        if let port = fromDictionary["port"]?.intValue {
            self.port = port
        }
        if let transportProto = fromDictionary["transport_proto"]?.stringValue {
            self.transportProto = transportProto
        }

        if let lastConfig = fromDictionary["last_config"]?.stringValue {
            let json = JSON.init(parseJSON: lastConfig)

            if let log = json["log"].dictionary, let logLevel = log["loglevel"]?.stringValue {
                self.loglevel = logLevel
            }

            if let inbounds = json["inbounds"].array, let inbound = inbounds.first {
                self.inboundListen = inbound["listen"].stringValue
                self.inboundPort = inbound["port"].intValue
                self.inboundProtocol = inbound["protocol"].stringValue
                if let settings = inbound["settings"].dictionary, let inboundUdp = settings["udp"]?.boolValue {
                    self.inboundUdp = inboundUdp
                }
            }
            if let outbounds = json["outbounds"].array, let outbound = outbounds.first {
                self.outboundProtocol = outbound["protocol"].stringValue
                if let settings = outbound["settings"].dictionary, let vnext = settings["vnext"]?.array, let vnextFirst = vnext.first {
                    self.outboundAddress = vnextFirst["address"].stringValue
                    self.outboundPort = vnextFirst["port"].intValue
                    if let users = vnextFirst["users"].array, let usersFirst = users.first {
                        self.outboundUserId = usersFirst["id"].stringValue
                        self.outboundFlow = usersFirst["flow"].stringValue
                        self.outboundEncryption = usersFirst["encryption"].stringValue
                    }
                }

                if let streamSettings = outbound["streamSettings"].dictionary {
                    if let outboundNetwork = streamSettings["network"]?.stringValue {
                        self.outboundNetwork = outboundNetwork
                    }
                    if let outboundSecurity = streamSettings["security"]?.stringValue {
                        self.outboundSecurity = outboundSecurity
                    }
                    if let realitySettings = streamSettings["realitySettings"]?.dictionary {
                        if let outboundFingerprint = realitySettings["fingerprint"]?.stringValue {
                            self.outboundFingerprint = outboundFingerprint
                        }
                        if let outboundServername = realitySettings["serverName"]?.stringValue {
                            self.outboundServername = outboundServername
                        }
                        if let outboundPublicKey = realitySettings["publicKey"]?.stringValue {
                            self.outboundPublicKey = outboundPublicKey
                        }
                        if let outboundShortId = realitySettings["shortId"]?.stringValue {
                            self.outboundShortId = outboundShortId
                        }
                        if let outboundSpiderX = realitySettings["spiderX"]?.stringValue {
                            self.outboundSpiderX = outboundSpiderX
                        }
                    }
                }
            }
        }
    }

    var parsedData: String {
        var text = "XRayContainer: \n"
        text += "port: \(self.port) \n"
        text += "transportProto: \(self.transportProto) \n"
        text += "loglevel: \(self.loglevel) \n"
        text += "inboundListen: \(self.inboundListen) \n"
        text += "inboundPort: \(self.inboundPort) \n"
        text += "inboundProtocol: \(self.inboundProtocol) \n"
        text += "inboundUdp: \(self.inboundUdp) \n"

        text += "outboundProtocol: \(self.outboundProtocol) \n"
        text += "outboundAddress: \(self.outboundAddress) \n"
        text += "outboundPort: \(self.outboundPort) \n"
        text += "outboundUserId: \(self.outboundUserId) \n"
        text += "outboundFlow: \(self.outboundFlow) \n"
        text += "outboundEncryption: \(self.outboundEncryption) \n"

        text += "outboundNetwork: \(self.outboundNetwork) \n"
        text += "outboundSecurity: \(self.outboundSecurity) \n"
        text += "outboundFingerprint: \(self.outboundFingerprint) \n"
        text += "outboundServername: \(self.outboundServername) \n"
        text += "outboundPublicKey: \(self.outboundPublicKey) \n"
        text += "outboundShortId: \(self.outboundShortId) \n"
        text += "outboundSpiderX: \(self.outboundSpiderX) \n"
        text += "------\n"
        return text
    }
}

class Configuration {
    var defaultContainer: String
    var description: String
    var dns1: String
    var dns2: String

    var awgContainer: AwgContainer
    var xRayContainer: XRayContainer

    init() {
        self.defaultContainer = ""
        self.description = ""
        self.dns1 = ""
        self.dns2 = ""

        self.awgContainer = AwgContainer()
        self.xRayContainer = XRayContainer()
    }

    convenience init(fromJson: JSON) {
        self.init()
        if let decoded = fromJson["decoded"].dictionary {
            if let defaultContainer = decoded["defaultContainer"]?.stringValue {
                self.defaultContainer =  defaultContainer
            }
            if let description = decoded["description"]?.stringValue {
                self.description = description
            }
            if let dns1 = decoded["dns1"]?.stringValue {
                self.dns1 = dns1
            }
            if let dns2 = decoded["dns2"]?.stringValue {
                self.dns2 = dns2
            }

            if let containers = decoded["containers"]?.array {
                for container in containers {
                    if let awgDict = container["awg"].dictionary {
                        self.awgContainer = AwgContainer(fromDictionary: awgDict)
                    }
                    if let xRayDict = container["xray"].dictionary {
                        self.xRayContainer = XRayContainer(fromDictionary: xRayDict)
                    }
                }
            }
        }
    }

    var parsedData: String {
        var text = ""
        text += "defaultContainer: \(defaultContainer) \n"
        text += "description: \(description) \n"
        text += "dns1: \(dns1) \n"
        text += "dns2: \(dns2) \n"
        text += self.awgContainer.parsedData
        text += self.xRayContainer.parsedData
        return text
    }

}
