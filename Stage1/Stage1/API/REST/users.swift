//
//  users.swift
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


/// An individual user from /users.
/// Contract: all of these fields are non-optional.
struct User: Decodable {
    let id: Int
    let name: String
}


extension URLRequest {
    
    /// Returns a request for http://jsonplaceholder.typicode.com/users
    static func users() -> URLRequest {
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
        return URLRequest(
            url: url,
            cachePolicy: URLRequest.appDefaultCachePolicy,
            timeoutInterval: URLRequest.appDefaultTimeout
        )
    }
}


extension URLSession {
    
    /// Fetches http://jsonplaceholder.typicode.com/users.
    /// `completion` gets called on main thread.
    func getUsers(completion: @escaping (Result<[User], Error>)->()) {
        let request: URLRequest = .users()
        URLSession.shared.getDecodedJSONObject(request, completion: completion)
    }
}


/*
 Typical response:
 
 [
     {
         "id": 1,
         "name": "Leanne Graham",
         "username": "Bret",
         "email": "Sincere@april.biz",
         "address": {
             "street": "Kulas Light",
             "suite": "Apt. 556",
             "city": "Gwenborough",
             "zipcode": "92998-3874",
             "geo": {
                 "lat": "-37.3159",
                 "lng": "81.1496"
             }
         },
         "phone": "1-770-736-8031 x56442",
         "website": "hildegard.org",
         "company": {
            "name": "Romaguera-Crona",
            "catchPhrase": "Multi-layered client-server neural-net",
            "bs": "harness real-time e-markets"
         }
     },
 ...
 ]
 */
