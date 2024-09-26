// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit
import ProgressHUD

class ForgotPasswordVC: UIViewController {

    @IBOutlet weak var backButton: UIButton!

    @IBOutlet weak var emailTextField: HeroTextField!

    @IBOutlet weak var sendButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureUI()
        self.setTargets()
    }
}
private extension ForgotPasswordVC {
    func configureUI() {
        self.emailTextField.setPlaceholder(text: "Email address")

//        self.emailTextField.text = UserDefaultsManager.shared.lastUsedEmail
    }

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
        let email = self.emailTextField.text ?? ""

        guard !email.isEmpty else {
            self.showAlert("Please fill out email field")
            return
        }

        UserDefaultsManager.shared.lastUsedEmail = email

        ProgressHUD.animate()
        AppService().forgot(email: email) { result in
            ProgressHUD.dismiss()
            switch result {
            case .succsess(let state):
                if state {
                    guard let vc = Utils.shared.mainStoryboard().instantiateViewController(withIdentifier: VerificationVC.className) as? VerificationVC else { return }
                    vc.needChangePassword = true
                    self.present(vc, animated: true)
                } else {
                    self.showAlert("Undefined error")
                }
            case .failure(let error):
                self.showAlert(error.textError)
            }
        }
    }

}
