// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit

class LogoutVC: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setTargets()
    }
}
private extension LogoutVC {
    func setTargets() {
        self.backButton.addTarget(self, action: #selector(backTouch), for: .touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(backTouch), for: .touchUpInside)
        self.logoutButton.addTarget(self, action: #selector(logoutTouch), for: .touchUpInside)
    }

    @objc
    func backTouch() {
        self.dismiss(animated: true)
    }

    @objc
    func logoutTouch() {
        UserDefaultsManager.shared.userName = nil
        KeychainManager.shared.removeAll()
        Connection.shared.changeConnection(isOn: false)
//        Connection.shared.removeConfiguration()
        NotificationCenter.default.post(name: .needOpenAuth, object: nil)
    }
}
