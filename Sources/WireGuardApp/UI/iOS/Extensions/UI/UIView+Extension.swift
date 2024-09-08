// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit

extension UIView {
    public func setDefaultBorder() {
        self.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
    }
}
