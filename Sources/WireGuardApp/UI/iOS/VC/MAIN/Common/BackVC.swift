// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit

class BackVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(backTouch))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }

}
extension BackVC {
    @objc
    func backTouch() {
        self.dismiss(animated: true)
    }
}
