// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import Foundation
import UIKit

extension String {
    // property app name
    static var appName: String {
        return Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "appName"
    }

    // property app version
    static var appVersion: String {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    // property app build
    static var appBuild: String {
        return Bundle.main.infoDictionary!["CFBundleVersion"] as? String ?? "1"
    }

    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }

    // function get string as bearer token = "bearer " + self string
    var bearer: String {
        return "Bearer \(self)"
    }

    // function get string from Data from self string
    var fromBase64: String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    // function get string base64 from Date from self string
    var toBase64: String {
        return Data(self.utf8).base64EncodedString()
    }

    var strikeAttributedString: NSMutableAttributedString {
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
        return attributeString
    }
}
