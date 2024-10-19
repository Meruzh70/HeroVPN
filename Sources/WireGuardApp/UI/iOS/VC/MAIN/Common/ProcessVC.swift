// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit

enum ProcessType {
    case processPayment, successPayment, errorPayment, confirmDelete

    var topTitle: String {
        return switch self {
        case .processPayment: ""
        case .successPayment: ""
        case .errorPayment: ""
        case .confirmDelete: "Delete account"
        }
    }

    var title: String {
        return switch self {
        case .processPayment: "Please Wait..."
        case .successPayment: "Success! You're Subscribed!"
        case .errorPayment: "Processing"
        case .confirmDelete: "Delete account"
        }
    }

    var subtitle: String {
        return switch self {
        case .processPayment: "We're Processing Your Payment. This May Take a Moment."
        case .successPayment: "You're Now Protected with Our %@ Plan and Ready to Explore the Internet Safely."
        case .errorPayment: "We Apologize, but It Seems There Was an Issue with Your Payment for the %@ Plan. Please Verify Your Details and Try Again."
        case .confirmDelete: "Are you sure you want to delete your account?"
        }
    }

    var mainTitleAction: String {
        return switch self {
        case .processPayment: ""
        case .successPayment: "Go to Homepage"
        case .errorPayment: "Go to Payment"
        case .confirmDelete: "Delete account"
        }
    }

    var additionalTitleAction: String {
        return switch self {
        case .processPayment: ""
        case .successPayment: ""
        case .errorPayment: ""
        case .confirmDelete: "Cancel"
        }
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
        case .errorPayment, .confirmDelete: "error"
        default: ""
        }
    }

    var showingTopTitle: Bool {
        return self == .confirmDelete
    }

    var showingBackButton: Bool {
        return self == .confirmDelete
    }

    var showingTimerLabel: Bool {
        return self == .processPayment
    }
}

protocol ProcessVCDelegate: AnyObject {
    func mainActionTouched(vc: UIViewController, type: ProcessType)
    func additionalActionTouched(vc: UIViewController, type: ProcessType)
}
extension ProcessVCDelegate {
    func mainActionTouched(vc: UIViewController, type: ProcessType) {

    }

    func additionalActionTouched(vc: UIViewController, type: ProcessType) {

    }
}

class ProcessVC: BackVC {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topTitleLabel: UILabel!

    @IBOutlet weak var backStateView: UIView!
    @IBOutlet weak var stateImageView: UIImageView!
    @IBOutlet weak var loaderView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!

    @IBOutlet weak var additionalActionBackgroundView: UIView!
    @IBOutlet weak var additionalActionButton: UIButton!

    @IBOutlet weak var mainActionBackgroundView: UIView!
    @IBOutlet weak var mainActionButton: UIButton!

    private var timer: Timer?
    private var dateStartTimer: TimeInterval?

    var type: ProcessType = .processPayment
    var planString: String = ""

    weak var delegate: ProcessVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureUI()
        self.stateChanged()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.configureButtons()
    }

    func changeStatus(type: ProcessType) {
        self.type = type
        self.stateChanged()
    }

    override func backTouch() {

    }
}
private extension ProcessVC {
    func configureButtons() {
        if self.type == .confirmDelete {
            self.mainActionBackgroundView.setRedGradient()
        } else {
            self.mainActionBackgroundView.setBlueGradient()
        }
        self.additionalActionBackgroundView.setGrayGradient()
    }

    func configureUI() {
//        self.configureButtons()

        self.backStateView.layer.cornerRadius = self.backStateView.frame.width / 2
        self.backStateView.clipsToBounds = true

        self.backButton.addTarget(self, action: #selector(backTouch), for: .touchUpInside)
        self.mainActionButton.addTarget(self, action: #selector(mainActionTouch), for: .touchUpInside)
        self.additionalActionButton.addTarget(self, action: #selector(additionalActionTouch), for: .touchUpInside)
    }

    func stateChanged() {
        self.backButton.isHidden = !self.type.showingBackButton
        self.topTitleLabel.isHidden = !self.type.showingTopTitle
        self.topTitleLabel.text = self.type.topTitle

        self.titleLabel.text = self.type.title
        self.subtitleLabel.text = String(format: self.type.subtitle, arguments: [self.planString])
        self.mainActionButton.setAttributedTitle(NSAttributedString(string: self.type.mainTitleAction, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.montserratSemiBold(size: 16)]), for: .normal)
        self.additionalActionButton.setAttributedTitle(NSAttributedString(string: self.type.additionalTitleAction, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.montserratSemiBold(size: 16)]), for: .normal)

        self.mainActionBackgroundView.isHidden = self.type.mainTitleAction.isEmpty
        self.additionalActionBackgroundView.isHidden = self.type.additionalTitleAction.isEmpty
//        self.loaderView.isHidden = !self.type.showingLoaderView
        self.activityIndicatorView.isHidden = !self.type.showingLoaderView

        self.backStateView.isHidden = !self.type.showingStateImage
        if !self.type.imageName.isEmpty, let image = UIImage(named: self.type.imageName) {
            self.stateImageView.image = image
        } else {
            self.stateImageView.image = nil
        }

        self.timerLabel.text = nil
        self.timerLabel.isHidden = !self.type.showingTimerLabel

        if self.type == .processPayment {
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerTick), userInfo: nil, repeats: true)
            self.dateStartTimer = Date().timeIntervalSince1970
        }
    }

    @objc
    func timerTick() {
        guard self.type == .processPayment, let dateStartTimer = dateStartTimer else {
            self.timer?.invalidate()
            return
        }

        let limit = 60
        let now = Date().timeIntervalSince1970
        let diff = Int(now - dateStartTimer)
        if diff < limit {
            self.timerLabel.text = "Time checking transaction: \(limit-diff) seconds"
        } else {
            self.timer?.invalidate()
            self.timerLabel.isHidden = true
            self.changeStatus(type: .errorPayment)
        }
    }

    @objc
    func mainActionTouch() {
        self.delegate?.mainActionTouched(vc: self, type: self.type)
    }

    @objc
    func additionalActionTouch() {
        self.delegate?.additionalActionTouched(vc: self, type: self.type)
    }
}
