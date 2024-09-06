// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit

class ForgotPasswordVC: UIViewController {

    @IBOutlet weak var backButton: UIButton!

    @IBOutlet weak var emailTextField: UITextField!

    @IBOutlet weak var sendButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.emailTextField.text = UserDefaultsManager.shared.lastUsedEmail

        self.setTargets()
    }
}
private extension ForgotPasswordVC {
    func setTargets() {
        self.backButton.addTarget(self, action: #selector(backTouch), for: .touchUpInside)
        self.sendButton.addTarget(self, action: #selector(sendTouch), for: .touchUpInside)
    }

    @objc
    func backTouch() {
        self.dismiss(animated: true)
    }

    @objc
    func sendTouch() {

    }

}
