// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit
import ProgressHUD

class ResetPasswordVC: BackVC {

    @IBOutlet weak var backButton: UIButton!

    @IBOutlet weak var passwordTextField: HeroTextField!
    @IBOutlet weak var showPasswordButton: UIButton!

    @IBOutlet weak var confirmPasswordTextField: HeroTextField!
    @IBOutlet weak var showConfirmPasswordButton: UIButton!

    @IBOutlet weak var resetButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureUI()
        self.setTargets()
    }

}
private extension ResetPasswordVC {
    func configureUI() {

        self.backButton.isHidden = true

        self.passwordTextField.setPlaceholder(text: "Password")
        self.confirmPasswordTextField.setPlaceholder(text: "Confirm Password")
    }

    func setTargets() {
        self.backButton.addTarget(self, action: #selector(backTouch), for: .touchUpInside)
        self.showPasswordButton.addTarget(self, action: #selector(showPasswordTouch), for: .touchUpInside)
        self.showConfirmPasswordButton.addTarget(self, action: #selector(showConfirmPasswordTouch), for: .touchUpInside)
        self.resetButton.addTarget(self, action: #selector(resetTouch), for: .touchUpInside)
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
        let password = self.passwordTextField.text ?? ""
        let confirmPassword = self.confirmPasswordTextField.text ?? ""

        guard !password.isEmpty else {
            self.showAlert("Please fill out password")
            return
        }

        guard !confirmPassword.isEmpty else {
            self.showAlert("Please fill out confirm password")
            return
        }

        guard password == confirmPassword else {
            self.showAlert("Entered password not equal confirm password")
            return
        }

        ProgressHUD.animate()
        AppService().password(password: password, complition: { result in
            ProgressHUD.dismiss()
            switch result {
            case .success(let state):
                if state {
                    let vc = Utils.shared.mainStoryboard().instantiateViewController(withIdentifier: ResetPasswordSuccessVC.className)
                    self.present(vc, animated: true)
                } else {
                    self.showAlert("Undefined error")
                }
            case .failure(let error):
                self.showAlert(error.textError)
            }
        })
    }
}
