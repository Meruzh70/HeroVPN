// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.
import Alamofire

enum AppApi: URLRequestBuilder {

    // types
    case login(email: String, password: String)
    case signUp(name: String, email: String, password: String)
    case loginApple(name: String, appleToken: String)
    case pushToken(token: String)
    case connect
    case confirm(email: String, code: String)
    case forgot(email: String)
    case password(password: String)
    case tarrifs
    case promocode(code: String)
    case status
    case subscribe(transactionId: String, uniqId: String, cost: Float, created: Double)
    case delete

    // property for path
    var path: String {
        return switch self {
        case .login: "/login"
        case .loginApple: "/user/apple"
        case .pushToken: "/user/push"
        case .signUp: "/user"
        case .connect: "/connect"
        case .confirm: "/confirm"
        case .forgot: "/forgot"
        case .password: "/password"
        case .tarrifs: "/tariffs"
        case .promocode: "/promocode"
        case .status: "/status"
        case .subscribe: "/subscribe"
        case .delete: "/user"
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
        case .loginApple(let name, let appleToken):
            ["name": name,
             "token": appleToken]
        case .pushToken(let token):
            ["token": token]
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
        case .status:
            nil
        case .subscribe(let transactionId, let uniqId, let cost, let created):
            ["transaction_id": transactionId,
             "uniq_id": uniqId,
             "cost": cost,
             "created": created]
        case .delete:
            nil
        }
    }

    // property for method
    var method: HTTPMethod {
        return switch self {
        case .login, .loginApple, .pushToken, .signUp, .connect, .confirm, .forgot, .password, .promocode, .subscribe:
                .post
        case .tarrifs, .status:
                .get
        case .delete: .delete
        }
    }
}
