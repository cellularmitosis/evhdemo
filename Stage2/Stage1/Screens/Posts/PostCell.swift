//
//  PostCell.swift
//  Stage1
//
//  Created by Jason Pepas on 1/22/22.
//

import UIKit


// MARK: - PostCell

/// A row in the table on the Posts screen.
class PostCell: UITableViewCell, IReuseIdentifying {
    
    static let reuseIdentifier: String = "PostCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textLabel?.font = .systemFont(ofSize: 16)
        textLabel?.numberOfLines = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
