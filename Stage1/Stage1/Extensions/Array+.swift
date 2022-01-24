//
//  Array+.swift
//  Stage1
//
//  Created by Jason Pepas on 1/21/22.
//

import Foundation


extension Array {
    
    /// Safe array access.
    func get(at index: Int?) -> Element? {
        guard let index = index, index >= 0, index < count else {
            return nil
        }
        return self[index]
    }
}
