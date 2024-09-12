// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.
import Alamofire

enum AppApi: URLRequestBuilder {

    // types
    case login(email: String, password: String)
    case signUp(name: String, email: String, password: String)
    case connect
    case confirm(email: String, code: String)
    case forgot(email: String)
    case password(password: String)
    case tarrifs
    case promocode(code: String)

    // property for path
    var path: String {
        return switch self {
        case .login: "/login"
        case .signUp: "/user"
        case .connect: "/connect"
        case .confirm: "/confirm"
        case .forgot: "/forgot"
        case .password: "/password"
        case .tarrifs: "/tariffs"
        case .promocode: "/promocode"
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
        case .confirm(let email, let code):
            ["email": email,
             "code": code]
        case .forgot(let email):
            ["email": email]
        case .password(let password):
            ["password": password]
        case .tarrifs:
            nil
        case .promocode(let code):
            ["code": code]
        }
    }

    // property for method
    var method: HTTPMethod {
        return switch self {
        case .login, .signUp, .connect, .confirm, .forgot, .password, .promocode:
                .post
        case .tarrifs:
                .get
        }
    }
}
