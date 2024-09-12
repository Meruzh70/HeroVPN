// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit

class TarifTableViewCell: UITableViewCell {

    @IBOutlet weak var backView: UIView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var checkImageView: UIImageView?
    @IBOutlet weak var currentPriceLabel: UILabel?
    @IBOutlet weak var pricePerTimeLabel: UILabel?
    @IBOutlet weak var mainPriceLabel: UILabel?

    fileprivate var currency = "$"

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backView?.layer.cornerRadius = 16
        self.backView?.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }

    func setup(data: Tarif, isSelected: Bool) {
        self.titleLabel?.text = data.nameEn
        self.pricePerTimeLabel?.text = "/ \(data.nameEn)"
        if let priceDiscount = data.priceDiscount {
            self.currentPriceLabel?.text = "\(currency)\(priceDiscount.stringValue)"
            self.mainPriceLabel?.attributedText = "\(currency)\(data.price.stringValue)".strikeAttributedString
            self.mainPriceLabel?.isHidden = false
        } else {
            self.currentPriceLabel?.text = "\(currency)\(data.price.stringValue)"
            self.mainPriceLabel?.isHidden = true
        }
        checkImageView?.image = isSelected ? UIImage(named: "check") : UIImage(named: "uncheck")

        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.backgroundView?.frame.width ?? 100, height: self.backgroundView?.frame.height ?? 10))
        view.backgroundColor = UIColor.clear
        self.selectedBackgroundView = view
    }

}
