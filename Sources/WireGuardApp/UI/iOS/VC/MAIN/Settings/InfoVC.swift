// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit

enum InfoType {
    case terms, privacy, about

    var alias: String {
        return switch self {
        case .terms: "terms_of_service"
        case .privacy: "privacy"
        case .about: "privacy"
        }
    }

    var title: String {
        return switch self {
        case .terms: "Terms of Service"
        case .privacy: "Privacy Policy"
        case .about: "About"
        }
    }

    var showingTopView: Bool {
        let arr: [InfoType] = [.terms, .privacy]
        return arr.contains(self)
    }

    var topConstant: CGFloat {
        return switch self {
        case .terms: 71
        case .privacy: 71
        case .about: 31
        }
    }
}

class InfoVC: BackVC {

    @IBOutlet weak var backButton: UIButton!

    @IBOutlet weak var topTitleLabel: UILabel!

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var textView: UITextView!

    @IBOutlet weak var topTextViewConstraint: NSLayoutConstraint!

    var type: InfoType = .about

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setTargets()

        self.checkType()
    }

}

private extension InfoVC {
    func setTargets() {
        self.backButton.addTarget(self, action: #selector(backTouch), for: .touchUpInside)
    }

    func checkType() {
        self.topTitleLabel.text = self.type.title

        self.topView.isHidden = !self.type.showingTopView
        self.topTextViewConstraint.constant = self.type.topConstant

        self.textView.text = nil

        self.loadData()
    }

    func loadData() {
        AppService().info(type: self.type) { result in
            switch result {
            case .success(let info):
                if let textHtml = info.textEn {
                    var attribStr: NSMutableAttributedString? = nil

                    let textRangeForFont = NSMakeRange(0, attribStr?.length ?? 0)
                    if textHtml.isValidHtmlString {
                        attribStr = textHtml.data(using: .unicode, allowLossyConversion: true).flatMap {
                            try? NSMutableAttributedString(data: $0, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
                        }
                    } else {
                        attribStr = NSMutableAttributedString(string: textHtml)
                    }

                    attribStr?.addAttribute(.foregroundColor, value: UIColor.white.withAlphaComponent(0.5), range: textRangeForFont)
                    self.textView.attributedText = attribStr
                }
                if let dateChange = info.date, let date = dateChange.getDate {
                    self.changeLabel.text = "Last update : \(date.getStringDate())"
                } else {
                    self.changeLabel.text = nil
                }
                break
            case .failure(let error):
                self.showAlert(error.textError)
            }
        }
    }
}
extension InfoVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
}
