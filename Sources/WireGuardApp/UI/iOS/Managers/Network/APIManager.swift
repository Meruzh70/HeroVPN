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
    func perform<T: URLRequestBuilder, U: Decodable>(service: T, decodeType: U.Type, completion: @escaping(ResultResponce<U>) -> Void) {
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
    func perform<T: URLRequestBuilder>(service: T, completion: @escaping(ResultResponce<Data>) -> Void) {
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

    // function for perform reqeust with service, decode type and completion with bool value
    func performResponse<T: URLRequestBuilder>(service: T, completion: @escaping(ResultResponce<Bool>) -> Void) {
        if let request = service.urlRequest, let url = request.url {
            print("Request for: \(url.absoluteString)")
        }
        session.request(service)
            .validate(statusCode: avalibelStatusCodes)
            .response { (response) in
                switch response.result {
                case .success:
                    if let resp = response.response {
                        if resp.statusCode == 200 {
                            completion(.succsess(true))
                        } else {
                            completion(.succsess(false))
                        }
                    }
                case .failure(let error):
                    completion(.failure(self.errorHandling(error: error, data: response.data)))
                }
        }
    }

    // function for perform with image with service, image data, decode type and completion with U value
    func performWithImage<T: URLRequestBuilder, U: Decodable>(service: T, imageData: Data?, decodeType: U.Type, completion: @escaping(ResultResponce<U>) -> Void) {
        session.upload(multipartFormData: { (multipartFormData) in
            if let imageData = imageData {
                multipartFormData.append(imageData, withName: "img", fileName: "img.jpeg", mimeType: "image/jpeg")
            }
            for (key, value) in service.parameters ?? [String: Any]() {
                if let data = ((value as? String)?.data(using: String.Encoding.utf8)) {
                    multipartFormData.append(data, withName: key)
                } else if let valueInt = (value as? Int), let data = "\(valueInt)".data(using: String.Encoding.utf8) {
                    multipartFormData.append(data, withName: key)
                } else if let array = value as? [Int] {
                    for (_,arrayValue) in array.enumerated() {
                        multipartFormData.append("\(arrayValue)".data(using: String.Encoding.utf8)!, withName: "\(key)[]")
                    }
                }
            }
        }, with: service)
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
//
//    // function for perform with image with service, image data, name field and completion with bool value
//    func performWithImageResponse<T: URLRequestBuilder>(service: T, imageData: Data?, nameField: String = "file", completion: @escaping(ResultResponce<Bool>) -> Void) {
//        if let request = service.urlRequest, let url = request.url {
//            print("Request for: \(url.absoluteString)")
//        }
//        session.upload(multipartFormData: { (multipartFormData) in
//            if let imageData = imageData {
//                multipartFormData.append(imageData, withName: nameField, fileName: "img.jpeg", mimeType: "image/jpeg")
//            }
//            for (key, value) in service.parameters ?? [String: Any]() {
//                if let data = ((value as? String)?.data(using: String.Encoding.utf8)) {
//                    multipartFormData.append(data, withName: key)
//                }
//            }
//        }, with: service, interceptor: refreshTokenManager)
//        .validate(statusCode: avalibelStatusCodes)
//        .response { (response) in
//            print("code: \(response.response?.statusCode)")
//            switch response.result {
//            case .success:
//                if let resp = response.response {
//                    if resp.statusCode == 200 {
//                        completion(.succsess(true))
//                    } else {
//                        completion(.succsess(false))
//                    }
//                }
//            case .failure(let error):
//                completion(.failure(self.errorHandling(error: error, data: response.data)))
//            }
//        }
//    }
//
//    // function for request image by URL with complition Data? value
//    func requestForImage(url: URL, complition: @escaping(ResultResponce<Data?>) -> Void) {
//        AF.request(url, method: .get).response { response in
//            switch response.result {
//            case .success(let data):
//                if let _ = KeychainManager.shared.authToken {
//                    complition(.succsess(data))
//                } else {
//                    print("user logout before load avatar")
//                }
//            case .failure(let error):
//                complition(.failure(self.errorHandling(error: error, data: response.data)))
//            }
//        }
//    }
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
