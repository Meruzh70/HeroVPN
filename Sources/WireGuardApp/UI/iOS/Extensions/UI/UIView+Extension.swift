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

    func setGradient(colors: [CGColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors
        gradientLayer.locations = [0.0, 1.0]

        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)

        self.layer.insertSublayer(gradientLayer, at: 0)
    }

    func setBlueGradient() {
        guard self.layer.sublayers?.first as? CAGradientLayer == nil else { return }
        self.backgroundColor = .clear
        self.layer.cornerRadius = 16
        self.clipsToBounds = true
        self.setGradient(colors: [UIColor.leftBlueColor.cgColor, UIColor.rightBlueColor.cgColor])
    }

    func setTestGradient() {
        self.backgroundColor = .clear

        let gradientLayer = CAGradientLayer()

        gradientLayer.colors = [UIColor.leftBlueColor.cgColor, UIColor.rightBlueColor.cgColor]
//        gradientLayer.colors = [UIColor.red.cgColor, UIColor.blue.cgColor]
        gradientLayer.locations = [0.0, 1.0]

        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)

        gradientLayer.frame = self.bounds

        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
