//
//  comments.swift
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


/// An individual comment from /comments.
/// Contract: all of these fields are non-optional.
struct Comment: Decodable {
    let id: Int
    let postId: Int
}


extension URLRequest {
    
    /// Returns a request for http://jsonplaceholder.typicode.com/comments
    static func comments() -> URLRequest {
        let url = URL(string: "https://jsonplaceholder.typicode.com/comments")!
        return URLRequest(
            url: url,
            cachePolicy: URLRequest.appDefaultCachePolicy,
            timeoutInterval: URLRequest.appDefaultTimeout
        )
    }
}


extension URLSession {
    
    /// Fetches http://jsonplaceholder.typicode.com/comments.
    /// `completion` gets called on main thread.
    func getComments(completion: @escaping (Result<[Comment], Error>)->()) {
        let request: URLRequest = .comments()
        URLSession.shared.getDecodedJSONObject(request, completion: completion)
    }
}


/*
 Typical response:
 
 [
    {
        "postId": 1,
        "id": 1,
        "name": "id labore ex et quam laborum",
        "email": "Eliseo@gardner.biz",
        "body": "laudantium enim quasi est quidem magnam voluptate ipsam eos\ntempora quo necessitatibus\ndolor quam autem quasi\nreiciendis et nam sapiente accusantium"
    },
    ...
 ]
 */


extension Array where Element == Comment {

    /// Returns the comments on a particular post.
    func on(_ post: Post) -> [Comment] {
        return filter { $0.postId == post.id }
    }
}
