// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit
import SwiftGifOrigin
import ProgressHUD
import SwiftyJSON

enum ConnectionState {
    case disconnected, connected, connecting

    var gifImageName: String {
        return switch self {
        case .disconnected: "disconnected"
        case .connecting: "connecting"
        case .connected: "connected"
        }
    }

    var labelText: String {
        return switch self {
        case .disconnected: "Not connected"
        case .connecting: "Connecting"
        case .connected: "Connected"
        }
    }
}

class HomeVC: UIViewController {

    @IBOutlet weak var shareButton: UIButton!

    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!

    @IBOutlet weak var connectionImageView: UIImageView!
    @IBOutlet weak var connectionButton: UIButton!

    @IBOutlet weak var downloadSpeedLabel: UILabel!
    @IBOutlet weak var uploadSpeedLabel: UILabel!

    private var state: ConnectionState = .disconnected {
        didSet {
            if connectionImageView != nil {
                self.connectionImageView.loadGif(name: state.gifImageName)
            }
            if stateLabel != nil {
                stateLabel.text = state.labelText
            }
            if state == .disconnected {
                UserDefaultsManager.shared.timerStartConnection = nil
                self.timer?.invalidate()
                self.timer = nil
                self.updateTimer()
                NetworkDataUsage.shared.reset()
            }
        }
    }

    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        UserDefaultsManager.shared.timerStartConnection = nil

        self.nameLabel.text = UserDefaultsManager.shared.userName ?? "Walter White"
        self.locationLabel.text = "Armenia"
        self.state = .disconnected

        self.setTargets()
        self.subscribeNoticications()

        Connection.shared.createManager {
            Connection.shared.delegate = self

            if Connection.shared.hasConfiguration {
                self.getConfiguration()
                Connection.shared.getStatus()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Connection.shared.getStatus()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

private extension HomeVC {
    func setTargets() {
        self.shareButton.addTarget(self, action: #selector(shareTouch(_:)), for: .touchUpInside)
        self.connectionButton.addTarget(self, action: #selector(connectTouch), for: .touchUpInside)
    }

    func subscribeNoticications() {
        NotificationCenter.default.addObserver(self, selector: #selector(getConfiguration), name: .needGetConfiguration, object: nil)
    }

    @objc
    func shareTouch(_ sender: UIButton) {
        if let appURL = URL(string: "https://apps.apple.com/app/id6502580819") {
             let activityViewController = UIActivityViewController(activityItems: [appURL], applicationActivities: nil)

             // Exclude some activity types from the list (optional)
             activityViewController.excludedActivityTypes = [
                 .addToReadingList,
                 .assignToContact,
                 .saveToCameraRoll,
                 .print
             ]

             // For iPad, set the popover presentation controller
             if let popoverController = activityViewController.popoverPresentationController {
                 popoverController.sourceView = self.view
                 popoverController.sourceRect = (sender as AnyObject).frame
             }

             self.present(activityViewController, animated: true, completion: nil)
         }
    }

    @objc
    func connectTouch() {
        Connection.shared.changeConnection(isOn: self.state == .disconnected)
    }

    @objc
    func getConfiguration() {
        AppService().getConfig { result in
            switch result {
            case .succsess(let data):
                if let json = try? JSON.init(data: data) {
                    let configuration = Configuration(fromJson: json)
                    //print("configuration: \(configuration.parsedData)")
                    //UIPasteboard.general.string = "configuration.parsedData"
                    Connection.shared.changeConfiguration(conf: configuration)
                } else {
                    self.showAlert("Error parse json from request")
                }
            case .failure(let error):
                self.showAlert(error.textError)
            }
        }
    }

    @objc
    func updateTimer() {
        guard let savedTime = UserDefaultsManager.shared.timerStartConnection else {
            self.timeLabel.text = "00:00:00"
            return
        }
        let diff = Int(Date().timeIntervalSince1970 - savedTime)
        let hours = diff / 3600
        let minutes = (diff % 3600) / 60
        let seconds = (diff % 3600) % 60
        let timeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        self.timeLabel.text = timeString

        let speed = NetworkDataUsage.shared.speedValue
        self.downloadSpeedLabel.text = speed.download
        self.uploadSpeedLabel.text = speed.upload
    }

}
extension HomeVC: ConnectionDelegate {
    func changeConnectedDate(date: Date) {
        UserDefaultsManager.shared.timerStartConnection = date.timeIntervalSince1970
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        if self.state != .connected {
            self.state = .connected
        }
    }

    func connectionStatusChanged(state: ConnectionState) {
        guard self.state != state else { return }
        print("connectionStatusChanged: \(state)")
        self.state = state
        if state == .connecting {
            Connection.shared.changeConnection(isOn: true)
        }
        Connection.shared.getStatus()
    }

    func changedSpeed(download: Double, upload: Double) {
        print("download \(download) upload: \(upload)")
    }

    func error(text: String) {
        self.showAlert(text)
    }
}
