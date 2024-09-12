// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import Foundation

// class for auth service
class AppService {

    // property api manager
    let apiManager = APIManager.shared

    // function for login by login and password with complition string result
    func login(email: String, password: String, complition: @escaping (ResultResponce<String?>) -> Void) {
        let service: AppApi = .login(email: email, password: password)
        apiManager.perform(service: service, decodeType: AuthEntity.self) { (result) in
            switch result {
            case .succsess(let loginResponse):
                if let token = loginResponse.token {
                    KeychainManager.shared.authToken = token
                    complition(.succsess(loginResponse.name))
                } else {
                    complition(.failure(.custom(loginResponse.message, [])))
                }
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }

    // function for register by name, email and password with complition string result
    func register(name: String, email: String, password: String, complition: @escaping (ResultResponce<Bool>) -> Void) {
        let service: AppApi = .signUp(name: name, email: email, password: password)
        apiManager.perform(service: service, decodeType: RegEntity.self) { (result) in
            switch result {
            case .succsess(let loginResponse):
                if loginResponse.sended ?? false {
                    complition(.succsess(true))
                } else if loginResponse.exist ?? false {
                    complition(.failure(.custom("User has been already registered. Log in", [])))
                } else {
                    complition(.failure(.custom(loginResponse.message, [])))
                }
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }

    // function for confirm email by code with complition string result
    func confirm(email: String, code: String, complition: @escaping (ResultResponce<String?>) -> Void) {
        let service: AppApi = .confirm(email: email, code: code)
        apiManager.perform(service: service, decodeType: AuthEntity.self) { (result) in
            switch result {
            case .succsess(let loginResponse):
                if let token = loginResponse.token {
                    KeychainManager.shared.authToken = token
                    complition(.succsess(loginResponse.name))
                } else {
                    complition(.failure(.custom(loginResponse.message, [])))
                }
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }

    // function for forgot email with complition bool result
    func forgot(email: String, complition: @escaping (ResultResponce<Bool>) -> Void) {
        let service: AppApi = .forgot(email: email)
        apiManager.perform(service: service, decodeType: DefaultEntity.self) { (result) in
            switch result {
            case .succsess(_):
                complition(.succsess(true))
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }

    func password(password: String, complition: @escaping (ResultResponce<Bool>) -> Void) {
        let service: AppApi = .password(password: password)
        apiManager.perform(service: service, decodeType: DefaultEntity.self) { (result) in
            switch result {
            case .succsess(_):
                complition(.succsess(true))
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }

    func tarrifs(complition: @escaping (ResultResponce<[String]>) -> Void) {
        let service: AppApi = .tarrifs
        apiManager.perform(service: service, decodeType: DefaultEntity.self) { (result) in

        }
    }

    func promocode(code: String, complition: @escaping (ResultResponce<[String]>) -> Void) {
        let service: AppApi = .promocode(code: code)
        apiManager.perform(service: service, decodeType: DefaultEntity.self) { (result) in

        }
    }

    func getConfig(complition: @escaping (ResultResponce<Data>) -> Void) {
        let service: AppApi = .connect
        apiManager.perform(service: service) { result in
            complition(result)
        }
    }
}
