// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import Foundation

// types for result response
enum ResultResponce<T: Decodable> {
    case succsess(T)
    case failure(ResponseError)
}

// types for response error
enum ResponseError {
    case serverNotResponding
    case noInternetConnection
    case accessDenied
    case tooManyRequest
    case invalidCredentials
    case expiredTemporary
    case exist
    case custom(String?, [String]?)

    var textError: String {
        switch self {
        case .serverNotResponding: return "serverNotResponding"
        case .noInternetConnection: return "noInternetConnection"
        case .accessDenied: return "accessDenied"
        case .tooManyRequest: return "tooManyRequest"
        case .invalidCredentials: return "invalidCredentials"
        case .expiredTemporary: return "expiredTemporary"
        case .exist: return "User already exist"
        case .custom(let title, let errors):
            print("custom error: \(title). \(errors?.joined(separator: ";"))")
            return (errors?.isEmpty ?? true) ? "\(title ?? "")" : "\(title ?? ""). \(errors?.joined(separator: ";") ?? "")"
        }
    }
}
