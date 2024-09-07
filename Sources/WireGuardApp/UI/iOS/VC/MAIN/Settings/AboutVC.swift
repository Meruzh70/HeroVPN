// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit

class AboutVC: UIViewController {

    @IBOutlet weak var backButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setTargets()
    }
}
private extension AboutVC {
    func setTargets() {
        self.backButton.addTarget(self, action: #selector(backTouch), for: .touchUpInside)
    }

    @objc
    func backTouch() {
        self.dismiss(animated: true)
    }
}
