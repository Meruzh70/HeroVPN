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
            case .success(let loginResponse):
                if let token = loginResponse.token {
                    print("token: \(token)")
                    KeychainManager.shared.authToken = token
                    complition(.success(loginResponse.name))
                } else {
                    complition(.failure(.custom(loginResponse.message, [])))
                }
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }

    // function for login by name and apple token with complition string result
    func loginApple(name: String, appleToken: String, complition: @escaping (ResultResponce<String?>) -> Void) {
        let service: AppApi = .loginApple(name: name, appleToken: appleToken)
        apiManager.perform(service: service, decodeType: AuthEntity.self) { (result) in
            switch result {
            case .success(let loginResponse):
                if let token = loginResponse.token {
                    print("token: \(token)")
                    KeychainManager.shared.authToken = token
                    complition(.success(loginResponse.name))
                } else {
                    complition(.failure(.custom(loginResponse.message, [])))
                }
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }

    // function for login by login and password with complition string result
    func pushToken(pushToken: String, complition: @escaping (ResultResponce<Bool>) -> Void) {
        let service: AppApi = .pushToken(token: pushToken)
        apiManager.perform(service: service, decodeType: DefaultEntity.self) { (result) in
            switch result {
            case .success(let defaultResponse):
                complition(.success(defaultResponse.isSuccess))
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
            case .success(let loginResponse):
                if loginResponse.sended ?? false {
                    complition(.success(true))
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
            case .success(let loginResponse):
                if let token = loginResponse.token {
                    KeychainManager.shared.authToken = token
                    complition(.success(loginResponse.name))
                } else {
                    complition(.failure(.custom(loginResponse.message, [])))
                }
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }

    // function for forgot by email with complition bool result
    func forgot(email: String, complition: @escaping (ResultResponce<Bool>) -> Void) {
        let service: AppApi = .forgot(email: email)
        apiManager.perform(service: service, decodeType: DefaultEntity.self) { (result) in
            switch result {
            case .success(_):
                complition(.success(true))
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }

    // function for change password by password with complition Bool result
    func password(password: String, complition: @escaping (ResultResponce<Bool>) -> Void) {
        let service: AppApi = .password(password: password)
        apiManager.perform(service: service, decodeType: DefaultEntity.self) { (result) in
            switch result {
            case .success(_):
                complition(.success(true))
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }

    // function for get tarifs with complition [Tarift] result
    func getTarifs(complition: @escaping (ResultResponce<[Tarif]>) -> Void) {
        let service: AppApi = .tarrifs
        apiManager.perform(service: service, decodeType: TarifEntity.self) { (result) in
            switch result {
            case .success(let tarifResponse):
                complition(.success(tarifResponse.result))
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }

    // function for register promocode by code with complition bool result
    func promocode(code: String, complition: @escaping (ResultResponce<Bool>) -> Void) {
        let service: AppApi = .promocode(code: code)
        apiManager.perform(service: service, decodeType: DefaultEntity.self) { (result) in
            switch result {
            case .success(let defaultResponse):
                complition(.success(defaultResponse.isSuccess))
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }

    // function for get config with complition Data result
    func getConfig(complition: @escaping (ResultResponce<Data>) -> Void) {
        let service: AppApi = .connect
        apiManager.perform(service: service) { result in
            complition(result)
        }
    }

    // function for get status subscribe with complition bool result
    func getStatus(complition: @escaping (ResultResponce<StatusEntity>) -> Void) {
        let service: AppApi = .status
        apiManager.perform(service: service, decodeType: StatusEntity.self) { (result) in
            complition(result)
        }
    }

    // function for subsribe by transactionId, uniqId, cost and created with complition bool result
    func subsribe(transactionId: String, uniqId: String, cost: Float, created: Double, complition: @escaping (ResultResponce<Bool>) -> Void) {
        let service: AppApi = .subscribe(transactionId: transactionId, uniqId: uniqId, cost: cost, created: created)
        apiManager.perform(service: service, decodeType: DefaultEntity.self) { (result) in
            switch result {
            case .success(let defaultResponse):
                complition(.success(defaultResponse.isSuccess))
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }

    // functuon for delete user
    func delete(complition: @escaping (ResultResponce<Bool>) -> Void) {
        let service: AppApi = .delete
        apiManager.perform(service: service, decodeType: DefaultEntity.self) { (result) in
            switch result {
            case .success(let defaultResponse):
                complition(.success(defaultResponse.isSuccess))
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
}
