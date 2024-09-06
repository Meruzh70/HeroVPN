// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import Foundation

// class for auth service
class AppService {

    // property api manager
    let apiManager = APIManager.shared

    // function for login by login and password with complition string result
    func login(email: String, password: String, complition: @escaping(ResultResponce<String>) -> Void) {
        let service: AppApi = .login(email: email, password: password)
//        apiManager.perform(service: service, decodeType: LoginEntity.self) { (result) in
//            switch result {
//            case .succsess(let loginResponse):
//                if let accessToken = loginResponse.data?.accessToken {
//                    KeychainManager.shared.authToken = accessToken
//                    complition(.succsess(accessToken))
//                } else {
//                    complition(.failure(.custom(loginResponse.tag, loginResponse.errors)))
//                }
//            case .failure(let error):
//                complition(.failure(error))
//            }
//        }
    }

    // function for logout with complition bool result
//    func logout(complition: @escaping(ResultResponce<Bool?>) -> Void) {
//        let service: AuthApi = .logout
//        apiManager.perform(service: service, decodeType: LoginEntity.self) { (result) in
//            switch result {
//            case .succsess(let login):
//                complition(.succsess(login.success))
//            case .failure(let error):
//                complition(.failure(error))
//            }
//        }
//    }
//
//    // function for refresh token with complition string result
//    func refreshToken(complition: @escaping(ResultResponce<String?>) -> Void) {
//        let service: AuthApi = .refreshToken
//        apiManager.perform(service: service, decodeType: LoginEntity.self) { (result) in
//            switch result {
//            case .succsess(let login):
//                complition(.succsess(login.data?.accessToken))
//            case .failure(let error):
//                complition(.failure(error))
//            }
//        }
//    }
//
//    // function for sendeing password by login with channel type with complition bool result
//    func password(login: String, channel: PasswordSendType, complition: @escaping(ResultResponce<Bool>) -> Void) {
//        let service: AuthApi = .password(login: login, channel: channel)
//        apiManager.performResponse(service: service) { (result) in
//            switch result {
//            case .succsess:
//                complition(.succsess(true))
//            case .failure(let error):
//                complition(.failure(error))
//            }
//        }
//    }
//
//    // function for get user role login with complition string result
//    func role(login: String, complition: @escaping(ResultResponce<String>) -> Void) {
//        let service: AuthApi = .role(login: login)
//        apiManager.perform(service: service, decodeType: RoleEntity.self) { (result) in
//            switch result {
//            case .succsess(let roleRespone):
//                if let role = roleRespone.role {
//                    complition(.succsess(role))
//                } else {
//                    if Config.shared.isAdminAuth {
//                        complition(.succsess(""))
//                    } else {
//                        complition(.failure(.custom(roleRespone.tag, roleRespone.errors)))
//                    }
//                }
//            case .failure(let error):
//                complition(.failure(error))
//            }
//        }
//    }
//
//    // function for login v2 (with code) by login password with complition string result
//    func loginV2(login: String, password: String, complition: @escaping(ResultResponce<String>) -> Void) {
//        let service: AuthApi = .loginV2(login: login, password: password)
//        apiManager.perform(service: service, decodeType: LoginEntity.self) { (result) in
//            switch result {
//            case .succsess(let loginResponse):
//                if let accessToken = loginResponse.data?.accessToken {
//                    KeychainManager.shared.authToken = accessToken
//                    complition(.succsess(accessToken))
//                } else {
//                    complition(.failure(.custom(loginResponse.tag, loginResponse.errors)))
//                }
//            case .failure(let error):
//                complition(.failure(error))
//            }
//        }
//    }
}
