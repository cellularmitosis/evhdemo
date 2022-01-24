//
//  Store.swift
//  Stage1
//
//  Created by Jason Pepas on 1/23/22.
//

import Foundation


// MARK: - Store

/// Basic persistence layer.
class Store {
    
    func get() -> PostsViewController.State.Complete? {
        guard let data = UserDefaults.standard.data(forKey: Self.key) else {
            return nil
        }
        return try? JSONDecoder().decode(PostsViewController.State.Complete.self, from: data)
    }
    
    func set(_ object: PostsViewController.State.Complete) {
        do {
            let data = try JSONEncoder().encode(object)
            UserDefaults.standard.set(data, forKey: Self.key)
        } catch {
            print("⚠️ Warning: Store.set() can't encode object!")
        }
    }
    
    // MARK: - Internals
    
    private static let key: String = "Store.Complete"
}
