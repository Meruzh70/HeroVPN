// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit

class SubscribtionManager {
    static let shared = SubscribtionManager()

    init() { }

    weak var controller: UIViewController?

    func getStatus() {
        AppService().getStatus(complition: { result in
            switch result {
            case .succsess(let statusEntity):
                UserDefaultsManager.shared.timerFinishSubscribtion = statusEntity.isSuccess ? Date().timeIntervalSince1970 + Double(statusEntity.secLeft ?? 0) : nil

                NotificationCenter.default.post(name: .finishSubscribtionUpdated, object: nil)
            case .failure(let error):
                self.controller?.showAlert(error.textError)
            }
        })
    }
}
