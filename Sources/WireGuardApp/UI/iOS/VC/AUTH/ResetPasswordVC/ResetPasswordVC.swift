// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit

class ResetPasswordVC: UIViewController {

    @IBOutlet weak var backButton: UIButton!

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var showPasswordButton: UIButton!

    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var showConfirmPasswordButton: UIButton!

    @IBOutlet weak var resetButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setTargets()
    }

}
private extension ResetPasswordVC {
    func setTargets() {
        self.backButton.addTarget(self, action: #selector(backTouch), for: .touchUpInside)
        self.showPasswordButton.addTarget(self, action: #selector(showPasswordTouch), for: .touchUpInside)
        self.showConfirmPasswordButton.addTarget(self, action: #selector(showConfirmPasswordTouch), for: .touchUpInside)
        self.resetButton.addTarget(self, action: #selector(resetTouch), for: .touchUpInside)
    }

    @objc
    func backTouch() {
        self.dismiss(animated: true)
    }

    @objc
    func showPasswordTouch() {
        self.passwordTextField.isSecureTextEntry.toggle()
    }

    @objc
    func showConfirmPasswordTouch() {
        self.confirmPasswordTextField.isSecureTextEntry.toggle()
    }

    @objc
    func resetTouch() {

    }
}
