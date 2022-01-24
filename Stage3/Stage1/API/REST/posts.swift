//
//  posts.swift
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


/// An individual post from /posts.
/// Contract: all of these fields are non-optional.
struct Post: Decodable, Equatable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}


extension URLRequest {
    
    /// Returns a request for http://jsonplaceholder.typicode.com/posts
    static func posts() -> URLRequest {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        return URLRequest(
            url: url,
            cachePolicy: URLRequest.appDefaultCachePolicy,
            timeoutInterval: URLRequest.appDefaultTimeout
        )
    }
}


extension URLSession {
    
    /// Fetches http://jsonplaceholder.typicode.com/posts.
    /// `completion` gets called on main thread.
    func getPosts(completion: @escaping (Result<[Post], Error>)->()) {
        let request: URLRequest = .posts()
        URLSession.shared.getDecodedJSONObject(request, completion: completion)
    }
}


/*
 Typical response:
 
 [
    {
        "userId": 1,
        "id": 1,
        "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
        "body": "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
    },
    ...
 ]
 */
