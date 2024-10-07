// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import Foundation
import Alamofire

protocol ConnectionDelegate: AnyObject {
    func connectionStatusChanged(state: ConnectionState)
    func changedSpeed(download: Double, upload: Double)
    func error(text: String)
    func changeConnectedDate(date: Date)
}

class Connection {

    static let shared = Connection()

    init() { }

    weak var delegate: ConnectionDelegate?

    private var tunnelsManager: TunnelsManager?
    private var tunnel: TunnelContainer?

//    private var addresses = ["x.com", "yandex.ru", "instagram.com", "google.com", "app.vpnhero.am"]
    private var addresses = ["instagram.com", "google.com", "app.vpnhero.am"]
    private var statusRequests: Int = 0
    private var finishedRequest: Int = 0
    private var indexChecking = 0

    func refreshTunnelConnectionStatuses() {
        if let tunnelsManager = tunnelsManager {
            tunnelsManager.refreshStatuses()
        }
    }

    func changeConnection(isOn: Bool) {
        guard let tunnelsManager = self.tunnelsManager else {
            return
        }
        guard let tunnel = tunnel else {
            NotificationCenter.default.post(name: .needGetConfiguration, object: nil)
            return
        }
        tunnel.onDeactivated = {
            self.delegate?.connectionStatusChanged(state: .disconnected)
        }

        if tunnel.hasOnDemandRules {
            tunnelsManager.setOnDemandEnabled(isOn, on: tunnel) { error in
                tunnelsManager.startDeactivation(of: tunnel)
            }
        } else {
            if isOn {
                tunnelsManager.startActivation(of: tunnel)
            } else {
                tunnelsManager.startDeactivation(of: tunnel)
            }
        }
    }

    func changeConfiguration(conf: Configuration) {

        guard let privateKey = PrivateKey(base64Key: conf.awgContainer.clientPrivateKey) else {
            print("error private key")
            return
        }
        var interfaceConfig = InterfaceConfiguration(privateKey: privateKey)

        if let addressRange = IPAddressRange(from: conf.awgContainer.address) {
            interfaceConfig.addresses = [addressRange]
        }
        interfaceConfig.listenPort = UInt16(conf.awgContainer.port)

        var dnsServers: [DNSServer] = []
        var dnsSearch: [String] = []
        if let dns1 = DNSServer(from: conf.dns1) {
            dnsServers.append(dns1)
        } else {
            dnsSearch.append(conf.dns1)
        }
        if let dns2 = DNSServer(from: conf.dns2) {
            dnsServers.append(dns2)
        } else {
            dnsSearch.append(conf.dns2)
        }
        interfaceConfig.dns = dnsServers
        interfaceConfig.dnsSearch = dnsSearch

        interfaceConfig.junkPacketCount = UInt16(conf.awgContainer.jc)
        interfaceConfig.junkPacketMinSize = UInt16(conf.awgContainer.jMin)
        interfaceConfig.junkPacketMaxSize = UInt16(conf.awgContainer.jMax)

        interfaceConfig.initPacketJunkSize = UInt16(conf.awgContainer.s1)
        interfaceConfig.responsePacketJunkSize = UInt16(conf.awgContainer.s2)

        interfaceConfig.initPacketMagicHeader = UInt32(conf.awgContainer.h1)
        interfaceConfig.responsePacketMagicHeader = UInt32(conf.awgContainer.h2)
        interfaceConfig.underloadPacketMagicHeader = UInt32(conf.awgContainer.h3)
        interfaceConfig.transportPacketMagicHeader = UInt32(conf.awgContainer.h4)

        var peerConfigurations = [PeerConfiguration]()
        if let publicKey = PublicKey(base64Key: conf.awgContainer.serverPubKey) {
            var peerConfig = PeerConfiguration(publicKey: publicKey)
            peerConfig.preSharedKey = PreSharedKey(base64Key: conf.awgContainer.pskKey)
            peerConfig.endpoint = Endpoint(from: conf.awgContainer.endPoint)
            peerConfig.persistentKeepAlive = UInt16(conf.awgContainer.keepALive)

            if let allowedIpAddressRange = IPAddressRange(from: conf.awgContainer.allowedIps) {
                peerConfig.allowedIPs = [allowedIpAddressRange]
            }

            peerConfigurations.append(peerConfig)
        }

        let tunnelConfiguration = TunnelConfiguration(name: .appName, interface: interfaceConfig, peers: peerConfigurations)

        if let tunnel = tunnel {
            print("has tunnel")
            // We're modify a tunnel
            self.tunnelsManager?.modify(tunnel: tunnel, tunnelConfiguration: tunnelConfiguration, onDemandOption: .off, completionHandler: { result in
                if let error = result {
                    print(error.localizedDescription)
                } else {
                    print("success modify tunnel")
                }
            })
        } else {
            print("has not tunnel")
            // We're creating a new tunnel
            self.tunnelsManager?.add(tunnelConfiguration: tunnelConfiguration, onDemandOption: .off) { result in
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let tunnel):
                    print("success add tunnel")
                }
            }
        }
    }

    func removeConfiguration() {
        guard let manager = tunnelsManager else { return }
        guard let tunnel = tunnel else { return }
        manager.remove(tunnel: tunnel, completionHandler: { result in
            if let error = result {
                print(error.localizedDescription)
            } else {
                print("success remove tunnel")
            }
        })
    }

    var hasConfiguration: Bool {
        return tunnel != nil
    }

    func createManager(completionHandler: (() -> Void)?) {
        TunnelsManager.create { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                ErrorPresenter.showErrorAlert(error: error, from: self)
            case .success(let tunnelsManager):
                self.tunnelsManager = tunnelsManager
                self.tunnel = tunnelsManager.numberOfTunnels() > 0 ? self.tunnelsManager?.tunnel(at: 0) : nil

                tunnelsManager.activationDelegate = self
                tunnelsManager.tunnelsListDelegate = self
            }
            completionHandler?()
        }
    }

    func getStatus() {
        guard let tunnel = tunnel else { return }
        guard let date = tunnel.getConnectedDate else { return }
        self.delegate?.changeConnectedDate(date: date)
    }
}
private extension Connection {
    func checkConnection() {
        self.indexChecking = 0
        self.finishedRequest = 0
        self.statusRequests = 0
        self.requestChecking()
    }

