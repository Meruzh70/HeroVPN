// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import Alamofire

// singletone class manager for API
class APIManager {

    // initialise
    static let shared = APIManager()

    // property for lock the queue
    private let lock = NSLock()
    // proprety for success status codes
    private var avalibelStatusCodes = [200, 201]
    // property for session
    private var session: Session

    // initialise
    private init() {
        let rootQueue = DispatchQueue(label: "apiManagerQueue")
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.underlyingQueue = rootQueue
        let delegate = SessionDelegate()
        let configuration = URLSessionConfiguration.af.default
        let urlSession = URLSession(configuration: configuration, delegate: delegate, delegateQueue: queue)
        session = Session(session: urlSession, delegate: delegate, rootQueue: rootQueue)
    }

    // function for perform reqeust with service, decode type and completion with U value
    func perform<T: URLRequestBuilder, U: Decodable>(service: T, decodeType: U.Type, completion: @escaping (ResultResponce<U>) -> Void) {
        lock.lock(); defer { lock.unlock() }
        if let request = service.urlRequest, let url = request.url {
            print("Request for: \(url.absoluteString)")
        }
        session.request(service)
            .validate(statusCode: avalibelStatusCodes)
            .responseDecodable(of: U.self) { (response) in
            switch response.result {
            case .success(let result):
                completion(.succsess(result))
            case .failure(let error):
                completion(.failure(self.errorHandling(error: error, data: response.data)))
            }
        }
    }

    // function for perform reqeust with service and completion with data value
    func perform<T: URLRequestBuilder>(service: T, completion: @escaping (ResultResponce<Data>) -> Void) {
        if let request = service.urlRequest, let url = request.url {
            print("Request for: \(url.absoluteString)")
        }
        session.request(service)
            .validate(statusCode: avalibelStatusCodes)
            .responseData { (response) in
                switch response.result {
                case .success(let data):
                    completion(.succsess(data))
                case .failure(let error):
                    completion(.failure(self.errorHandling(error: error, data: response.data)))
                }
        }
    }
}

// MARK: - Private Methods
extension APIManager {
    // property indicate that internet is connected and word
    var isConnectedToInternet: Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }

    // function for handling error by AFError and Data, return ResponseError
    func errorHandling(error: AFError, data: Data?) -> ResponseError {
        var textErrors: [String] = []
        if let data = data {
            let str = String(decoding: data, as: UTF8.self)
            print(str)
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject], let errors = jsonArray["errors"] as? [String] {
                    textErrors = errors
                    print(textErrors)
                }
            } catch let err as NSError {
                print(err)
            }
        }

        if textErrors.isEmpty {
            return .custom("", textErrors)
        } else {
            switch error.responseCode {
            case 401: return .accessDenied
            case 422: return .invalidCredentials
            case 429: return .tooManyRequest
            case 498: return .expiredTemporary
            default: return isConnectedToInternet ? .serverNotResponding : .noInternetConnection
            }
        }
    }
}
