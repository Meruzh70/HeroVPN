// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit

class Onboarding3VC: UIViewController {

    @IBOutlet weak var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.nextButton.addTarget(self, action: #selector(nextTouch), for: .touchUpInside)
    }

    @objc
    func nextTouch() {
        let vc = Utils.shared.mainStoryboard().instantiateViewController(withIdentifier: AuthVC.className)
        self.present(vc, animated: true)
    }
}
