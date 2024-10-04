// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit

class LoaderView: UIView {

    private var viewAnimation: UIView?
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
extension LoaderView {
    func startAnimating() {
        let width = self.frame.size.width
        let height = self.frame.size.height
        let center = CGPoint(x: width / 2, y: height / 2)

        let beginTime        = 0.5
        let durationStart    = 1.2
        let durationStop    = 0.7

        let animationRotation = CABasicAnimation(keyPath: "transform.rotation")
        animationRotation.byValue = 2 * Float.pi
        animationRotation.timingFunction = CAMediaTimingFunction(name: .linear)

        let animationStart = CABasicAnimation(keyPath: "strokeStart")
        animationStart.duration = durationStart
        animationStart.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0, 0.2, 1)
        animationStart.fromValue = 0
        animationStart.toValue = 1
        animationStart.beginTime = beginTime

        let animationStop = CABasicAnimation(keyPath: "strokeEnd")
        animationStop.duration = durationStop
        animationStop.timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0, 0.2, 1)
        animationStop.fromValue = 0
        animationStop.toValue = 1

        let animation = CAAnimationGroup()
        animation.animations = [animationRotation, animationStop, animationStart]
        animation.duration = durationStart + beginTime
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards

        let path = UIBezierPath(arcCenter: center, radius: width / 2, startAngle: -0.5 * .pi, endAngle: 1.5 * .pi, clockwise: true)

        let layer = CAShapeLayer()
        layer.frame = CGRect(x: 0, y: 0, width: width, height: height)
        layer.path = path.cgPath
        layer.fillColor = nil
        layer.lineWidth = 5

        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = [UIColor.leftBlueColor.cgColor,
                           UIColor.rightBlueColor.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradient.mask = gradient

        layer.add(animation, forKey: "animation")
        self.layer.addSublayer(gradient)
    }
}
