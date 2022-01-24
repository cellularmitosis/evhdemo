//
//  LoadingView.swift
//  Stage1
//
//  Created by Jason Pepas on 1/22/22.
//

import UIKit


class LoadingView: UIView {
    
    // MARK: - Internals
    
    private lazy var _spinner: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(style: .large)
        a.startAnimating()
        return a
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        func assembleViewHierarchy() {
            for v in [_spinner] {
                v.translatesAutoresizingMaskIntoConstraints = false
                addSubview(v)
                NSLayoutConstraint.activate([
                    v.centerYAnchor.constraint(equalTo: centerYAnchor),
                    v.centerXAnchor.constraint(equalTo: centerXAnchor)
                ])
            }
        }
        assembleViewHierarchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
