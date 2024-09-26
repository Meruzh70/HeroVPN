// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit
import ProgressHUD
import AuthenticationServices

//protocol SignInDelegate: AnyObject {
//    func signUp()
//}

class AuthVC: UIViewController {

    @IBOutlet weak var backButton: UIButton!

    @IBOutlet weak var emailTextField: HeroTextField!

    @IBOutlet weak var passwordTextField: HeroTextField!
    @IBOutlet weak var showPasswordButton: UIButton!

    @IBOutlet weak var forgotPasswordButton: UIButton!

    @IBOutlet weak var signInButton: UIButton!

    @IBOutlet weak var appleSignInButton: UIButton!

    @IBOutlet weak var signUpButton: UIButton!

//    weak var delegate: SignInDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureUI()
        self.setTargets()
    }

}
private extension AuthVC {
    func configureUI() {
        self.emailTextField.setPlaceholder(text: "Email address")
        self.passwordTextField.setPlaceholder(text: "Password")

//        self.emailTextField.text = UserDefaultsManager.shared.lastUsedEmail
    }

    func setTargets() {
        self.backButton.addTarget(self, action: #selector(backTouch), for: .touchUpInside)
        self.showPasswordButton.addTarget(self, action: #selector(showPasswordTouch), for: .touchUpInside)
        self.signInButton.addTarget(self, action: #selector(signInTouch), for: .touchUpInside)
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
    func signInTouch() {
        let email = self.emailTextField.text ?? ""
        let password = self.passwordTextField.text ?? ""

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
        AppService().login(email: email, password: password) { result in
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
    func forgotPasswordTouch() {
        let vc = Utils.shared.mainStoryboard().instantiateViewController(withIdentifier: ForgotPasswordVC.className)
        self.present(vc, animated: true)
    }

    @objc
    func appleSignInTouch() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
//        controller.presentationContextProvider = self
        controller.performRequests()
    }

    @objc
    func signUpTouch() {
//        self.delegate?.signUp()
        let vc = Utils.shared.mainStoryboard().instantiateViewController(withIdentifier: SignUpVC.className)
        self.present(vc, animated: true)
    }
}
extension AuthVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let code = appleIDCredential.authorizationCode,
            let codeStr = String(data: code, encoding: .utf8) else {
                return
        }

        var name = ""
        if let fullName = appleIDCredential.fullName {
            if let givenName = fullName.givenName {
                name = givenName
            }
            if let familyName = fullName.familyName {
                if name.isEmpty {
                    name = familyName
                } else {
                    name += " \(familyName)"
                }
            }
        }

        print("apple sign in name: \(name) apple token:\(codeStr)")

        ProgressHUD.animate()
        AppService().loginApple(appleToken: codeStr) { result in
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

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.showAlert(error.localizedDescription)
    }
}
