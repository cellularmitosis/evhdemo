//
//  DetailView.swift
//  Stage1
//
//  Created by Jason Pepas on 1/22/22.
//

import UIKit


/// The primary view of DetailsViewController.
class DetailView: UIView {
    
    enum Model: Equatable {
        case empty
        case populated(body: String, authorName: String, commentCount: Int)
    }
    
    var model: Model = .empty {
        didSet {
            _apply(model: model, oldModel: oldValue)
        }
    }

    // MARK: - Internals
    
    private lazy var _bodyLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 18)
        l.numberOfLines = 0
        return l
    }()
    
    private lazy var _authorLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.italicSystemFont(ofSize: 14)
        l.adjustsFontSizeToFitWidth = true
        l.textAlignment = .right
        return l
    }()

    private lazy var _commentCountLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12)
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground

        func assembleViewHierarchy() {
            let guide = layoutMarginsGuide

            for v in [_bodyLabel] {
                v.translatesAutoresizingMaskIntoConstraints = false
                addSubview(v)
                NSLayoutConstraint.activate([
                    v.topAnchor.constraint(equalTo: guide.topAnchor, constant: 16),
                    v.leftAnchor.constraint(equalTo: guide.leftAnchor),
                    v.rightAnchor.constraint(equalTo: guide.rightAnchor)
                ])
            }

            for v in [_authorLabel] {
                v.translatesAutoresizingMaskIntoConstraints = false
                addSubview(v)
                NSLayoutConstraint.activate([
                    v.topAnchor.constraint(equalTo: _bodyLabel.bottomAnchor, constant: 16),
                    v.leftAnchor.constraint(equalTo: guide.leftAnchor),
                    v.rightAnchor.constraint(equalTo: guide.rightAnchor)
                ])
            }
            
            for v in [_commentCountLabel] {
                v.translatesAutoresizingMaskIntoConstraints = false
                addSubview(v)
                NSLayoutConstraint.activate([
                    v.topAnchor.constraint(equalTo: _authorLabel.bottomAnchor, constant: 16),
                    v.leftAnchor.constraint(equalTo: guide.leftAnchor),
                    v.rightAnchor.constraint(equalTo: guide.rightAnchor)
                ])
            }
        }
        assembleViewHierarchy()
        
        _apply(model: model, oldModel: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func _apply(model: Model, oldModel: Model?) {
        guard model != oldModel else {
            return
        }
        
        switch model {
            
        case .empty:
            _authorLabel.text = nil
            _bodyLabel.text = nil
            _commentCountLabel.text = nil
            
        case .populated(let body, let authorName, let commentCount):
            _authorLabel.text = "by \(authorName)"
            _bodyLabel.text = body.replacingOccurrences(of: "\n", with: "\n\n")

            switch commentCount {
            case 0:
                _commentCountLabel.text = "No comments"
            case 1:
                _commentCountLabel.text = "1 comment"
            default:
                _commentCountLabel.text = "\(commentCount) comments"
            }
        }
    }
}
