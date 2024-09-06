// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.
import Alamofire

enum AppApi: URLRequestBuilder {

    // types
    case login(email: String, password: String)
    case signUp(name: String, email: String, password: String)
    case connect

    // property for path
    var path: String {
        return switch self {
        case .login: "/api/login"
        case .signUp: "/api/user"
        case .connect: "/auth/connect"
        }
    }

    // property for headers
    var headers: HTTPHeaders? {
        var headers = baseHeader
//        headers.add(.init(name: "X-Requested-With", value: "XMLHttpReques"))
        return headers
    }

    // property for parameters
    var parameters: Parameters? {
        return switch self {
        case .login(let email, let password):
            ["email": email,
             "password": password]
        case .signUp(let name, let email, let password):
            ["name": name,
             "email": email,
             "password": password]
        case .connect:
            nil
        }
    }

    // property for method
    var method: HTTPMethod {
        return switch self {
        case .login, .signUp, .connect:
            .post
        }
    }
}
