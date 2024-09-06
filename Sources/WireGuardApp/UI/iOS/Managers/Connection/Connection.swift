// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import Foundation

protocol ConnectionDelegate: AnyObject {
    func successChangeConfiguration()
    func connectionStatusChanged(state: ConnectionState)
    func changedSpeed(download: Double, upload: Double)

    func errorChangeConfiguration(text: String)
    func successConnect()
    func successDisconnect()
    func errorConnect(text: String)
}

class Connection {

    static let shared = Connection()

    init() { }

    weak var delegate: ConnectionDelegate?

    private var tunnelsManager: TunnelsManager?
    private var tunnel: TunnelContainer?

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

    func changeConfiguration() {
        let conf = Configuration(fromJson: nil)

        guard let privateKey = PrivateKey(base64Key: conf.clientPrivateKey) else {
            print("error private key")
            return
        }
        var interfaceConfig = InterfaceConfiguration(privateKey: privateKey)

        if let addressRange = IPAddressRange(from: conf.address) {
            interfaceConfig.addresses = [addressRange]
        }
        interfaceConfig.listenPort = UInt16(conf.port)

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

        interfaceConfig.junkPacketCount = UInt16(conf.jc)
        interfaceConfig.junkPacketMinSize = UInt16(conf.jMin)
        interfaceConfig.junkPacketMaxSize = UInt16(conf.jMax)

        interfaceConfig.initPacketJunkSize = UInt16(conf.s1)
        interfaceConfig.responsePacketJunkSize = UInt16(conf.s2)

        interfaceConfig.initPacketMagicHeader = UInt32(conf.h1)
        interfaceConfig.responsePacketMagicHeader = UInt32(conf.h2)
        interfaceConfig.underloadPacketMagicHeader = UInt32(conf.h3)
        interfaceConfig.transportPacketMagicHeader = UInt32(conf.h4)

        var peerConfigurations = [PeerConfiguration]()
        if let publicKey = PublicKey(base64Key: conf.serverPubKey) {
            var peerConfig = PeerConfiguration(publicKey: publicKey)
            peerConfig.preSharedKey = PreSharedKey(base64Key: conf.pskKey)
            peerConfig.endpoint = Endpoint(from: conf.endPoint)
            peerConfig.persistentKeepAlive = UInt16(conf.keepALive)

            if let allowedIpAddressRange = IPAddressRange(from: conf.allowedIps) {
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

    func getSpeed() {
        guard let tunnelsManager = tunnelsManager else { return }
        tunnelsManager.getTraffic()
    }
}
extension Connection: TunnelsManagerActivationDelegate {
    func tunnelActivationAttemptFailed(tunnel: TunnelContainer, error: TunnelsManagerActivationAttemptError) {
        print("tunnelActivationAttemptFailed \(error.localizedDescription)")
//        self.delegate?.errorConnect(text: error.localizedDescription)
    }

    func tunnelActivationAttemptSucceeded(tunnel: TunnelContainer) {
        self.delegate?.connectionStatusChanged(state: .connecting)
    }

    func tunnelActivationFailed(tunnel: TunnelContainer, error: TunnelsManagerActivationError) {
        print("tunnelActivationFailed \(error.localizedDescription)")
//        self.delegate?.errorConnect(text: error.localizedDescription)
    }

    func tunnelActivationSucceeded(tunnel: TunnelContainer) {
        self.delegate?.connectionStatusChanged(state: .connected)
//        self.delegate?.successConnect()
    }
}
extension Connection: TunnelsManagerListDelegate {
    func tunnelAdded(at index: Int) {
        self.delegate?.connectionStatusChanged(state: .connecting)
        self.changeConnection(isOn: true)
    }

    func tunnelModified(at index: Int) {

    }

    func tunnelMoved(from oldIndex: Int, to newIndex: Int) {

    }

    func tunnelRemoved(at index: Int, tunnel: TunnelContainer) {

    }
}
