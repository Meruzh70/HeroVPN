// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit

protocol SignInDelegate: AnyObject {
    func signUp()
}

class AuthVC: UIViewController {

    @IBOutlet weak var backButton: UIButton!

    @IBOutlet weak var emailTextField: UITextField!

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var showPasswordButton: UIButton!

    @IBOutlet weak var forgotPasswordButton: UIButton!

    @IBOutlet weak var signInButton: UIButton!

    @IBOutlet weak var appleSignInButton: UIButton!

    @IBOutlet weak var signUpButton: UIButton!

    weak var delegate: SignInDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.emailTextField.text = UserDefaultsManager.shared.lastUsedEmail

        self.setTargets()
    }

}
private extension AuthVC {
    func setTargets() {
        self.backButton.addTarget(self, action: #selector(backTouch), for: .touchUpInside)
        self.showPasswordButton.addTarget(self, action: #selector(showPasswordTouch), for: .touchUpInside)
        self.forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTouch), for: .touchUpInside)
        self.appleSignInButton.addTarget(self, action: #selector(appleSignInTouch), for: .touchUpInside)
        self.signUpButton.addTarget(self, action: #selector(signUpTouch), for: .touchUpInside)
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
    func forgotPasswordTouch() {
        let vc = Utils.shared.mainStoryboard().instantiateViewController(withIdentifier: ForgotPasswordVC.className)
        self.present(vc, animated: true)
    }

    @objc
    func appleSignInTouch() {

    }

    @objc
    func signUpTouch() {
        UserDefaultsManager.shared.lastUsedEmail = emailTextField.text ?? ""
        self.delegate?.signUp()
    }

}
