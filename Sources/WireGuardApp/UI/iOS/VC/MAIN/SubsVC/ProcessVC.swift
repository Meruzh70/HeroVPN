// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit

enum ProcessType {
    case processPayment, successPayment, errorPayment

    var title: String {
        return switch self {
        case .processPayment: "Please Wait..."
        case .successPayment: "Success! You're Subscribed!"
        case .errorPayment: "Processing"
        }
    }

    var subtitle: String {
        return switch self {
        case .processPayment: "We're Processing Your Payment. This May Take a Moment."
        case .successPayment: "You're Now Protected with Our %@ Plan and Ready to Explore the Internet Safely."
        case .errorPayment: "We Apologize, but It Seems There Was an Issue with Your Payment for the %@ Plan. Please Verify Your Details and Try Again."
        }
    }

    var titleAction: String {
        return switch self {
        case .processPayment: ""
        case .successPayment: "Go to Homepage"
        case .errorPayment: "Go to Payment"
        }
    }

    var showingMainButton: Bool {
        return self != .processPayment
    }

    var showingLoaderView: Bool {
        return self == .processPayment
    }

    var showingStateImage: Bool {
        return self != .processPayment
    }

    var imageName: String {
        return switch self {
        case .successPayment: "success"
        case .errorPayment: "error"
        default: ""
        }
    }
}

protocol ProcessVCDelegate: AnyObject {
    func mainActionTouched(vc: UIViewController, type: ProcessType)
}

class ProcessVC: UIViewController {

    @IBOutlet weak var backStateView: UIView!
    @IBOutlet weak var stateImageView: UIImageView!
    @IBOutlet weak var loaderView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    @IBOutlet weak var mainActionBackgroundView: UIView!
    @IBOutlet weak var mainActionButton: UIButton!

    var type: ProcessType = .processPayment
    var planString: String = ""

    weak var delegate: ProcessVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureUI()
        self.stateChanged()
    }

    func changeStatus(type: ProcessType) {
        self.type = type
        self.stateChanged()
    }
}
private extension ProcessVC {
    func configureUI() {
        self.mainActionBackgroundView.setBlueGradient()

        self.backStateView.layer.cornerRadius = self.backStateView.frame.width / 2
        self.backStateView.clipsToBounds = true

        self.mainActionButton.addTarget(self, action: #selector(mainActionTouch), for: .touchUpInside)
    }

    func stateChanged() {
        self.titleLabel.text = self.type.title
        self.subtitleLabel.text = String(format: self.type.subtitle, arguments: [self.planString])
        self.mainActionButton.setAttributedTitle(NSAttributedString(string: self.type.titleAction, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.montserratSemiBold(size: 16)]), for: .normal)

        self.mainActionBackgroundView.isHidden = !self.type.showingMainButton
        self.loaderView.isHidden = !self.type.showingLoaderView

        self.backStateView.isHidden = !self.type.showingStateImage
        self.stateImageView.image = UIImage(named: self.type.imageName)
    }

    @objc
    func mainActionTouch() {
        self.delegate?.mainActionTouched(vc: self, type: self.type)
    }
}
