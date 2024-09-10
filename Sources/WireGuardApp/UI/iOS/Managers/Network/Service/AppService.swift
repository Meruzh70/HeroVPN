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
    func register(name: String, email: String, password: String, complition: @escaping (ResultResponce<String?>) -> Void) {
        let service: AppApi = .signUp(name: name, email: email, password: password)
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

    func getConfig(complition: @escaping (ResultResponce<Data>) -> Void) {
        let service: AppApi = .connect
        apiManager.perform(service: service) { result in
            complition(result)
        }
    }
}
