// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit
import ProgressHUD

//protocol SignUpDelegate: AnyObject {
//    func auth()
//}

class SignUpVC: UIViewController {

    @IBOutlet weak var backButton: UIButton!

    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var emailTextField: UITextField!

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var showPasswordButton: UIButton!

    @IBOutlet weak var singUpButton: UIButton!

    @IBOutlet weak var signInButton: UIButton!

//    weak var delegate: SignUpDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.emailTextField.text = UserDefaultsManager.shared.lastUsedEmail

        self.setTargets()
    }

}
private extension SignUpVC {
    func setTargets() {
        self.backButton.addTarget(self, action: #selector(backTouch), for: .touchUpInside)
        self.showPasswordButton.addTarget(self, action: #selector(showPasswordTouch), for: .touchUpInside)
        self.singUpButton.addTarget(self, action: #selector(singUpTouch), for: .touchUpInside)
        self.signInButton.addTarget(self, action: #selector(signInTouch), for: .touchUpInside)
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
            case .succsess(let name):
                UserDefaultsManager.shared.userName = name
                NotificationCenter.default.post(name: .needOpenMainTabBar, object: nil)
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
