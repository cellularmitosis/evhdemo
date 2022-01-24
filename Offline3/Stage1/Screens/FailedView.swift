//
//  FailedView.swift
//  Stage1
//
//  Created by Jason Pepas on 1/22/22.
//

import UIKit


class FailedView: UIView {
    
    var didTap: (()->Void)? = nil
    
    // MARK: - Internals
    
    private lazy var _errorLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 36)
        l.text = "😭"
        return l
    }()
    
    private lazy var _button: UIButton = {
        let b = UIButton(type: .custom)
        b.addTarget(self, action: #selector(_buttonDidGetTapped), for: .touchUpInside)
        return b
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        func assembleViewHierarchy() {
            for v in [_errorLabel] {
                v.translatesAutoresizingMaskIntoConstraints = false
                addSubview(v)
                NSLayoutConstraint.activate([
                    v.centerYAnchor.constraint(equalTo: centerYAnchor),
                    v.centerXAnchor.constraint(equalTo: centerXAnchor)
                ])
            }
            
            for v in [_button] {
                v.translatesAutoresizingMaskIntoConstraints = false
                addSubview(v)
                NSLayoutConstraint.activate([
                    v.topAnchor.constraint(equalTo: topAnchor),
                    v.bottomAnchor.constraint(equalTo: bottomAnchor),
                    v.leftAnchor.constraint(equalTo: leftAnchor),
                    v.rightAnchor.constraint(equalTo: rightAnchor)
                ])
            }
        }
        assembleViewHierarchy()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func _buttonDidGetTapped() {
        didTap?()
    }
}
