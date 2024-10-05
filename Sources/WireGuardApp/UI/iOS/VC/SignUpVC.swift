// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit
import ProgressHUD

//protocol SignUpDelegate: AnyObject {
//    func auth()
//}

class SignUpVC: BackVC {

    @IBOutlet weak var backButton: UIButton!

    @IBOutlet weak var nameTextField: HeroTextField!

    @IBOutlet weak var emailTextField: HeroTextField!

    @IBOutlet weak var passwordTextField: HeroTextField!
    @IBOutlet weak var showPasswordButton: UIButton!

    @IBOutlet weak var singUpButton: UIButton!

    @IBOutlet weak var signInButton: UIButton!

//    weak var delegate: SignUpDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureUI()
        self.setTargets()
    }

}
private extension SignUpVC {
    func configureUI() {
        self.nameTextField.setPlaceholder(text: "Name")
        self.emailTextField.setPlaceholder(text: "Email address")
        self.passwordTextField.setPlaceholder(text: "Password")

//        self.emailTextField.text = UserDefaultsManager.shared.lastUsedEmail
    }

    func setTargets() {
        self.backButton.addTarget(self, action: #selector(backTouch), for: .touchUpInside)
        self.showPasswordButton.addTarget(self, action: #selector(showPasswordTouch), for: .touchUpInside)
        self.singUpButton.addTarget(self, action: #selector(singUpTouch), for: .touchUpInside)
        self.signInButton.addTarget(self, action: #selector(signInTouch), for: .touchUpInside)
    }

    @objc
    func showPasswordTouch() {
        self.passwordTextField.isSecureTextEntry.toggle()
    }

    @objc
    func singUpTouch() {
        let name = self.nameTextField.text ?? ""
        let email = self.emailTextField.text ?? ""
        let password = self.passwordTextField.text ?? ""

        guard !name.isEmpty else {
            self.showAlert("Please fill out full name field")
            return
        }

        guard !email.isEmpty else {
            self.showAlert("Please fill out email field")
            return
        }

        guard email.isValidEmail else {
            self.showAlert("Enter valid Email")
            return
        }

        guard !password.isEmpty else {
            self.showAlert("Please fill out password field")
            return
        }

        UserDefaultsManager.shared.lastUsedEmail = email

        ProgressHUD.animate()
        AppService().register(name: name, email: email, password: password) { result in
            ProgressHUD.dismiss()
            switch result {
            case .success(let state):
                if state {
                    let vc = Utils.shared.mainStoryboard().instantiateViewController(withIdentifier: VerificationVC.className)
                    self.present(vc, animated: true)
                } else {
                    self.showAlert("Undefined error")
                }
            case .failure(let error):
                self.showAlert(error.textError)
            }
        }
    }

    @objc
    func signInTouch() {
//        self.delegate?.auth()
        self.backTouch()
    }
}
