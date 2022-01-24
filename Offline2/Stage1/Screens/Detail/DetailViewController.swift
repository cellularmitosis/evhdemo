//
//  DetailViewController.swift
//  Stage1
//
//  Created by Jason Pepas on 1/21/22.
//

import UIKit


// MARK: - DetailViewController

/// Displays the details of a single post.
class DetailViewController: UIViewController {

    init(post: Post, users: [User], comments: [Comment]) {
        _post = post
        _users = users
        _comments = comments
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Internals

    private let _post: Post
    private let _users: [User]
    private let _comments: [Comment]
    
    private let _detailView = DetailView()
    
    private lazy var _failedView: FailedView = {
        let f = FailedView()
        f.isHidden = true
        return f
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"

        func assembleViewHierarchy() {
            for v in [_detailView, _failedView] {
                v.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(v)
                NSLayoutConstraint.activate([
                    v.topAnchor.constraint(equalTo: view.topAnchor),
                    v.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    v.leftAnchor.constraint(equalTo: view.leftAnchor),
                    v.rightAnchor.constraint(equalTo: view.rightAnchor)
                ])
            }
        }
        assembleViewHierarchy()

        guard let author = _users.filter({ $0.id == _post.userId }).first else {
            _failedView.isHidden = false
            return
        }
        
        let filteredComments = _comments.on(_post)

        _detailView.model = .populated(
            body: _post.body,
            authorName: author.name,
            commentCount: filteredComments.count
        )
    }
}
