// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit

class ChooseVC: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!

    var openLogin = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.loginButton.addTarget(self, action: #selector(loginTouch), for: .touchUpInside)
        self.signUpButton.addTarget(self, action: #selector(singUpTouch), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if openLogin {
            loginTouch()
            self.openLogin = false
        }
    }
}
private extension ChooseVC {
    @objc
    func loginTouch() {
        let vc = Utils.shared.mainStoryboard().instantiateViewController(withIdentifier: AuthVC.className)
        self.present(vc, animated: true)
    }

    @objc
    func singUpTouch() {
        let vc = Utils.shared.mainStoryboard().instantiateViewController(withIdentifier: SignUpVC.className)
        self.present(vc, animated: true)
    }
}
extension ChooseVC: SignUpDelegate {
    func auth() {
        self.loginTouch()
    }
}
extension ChooseVC: SignInDelegate {
    func signUp() {
        self.singUpTouch()
    }
}
