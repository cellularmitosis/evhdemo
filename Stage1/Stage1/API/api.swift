//
//  api.swift
//  Stage1
//
//  Created by Jason Pepas on 1/21/22.
//

import Foundation


fileprivate let debugEnabled = false
fileprivate func debug(_ message: String) {
    if debugEnabled {
        print(message)
    }
}


// MARK: - HTTPError

enum HTTPError: Error {
    case responseWasNil
    case dataWasNil
    case badHTTPStatusCode(code: Int)
}


// MARK: - URLRequest

extension URLRequest {

    static var appDefaultCachePolicy: NSURLRequest.CachePolicy {
        return .useProtocolCachePolicy
    }
    
    static var appDefaultTimeout: TimeInterval {
        return 3
    }
}


// MARK: - URLSession

extension URLSession {
    
    /// Generic JSON fetching / decoding.
    /// `completion` gets called on main thread.
    func getDecodedJSONObject<T: Decodable>(_ request: URLRequest, completion: @escaping (Result<T, Error>)->()) {
        let task = dataTask(with: request) { maybeData, maybeResponse, maybeError in
            if let error = maybeError {
                DispatchQueue.main.async {
                    print("❌ \(#function): error: \(error), url: \(request.url!.absoluteString)")
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = maybeResponse as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    print("❌ \(#function): response was nil.")
                    completion(.failure(HTTPError.responseWasNil))
                }
                return
            }
            
            guard 200..<400 ~= httpResponse.statusCode else {
                DispatchQueue.main.async {
                    print("❌ \(#function): bad HTTP status: \(httpResponse.statusCode).")
                    completion(.failure(HTTPError.badHTTPStatusCode(code: httpResponse.statusCode)))
                }
                return
            }
            
            guard let data = maybeData else {
                DispatchQueue.main.async {
                    print("❌ \(#function): data was nil.")
                    completion(.failure(HTTPError.dataWasNil))
                }
                return
            }

            do {
                let object = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    debug("✅ \(#function), object:\n\(object)")
                    completion(.success(object))
                }
            } catch {
                DispatchQueue.main.async {
                    print("❌ \(#function): JSON decoding error: \(error).")
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}


// MARK: - IAPI

protocol IAPI {
    func getPosts(completion: @escaping (Result<[Post], Error>)->())
    func getUsers(completion: @escaping (Result<[User], Error>)->())
    func getComments(completion: @escaping (Result<[Comment], Error>)->())
}


// MARK: - URLSessionAPI

class URLSessionAPI: IAPI {
    func getPosts(completion: @escaping (Result<[Post], Error>) -> ()) {
        URLSession.shared.getPosts(completion: completion)
    }
    
    func getUsers(completion: @escaping (Result<[User], Error>) -> ()) {
        URLSession.shared.getUsers(completion: completion)
    }
    
    func getComments(completion: @escaping (Result<[Comment], Error>) -> ()) {
        URLSession.shared.getComments(completion: completion)
    }
}


// MARK: - FailingAPI

class FailingAPI: IAPI {
    func getPosts(completion: @escaping (Result<[Post], Error>) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let error = HTTPError.badHTTPStatusCode(code: 500)
            print("❌ \(#function): error: \(error)")
            completion(.failure(error))
        }
    }
    
    func getUsers(completion: @escaping (Result<[User], Error>) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let error = HTTPError.badHTTPStatusCode(code: 500)
            print("❌ \(#function): error: \(error)")
            completion(.failure(error))
        }
    }
    
    func getComments(completion: @escaping (Result<[Comment], Error>) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let error = HTTPError.badHTTPStatusCode(code: 500)
            print("❌ \(#function): error: \(error)")
            completion(.failure(error))
        }
    }
}
