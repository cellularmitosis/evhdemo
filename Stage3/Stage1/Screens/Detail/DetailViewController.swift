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
    
    enum State: Equatable {
        case empty
        case loading(partial: Partial)
        case populated(author: User, filteredComments: [Comment])
        case failed
        
        enum Partial: Equatable {
            case neither
            case justAuthor(User)
            case justFilteredComments([Comment])
        }
    }
    
    private var _state: State = .empty {
        didSet {
            _apply(state: _state, oldState: oldValue)
        }
    }
    
    private let _detailView = DetailView()
    
    private let _loadingView = LoadingView()
    
    private lazy var _failedView: FailedView = {
        let f = FailedView()
        f.didTap = { [weak self] in
            guard let self = self else { return }
            self._fetchData()
        }
        return f
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func _apply(state: State, oldState: State?) {
        guard state != oldState else {
            return
        }
        
        _loadingView.isHidden = state.loadingViewShouldBeHidden
        _failedView.isHidden = state.failedViewShouldBeHidden
        _detailView.model = state.detailViewModel(forPost: _post)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"

        func assembleViewHierarchy() {
            for v in [_detailView, _loadingView, _failedView] {
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
        _apply(state: _state, oldState: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(_applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        // When focused, refresh if needed.
        switch _state {
        case .empty, .failed:
            _fetchData()
        case .loading, .populated:
            break
        }
    }
    
    @objc
    private func _applicationDidBecomeActive() {
        // When app is foregrounded, unconditionally refresh.
        _fetchData()
    }

    /// Reverts to .loading and fetches /users and /comments.
    private func _fetchData() {
        _state = .loading(partial: .neither)

        _api.getUsers { [weak self] result in
            guard let self = self else { return }
            self._state = self._state.with(result: result, forPost: self._post)
        }

        _api.getComments { [weak self] result in
            guard let self = self else { return }
            self._state = self._state.with(result: result, forPost: self._post)
        }
    }
}


// MARK: - DetailViewController.State

extension DetailViewController.State {
    
    /// Returns a new State with the result of a /users network request.
    func with(result: Result<[User], Error>, forPost post: Post) -> DetailViewController.State {
        switch result {
        case .failure:
            return .failed
        case .success(let users):
            return self.with(users: users, forPost: post)
        }
    }

    /// Returns a new State with the result of a /comments network request.
    func with(result: Result<[Comment], Error>, forPost post: Post) -> DetailViewController.State {
        switch result {
        case .failure:
            return .failed
        case .success(let comments):
            return self.with(comments: comments, forPost: post)
        }
    }

    /// Returns a new State with updated users.
    func with(users: [User], forPost post: Post) -> DetailViewController.State {
        guard let author = users.filter({ $0.id == post.userId }).first else {
            return .failed
        }

        switch self {
        
        case .failed:
            return .failed

        case .empty:
            return .loading(partial: .justAuthor(author))

        case .loading(let partial):
            switch partial {
            case .neither, .justAuthor:
                return .loading(partial: .justAuthor(author))
            case .justFilteredComments(let comments):
                return .populated(author: author, filteredComments: comments)
            }
            
        case .populated(_, let comments):
            return .populated(author: author, filteredComments: comments)
        }
    }

    /// Returns a new State with updated comments.
    func with(comments: [Comment], forPost post: Post) -> DetailViewController.State {
        let filteredComments = comments.on(post)

        switch self {

        case .failed:
            return .failed

        case .empty:
            return .loading(partial: .justFilteredComments(filteredComments))

        case .loading(let partial):
            switch partial {
            case .neither, .justFilteredComments:
                return .loading(partial: .justFilteredComments(filteredComments))
            case .justAuthor(let author):
                return .populated(author: author, filteredComments: filteredComments)
            }
            
        case .populated(let author, _):
            return .populated(author: author, filteredComments: filteredComments)
        }
    }
    
    var loadingViewShouldBeHidden: Bool {
        switch self {
        case .loading:
            return false
        case .empty, .populated, .failed:
            return true
        }
    }
    
    var failedViewShouldBeHidden: Bool {
        switch self {
        case .failed:
            return false
        case .empty, .loading, .populated:
            return true
        }
    }
    
    func detailViewModel(forPost post: Post) -> DetailView.Model {
        switch self {
        case .empty, .loading, .failed:
            return .empty
        case .populated(let author, let filteredComments):
            return .populated(
                body: post.body,
                authorName: author.name,
                commentCount: filteredComments.count
            )
        }
    }
}
