// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import Foundation

class KeychainManager {

    // keys for data
    struct KeychainKeys {
        let authToken = "authToken"
    }

    // initialise
    static let shared = KeychainManager()
    private init() {}

    // property for keys
    private let keys = KeychainKeys()

    // property for auth token
    var authToken: String? {
        get {
            return load(key: keys.authToken)?.toString
        }
        set {
            if let newValue = newValue,
               let valueData = newValue.data(using: .utf8) {
                _ = save(key: keys.authToken, data: valueData)
            }
        }
    }

    // function for remove all data
    func removeAll() {
        deleteAllData()
    }
}

// MARK: - Base keychain metods
private extension KeychainManager {
    // function for save data by key
    func save(key: String, data: Data) -> OSStatus {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key,
            kSecValueData as String: data ] as [String: Any]

        SecItemDelete(query as CFDictionary)

        return SecItemAdd(query as CFDictionary, nil)
    }

    // function for get data by key
    func load(key: String) -> Data? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne ] as [String: Any]

        var dataTypeRef: AnyObject?

        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr {
            return dataTypeRef as? Data
        } else {
            return nil
        }
    }

    // function for remove data from storage
    func deleteAllData() {
        let secItemClasses = [kSecClassGenericPassword, kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity]
        for itemClass in secItemClasses {
            let spec: NSDictionary = [kSecClass: itemClass]
            SecItemDelete(spec)
        }
    }
}
