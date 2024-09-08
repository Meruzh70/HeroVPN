// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit

class HeroTextField: UITextField {

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        self.setDefaultBorder()

        let view = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: rect.height))
        view.backgroundColor = .clear
        self.leftView = view
        self.leftViewMode = .always

        self.rightView = view
        self.rightViewMode = .always
    }

}
