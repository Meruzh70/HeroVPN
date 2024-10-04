// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import Alamofire

// protocol for default requst to server
protocol URLRequestBuilder: URLRequestConvertible {
    var baseUrl: String { get }
    var path: String { get }
    var headers: HTTPHeaders? { get }
    var parameters: Parameters? { get }
    var method: HTTPMethod { get }
}

// extension for URLRequestBuilder for default values
extension URLRequestBuilder {
    // property for base url
    var baseUrl: String {
//        return "https://app.vpnhero.am"
        return "https://dev.vpnhero.am"
    }

    // property for base header
    var baseHeader: HTTPHeaders {
        var headers = HTTPHeaders.init()
//        var uuid = UIDevice.current.identifierForVendor?.uuidString ?? ""
        if let authToken = KeychainManager.shared.authToken {
            headers.add(.authorization(authToken.bearer))
        }
        headers.add(.accept("application/json"))
//        headers.add(.init(name: "Accept-Language", value: Text.acceptLanguage.key.localized()))
//
//        headers.add(.init(name: "Device-Id", value: uuid))
//        headers.add(.init(name: "App-Version", value: Config.shared.appVersion))
//        headers.add(.init(name: "Platform", value: "ios"))
//        headers.add(.init(name: "OS-Version", value: Config.shared.osVersion))
//        headers.add(.init(name: "Device-Model", value: Config.shared.deviceName))
//        headers.add(.init(name: "App-Env", value: Config.shared.appConfiguration == .appStore ? "prod" : "dev"))
        return headers
    }

    // property for conver object to URLRequest
    func asURLRequest() throws -> URLRequest {
        var url = try baseUrl.asURL()
        url = url.appendingPathComponent("/api")
        url = url.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if let headers = headers {
            request.headers = headers
        }

        switch method {
        case .get:
            request = try URLEncoding.default.encode(request, with: parameters)
        case.post:
            request = try URLEncoding.default.encode(request, with: parameters)
        default:
            break
        }
        return request
    }
}
