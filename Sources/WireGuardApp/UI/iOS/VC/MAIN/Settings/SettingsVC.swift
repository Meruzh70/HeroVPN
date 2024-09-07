// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var supportButton: UIButton!
    @IBOutlet weak var appearanceSwitch: UISwitch!

    @IBOutlet weak var logoutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setTargets()
    }
}
private extension SettingsVC {
    func setTargets() {
        self.languageButton.addTarget(self, action: #selector(languageTouch), for: .touchUpInside)
        self.termsButton.addTarget(self, action: #selector(termsTouch), for: .touchUpInside)
        self.privacyPolicyButton.addTarget(self, action: #selector(privacyPolicyTouch), for: .touchUpInside)
        self.aboutButton.addTarget(self, action: #selector(aboutTouch), for: .touchUpInside)
        self.supportButton.addTarget(self, action: #selector(supportTouch), for: .touchUpInside)
        self.appearanceSwitch.addTarget(self, action: #selector(appearanceSwitchChange), for: .valueChanged)
        self.logoutButton.addTarget(self, action: #selector(logoutTouch), for: .touchUpInside)
    }

    @objc
    func languageTouch() {
        let vc = Utils.shared.mainStoryboard().instantiateViewController(withIdentifier: LanguageVC.className)
        self.present(vc, animated: true)
    }

    @objc
    func termsTouch() {
        let vc = Utils.shared.mainStoryboard().instantiateViewController(withIdentifier: TermsVC.className)
        self.present(vc, animated: true)
    }

    @objc
    func privacyPolicyTouch() {
        let vc = Utils.shared.mainStoryboard().instantiateViewController(withIdentifier: PrivacyVC.className)
        self.present(vc, animated: true)
    }

    @objc
    func aboutTouch() {
        let vc = Utils.shared.mainStoryboard().instantiateViewController(withIdentifier: AboutVC.className)
        self.present(vc, animated: true)
    }

    @objc
    func supportTouch() {
        self.showAlert("support touched")
    }

    @objc
    func appearanceSwitchChange() {
        self.showAlert("appearance changed")
    }

    @objc
    func logoutTouch() {
        let vc = Utils.shared.mainStoryboard().instantiateViewController(withIdentifier: LogoutVC.className)
        self.present(vc, animated: true)
    }

}
