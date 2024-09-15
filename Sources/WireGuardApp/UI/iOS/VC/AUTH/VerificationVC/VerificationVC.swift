// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit
import ProgressHUD

class VerificationVC: UIViewController {

    @IBOutlet weak var backButton: UIButton!

    @IBOutlet weak var topEmailLabel: UILabel!

    @IBOutlet weak var otpFieldView: OTPFieldView!

    @IBOutlet weak var verifyButton: UIButton!

    fileprivate var code = ""

    var needChangePassword = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureUI()
        self.setTargets()
    }

}
private extension VerificationVC {
    func configureUI() {
        self.topEmailLabel.text = UserDefaultsManager.shared.lastUsedEmail

        self.otpFieldView.fieldsCount = 4
        self.otpFieldView.fieldBorderWidth = 1
        self.otpFieldView.defaultBorderColor = UIColor.white.withAlphaComponent(0.3)
        self.otpFieldView.filledBorderColor = UIColor.white.withAlphaComponent(0.3)
        self.otpFieldView.cursorColor = .white
        self.otpFieldView.displayType = .roundedCorner
        self.otpFieldView.shouldAllowIntermediateEditing = false
        self.otpFieldView.fieldSize = 70
        self.otpFieldView.textColor = .white
        if let font = UIFont(name: "Montserrat-Regular", size: 32) {
            self.otpFieldView.fieldFont = font
        }
        self.otpFieldView.delegate = self
        self.otpFieldView.initializeUI()
    }
    
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
        guard let email = self.topEmailLabel.text else { return }
        guard self.code.count == 4 else { return }

        ProgressHUD.animate()
        AppService().confirm(email: email, code: code) { result in
            ProgressHUD.dismiss()
            self.code = ""
            self.otpFieldView.clearFields()
            switch result {
            case .succsess(let name):
                UserDefaultsManager.shared.userName = name
                if self.needChangePassword {
                    let vc = Utils.shared.mainStoryboard().instantiateViewController(withIdentifier: ResetPasswordVC.className)
                    self.present(vc, animated: true)
                } else {
                    NotificationCenter.default.post(name: .needOpenMainTabBar, object: nil)
                }
            case .failure(let error):
                self.showAlert(error.textError)
            }
        }
    }
}
extension VerificationVC: OTPFieldViewDelegate {
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {

        return true
    }

    func enteredOTP(otp: String) {
        self.code = otp
    }

    func hasEnteredAllOTP(hasEnteredAll: Bool) -> Bool {
        self.verifyTouch()
        return hasEnteredAll
    }

}
