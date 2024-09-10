// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import SwiftyJSON

class Configuration {
    var defaultContainer: String
    var description: String
    var dns1: String
    var dns2: String

    var h1: String
    var h2: String
    var h3: String
    var h4: String
    var jc: String
    var jMax: String
    var jMin: String
    var s1: String
    var s2: String
    var clientIp: String
    var clientPrivateKey: String
    var clientPublicKey: String
    var address: String
    var port: String
    var allowedIps: String
    var endPoint: String
    var pskKey: String
    var serverPubKey: String
    var keepALive: String

    init() {
        self.defaultContainer = ""
        self.description = ""
        self.dns1 = ""
        self.dns2 = ""

        self.h1 = ""
        self.h2 = ""
        self.h3 = ""
        self.h4 = ""
        self.jc = ""
        self.jMax = ""
        self.jMin = ""
        self.s1 = ""
        self.s2 = ""
        self.clientIp = ""
        self.clientPrivateKey = ""
        self.clientPublicKey = ""
        self.address = ""
        self.port = ""
        self.allowedIps = ""
        self.endPoint = ""
        self.pskKey = ""
        self.serverPubKey = ""
        self.keepALive = ""
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

            if let awg = decoded["containers"]?.array?.first?.dictionary?["awg"]?.dictionary {
                if let h1 = awg["H1"]?.stringValue {
                    self.h1 = h1
                }
                if let h2 = awg["H2"]?.stringValue {
                    self.h2 = h2
                }
                if let h3 = awg["H3"]?.stringValue {
                    self.h3 = h3
                }
                if let h4 = awg["H4"]?.stringValue {
                    self.h4 = h4
                }
                if let jc = awg["Jc"]?.stringValue {
                    self.jc = jc
                }
                if let jMax = awg["Jmax"]?.stringValue {
                    self.jMax = jMax
                }
                if let jMin = awg["Jmin"]?.stringValue {
                    self.jMin = jMin
                }
                if let s1 = awg["S1"]?.stringValue {
                    self.s1 = s1
                }
                if let s2 = awg["S2"]?.stringValue {
                    self.s2 = s2
                }
                if let port = awg["port"]?.intValue {
                    self.port = "\(port)"
                }
                if let lastConfig = awg["last_config"]?.stringValue {
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
        }
    }

    var parsedData: String {
        var text = ""
        text += "defaultContainer: \(defaultContainer) \n"
        text += "description: \(description) \n"
        text += "dns1: \(dns1) \n"
        text += "dns2: \(dns2) \n"
        text += "h1: \(h1) \n"
        text += "h2: \(h2) \n"
        text += "h3: \(h3) \n"
        text += "h4: \(h4) \n"
        text += "jc: \(jc) \n"
        text += "jMax: \(jMax) \n"
        text += "jMin: \(jMin) \n"
        text += "s1: \(s1) \n"
        text += "s2: \(s2) \n"
        text += "clientIp: \(clientIp) \n"
        text += "clientPrivateKey: \(clientPrivateKey) \n"
        text += "clientPublicKey: \(clientPublicKey) \n"
        text += "address: \(address) \n"
        text += "port: \(port) \n"
        text += "allowedIps: \(allowedIps) \n"
        text += "endPoint: \(endPoint) \n"
        text += "pskKey: \(pskKey) \n"
        text += "serverPubKey: \(serverPubKey) \n"
        text += "keepALive: \(keepALive) \n"

        return text
    }

}
