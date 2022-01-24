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
