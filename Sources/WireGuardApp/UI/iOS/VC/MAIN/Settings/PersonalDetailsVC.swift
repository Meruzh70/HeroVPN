// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit
import ProgressHUD

class PersonalDetailsVC: BackVC {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deleteTitleLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setTargets()
    }
}
private extension PersonalDetailsVC {
    func setTargets() {
        self.backButton.addTarget(self, action: #selector(backTouch), for: .touchUpInside)
        self.deleteButton.addTarget(self, action: #selector(deleteTouch), for: .touchUpInside)
    }

    @objc
    func deleteTouch() {
        guard let vc = Utils.shared.mainStoryboard().instantiateViewController(withIdentifier: ProcessVC.className) as? ProcessVC else { return }
        vc.type = .confirmDelete
        vc.delegate = self
        self.present(vc, animated: true)
    }
}
extension PersonalDetailsVC: ProcessVCDelegate {
    func mainActionTouched(vc: UIViewController, type: ProcessType) {
        vc.dismiss(animated: true)
        ProgressHUD.animate()
        AppService().delete { result in
            ProgressHUD.dismiss()
            switch result {
            case .success(let state):
                if state {
                    UserDefaultsManager.shared.userName = nil
                    UserDefaultsManager.shared.timerFinishSubscribtion = nil
                    KeychainManager.shared.removeAll()
                    Connection.shared.changeConnection(isOn: false)
            //        Connection.shared.removeConfiguration()
                    NotificationCenter.default.post(name: .needOpenAuth, object: nil)
                } else {
                    self.showAlert("Error delete account")
                }
            case .failure(let error):
                self.showAlert(error.textError)
            }
        }
    }

    func additionalActionTouched(vc: UIViewController, type: ProcessType) {
        vc.dismiss(animated: true)
    }
}
