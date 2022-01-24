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

    init(post: Post, api: IAPI) {
        _post = post
        _api = api
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Internals

    private let _post: Post
    private let _api: IAPI

    private var _users: [User]? = nil
    private var _comments: [Comment]? = nil

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

    private lazy var _spinner: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(style: .large)
        a.hidesWhenStopped = true
        return a
    }()
    
    private lazy var _errorLabel: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 36)
        return l
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"
        view.backgroundColor = .systemBackground

        func assembleViewHierarchy() {
            let guide = view.layoutMarginsGuide

            for v in [_bodyLabel] {
                v.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(v)
                NSLayoutConstraint.activate([
                    v.topAnchor.constraint(equalTo: guide.topAnchor, constant: 16),
                    v.leftAnchor.constraint(equalTo: guide.leftAnchor),
                    v.rightAnchor.constraint(equalTo: guide.rightAnchor)
                ])
            }

            for v in [_authorLabel] {
                v.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(v)
                NSLayoutConstraint.activate([
                    v.topAnchor.constraint(equalTo: _bodyLabel.bottomAnchor, constant: 16),
                    v.leftAnchor.constraint(equalTo: guide.leftAnchor),
                    v.rightAnchor.constraint(equalTo: guide.rightAnchor)
                ])
            }
            
            for v in [_commentCountLabel] {
                v.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(v)
                NSLayoutConstraint.activate([
                    v.topAnchor.constraint(equalTo: _authorLabel.bottomAnchor, constant: 16),
                    v.leftAnchor.constraint(equalTo: guide.leftAnchor),
                    v.rightAnchor.constraint(equalTo: guide.rightAnchor)
                ])
            }

            for v in [_spinner, _errorLabel] {
                v.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(v)
                NSLayoutConstraint.activate([
                    v.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                    v.centerXAnchor.constraint(equalTo: view.centerXAnchor)
                ])
            }
        }
        assembleViewHierarchy()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(_applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        // When focused, refresh if needed.
        if _users == nil || _comments == nil {
            _fetchData()
        }
    }
    
    @objc
    private func _applicationDidBecomeActive() {
        // When app is foregrounded, unconditionally refresh.
        _fetchData()
    }

    private func _fetchData() {

        func showLoadingState() {
            _spinner.startAnimating()
            _errorLabel.text = nil
        }
        
        func showErrorState() {
            _spinner.stopAnimating()
            _errorLabel.text = "😭"
        }
        
        func showPopulatedState(users: [User], comments: [Comment]) {
            _spinner.stopAnimating()
            _errorLabel.text = nil
            
            guard let user = users.filter({ $0.id == _post.userId }).first else {
                showErrorState()
                return
            }
            
            _authorLabel.text = "by \(user.name)"
            _bodyLabel.text = _post.body.replacingOccurrences(of: "\n", with: "\n\n")

            let commentCount = comments.on(_post).count
            switch commentCount {
            case 0:
                _commentCountLabel.text = "No comments"
            case 1:
                _commentCountLabel.text = "1 comment"
            default:
                _commentCountLabel.text = "\(commentCount) comments"
            }
        }

        _users = nil
        _comments = nil
        showLoadingState()

        _api.getUsers { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure:
                showErrorState()

            case .success(let users):
                self._users = users
                if let comments = self._comments {
                    showPopulatedState(users: users, comments: comments)
                }
            }
        }

        _api.getComments { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure:
                showErrorState()

            case .success(let comments):
                self._comments = comments
                if let users = self._users {
                    showPopulatedState(users: users, comments: comments)
                }
            }
        }
    }
}
