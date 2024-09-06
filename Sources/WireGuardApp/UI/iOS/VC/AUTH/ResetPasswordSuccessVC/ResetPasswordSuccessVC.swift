// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit

class ResetPasswordSuccessVC: UIViewController {

    @IBOutlet weak var goLoginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setTargets()
    }
}
private extension ResetPasswordSuccessVC {
    func setTargets() {
        self.goLoginButton.addTarget(self, action: #selector(goLoginTouch), for: .touchUpInside)
    }

    @objc
    func goLoginTouch() {
        NotificationCenter.default.post(name: .needOpenChooseVCForLogin, object: nil)
    }
}
