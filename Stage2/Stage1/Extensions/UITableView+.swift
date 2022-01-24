//
//  UITableView+.swift
//  Stage1
//
//  Created by Jason Pepas on 1/21/22.
//

import UIKit


extension UITableView {
    func deselectSelectedCells() {
        for i in indexPathsForSelectedRows ?? [] {
            deselectRow(at: i, animated: true)
        }
    }
}


protocol IReuseIdentifying: AnyObject {
    static var reuseIdentifier: String { get }
}


extension UITableView {
    func register(reuseIdentifiableClass: IReuseIdentifying.Type) {
        register(reuseIdentifiableClass, forCellReuseIdentifier: reuseIdentifiableClass.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: IReuseIdentifying>(at indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}
