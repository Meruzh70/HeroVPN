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
    case custom(String?, [String]?)

    var textError: String {
        return switch self {
        case .serverNotResponding: "serverNotResponding"
        case .noInternetConnection: "noInternetConnection"
        case .accessDenied: "accessDenied"
        case .tooManyRequest: "tooManyRequest"
        case .invalidCredentials: "invalidCredentials"
        case .expiredTemporary: "expiredTemporary"
        case .custom(let title, let errors): "\(title ?? ""). \(errors?.joined(separator: ";") ?? "")"
        }
    }
}
