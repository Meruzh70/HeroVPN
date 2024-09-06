// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit.UIImage

// extension Data
extension Data {
    // function for get string from Data
    var toString: String? {
        return String(data: self, encoding: .utf8)
    }

    // function for get int from Data
    var toInt: Int? {
        return Int(String(data: self, encoding: .utf8) ?? "")
    }

    // function for get image from Data
    var toImage: UIImage? {
        return UIImage(data: self)
    }

    // function for get size Data as Mb
    var sizeMb: Float {
        let floatSizeMb = sizeKb / 1024
        return floatSizeMb
    }

    // function for get size Data as Kb
    var sizeKb: Float {
        let floatSizeKb = Float(Double(count) / 1024)
        return floatSizeKb
    }
}
