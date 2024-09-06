// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit

class VerificationVC: UIViewController {

    @IBOutlet weak var backButton: UIButton!

    @IBOutlet weak var topEmailLabel: UILabel!

    @IBOutlet weak var otpFieldView: OTPFieldView!

    @IBOutlet weak var verifyButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.topEmailLabel.text = UserDefaultsManager.shared.lastUsedEmail

        self.setTargets()
    }

}
private extension VerificationVC {
    func setTargets() {
        self.backButton.addTarget(self, action: #selector(backTouch), for: .touchUpInside)
        self.verifyButton.addTarget(self, action: #selector(verifyTouch), for: .touchUpInside)
    }

    @objc
    func backTouch() {
        self.dismiss(animated: true)
    }

    @objc
    func verifyTouch() {


    }
}
