// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import Foundation

class UserDefaultsManager {

    // keys for data
    struct UserDefaultsKeys {
        let firstEnter = "firstEnter"
        let curentPushToken = "curentPushToken"
        let lastUsedEmail = "lastUsedEmail"
        let timerStartConnection = "timerStartConnection"
    }

    // initialise
    static let shared = UserDefaultsManager()

    // property for storage
    private let userDefaults = UserDefaults.standard

    // property for keys
    private let keys = UserDefaultsKeys()

    private init() { }

    // property for current push token
    var curentPushToken: String {
        get {
            return userDefaults.string(forKey: keys.curentPushToken) ?? String()
        }
        set {
            userDefaults.set(newValue, forKey: keys.curentPushToken)
        }
    }

    // property for last used phone
    var lastUsedEmail: String {
        get {
            return userDefaults.string(forKey: keys.lastUsedEmail) ?? String()
        }
        set {
            userDefaults.set(newValue, forKey: keys.lastUsedEmail)
        }
    }

    // property for is first opening app
    var isFirstOpeningApp: Bool {
        if userDefaults.bool(forKey: keys.firstEnter) {
            return false
        } else {
            userDefaults.set(true, forKey: keys.firstEnter)
            return true
        }
    }

    var timerStartConnection: Double? {
        get {
            if let obj = userDefaults.object(forKey: keys.timerStartConnection) {
                return obj as? Double
            } else {
                return nil
            }
        }
        set {
            if let value = newValue {
                userDefaults.set(value, forKey: keys.timerStartConnection)
            } else {
                userDefaults.removeObject(forKey: keys.timerStartConnection)
            }
        }
    }
}