    func requestChecking() {
        guard self.indexChecking < self.addresses.count else {
            print("finished requests")
            if self.statusRequests < self.finishedRequest / 2 {
                self.changeConnection(isOn: false)
            }
            return
        }

        let urlStr = "https://\(self.addresses[self.indexChecking])"
        print(urlStr)
        if let url = URL(string: urlStr) {
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            request.timeoutInterval = 2

            URLSession(configuration: .default).dataTask(with: request) { (_, response, error) -> Void in
                self.finishedRequest += 1
                guard error == nil else {
                    self.nextRequestChecking()
                    print("Error:", error ?? "")
                    return
                }

                guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                    print("down")
                    self.nextRequestChecking()
                    return
                }
                self.statusRequests += 1

                print("up")
                self.nextRequestChecking()
            }.resume()
        } else {
            self.indexChecking += 1
            self.requestChecking()
        }
    }

    func nextRequestChecking() {
        self.indexChecking += 1
        self.requestChecking()
    }
}
extension Connection: TunnelsManagerActivationDelegate {
    func tunnelActivationAttemptFailed(tunnel: TunnelContainer, error: TunnelsManagerActivationAttemptError) {
        let textError = "tunnelActivationAttemptFailed \(error.alertText)"
        print(textError)
//        self.delegate?.error(text: textError)
    }

    func tunnelActivationAttemptSucceeded(tunnel: TunnelContainer) {
        self.delegate?.connectionStatusChanged(state: .connecting)
        self.checkConnection()
    }

    func tunnelActivationFailed(tunnel: TunnelContainer, error: TunnelsManagerActivationError) {
        let textError = "tunnelActivationFailed \(error.localizedDescription)"
        print(textError)
        self.delegate?.error(text: textError)
    }

    func tunnelActivationSucceeded(tunnel: TunnelContainer) {
        self.delegate?.connectionStatusChanged(state: .connected)
        self.checkConnection()
    }
}
extension Connection: TunnelsManagerListDelegate {
    func tunnelAdded(at index: Int) {
        self.tunnel = (self.tunnelsManager?.numberOfTunnels() ?? 0) > 0 ? self.tunnelsManager?.tunnel(at: 0) : nil
        self.delegate?.connectionStatusChanged(state: .connecting)
    }

    func tunnelModified(at index: Int) {

    }

    func tunnelMoved(from oldIndex: Int, to newIndex: Int) {

    }

    func tunnelRemoved(at index: Int, tunnel: TunnelContainer) {

    }
}
