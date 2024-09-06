// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.
import UIKit

class Utils {

    static let shared = Utils()

    private init(){}

    enum Storyboards: String {
        case main = "Main"
    }

    func mainStoryboard() -> UIStoryboard {
        return makeStoryboard(from: Storyboards.main)
    }

    func makeStoryboard(from name: Storyboards) -> UIStoryboard {
        return UIStoryboard(name: name.rawValue, bundle: nil)
    }

}
