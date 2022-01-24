//
//  PostsViewController.swift
//  Stage1
//
//  Created by Jason Pepas on 1/21/22.
//

import UIKit


// MARK: - PostsViewController

/// Displays a table of posts.
class PostsViewController: UIViewController {
    
    init(api: IAPI) {
        _api = api
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Internals
    
    enum State: Equatable {
        case empty
        case loading(partial: Partial, oldData: Complete?)
        case populated(data: Complete)
        case failed(oldData: Complete?)
        
        struct Complete: Equatable {
            let posts: [Post]
            let users: [User]
            let comments: [Comment]
        }

        struct Partial: Equatable {
            var posts: [Post]?
            var users: [User]?
            var comments: [Comment]?
            
            static var empty: Self {
                return .init(posts: nil, users: nil, comments: nil)
            }
            
            var completed: Complete? {
                if let posts = posts, let users = users, let comments = comments {
                    return .init(posts: posts, users: users, comments: comments)
                } else {
                    return nil
                }
            }
        }
    }
    
    private var _state: State = .empty {
        didSet {
            _apply(state: _state, oldState: oldValue)
        }
    }
    
    private let _api: IAPI
    
    private lazy var _postsView: PostsView = {
        let p = PostsView()
        p.didTapPost = { [weak self] (index, post) in
            guard let self = self,
                  let data = self._state.currentOrOldData
            else {
                return
            }
            let vc = DetailViewController(post: post, users: data.users, comments: data.comments)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return p
    }()

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
        guard state != oldState else { return }
        _loadingView.isHidden = state.loadingViewShouldBeHidden
        _failedView.isHidden = state.failedViewShouldBeHidden
        _postsView.model = state.postsViewModel
        navigationItem.rightBarButtonItem = state.rightNavBarItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Posts"
        
        func assembleViewHierarchy() {
            for v in [_postsView, _loadingView, _failedView] {
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
        // Upon focus, only refresh if we have no data to show (current or old).
        if _state.currentOrOldData == nil {
            _fetchData()
        }
    }
    
    @objc
    private func _applicationDidBecomeActive() {
        // Upon being foregrounded, always attempt a refresh.
        _fetchData()
    }
    
    private func _fetchData() {
        // Disallow overlapping fetches.
        if case .loading = _state {
            return
        }

        _state = _state.afterStartingNewFetch

        _api.getPosts { [weak self] result in
            guard let self = self else { return }
            self._state = self._state.with(result: result)
        }
        
        _api.getUsers { [weak self] result in
            guard let self = self else { return }
            self._state = self._state.with(result: result)
        }

        _api.getComments { [weak self] result in
            guard let self = self else { return }
            self._state = self._state.with(result: result)
        }
    }
}


// MARK: - PostsViewController.State

extension PostsViewController.State {

    var afterStartingNewFetch: Self {
        return .loading(partial: .empty, oldData: currentOrOldData)
    }

    var currentOrOldData: Self.Complete? {
        switch self {
        case .empty:
            return nil
        case .loading(_, let maybeOldData):
            return maybeOldData
        case .populated(let data):
            return data
        case .failed(let maybeOldData):
            return maybeOldData
        }
    }
    
    enum APIData {
        case posts([Post])
        case users([User])
        case comments([Comment])
    }

    func with(apiData: APIData) -> Self {
        switch self {
        case .loading(var partial, let maybeOldData):
            switch apiData {
            case .posts(let newPosts):
                partial.posts = newPosts
            case .users(let newUsers):
                partial.users = newUsers
            case .comments(let newComments):
                partial.comments = newComments
            }
            if let completed = partial.completed {
                return .populated(data: completed)
            } else {
                return .loading(partial: partial, oldData: maybeOldData)
            }
        case .empty, .populated, .failed:
            semiFatalError("\(#function): ⚠️ Unexpected state transition, self: \(self), apiData: \(apiData)")
            return self
        }
    }

    func with(result: Result<[Post], Error>) -> Self {
        switch result {
        case .success(let newPosts):
            return self.with(apiData: .posts(newPosts))
        case .failure:
            return .failed(oldData: currentOrOldData)
        }
    }

    func with(result: Result<[User], Error>) -> Self {
        switch result {
        case .success(let newUsers):
            return self.with(apiData: .users(newUsers))
        case .failure:
            return .failed(oldData: currentOrOldData)
        }
    }

    func with(result: Result<[Comment], Error>) -> Self {
        switch result {
        case .success(let newComments):
            return self.with(apiData: .comments(newComments))
        case .failure:
            return .failed(oldData: currentOrOldData)
        }
    }

    var loadingViewShouldBeHidden: Bool {
        guard currentOrOldData == nil else {
            return true
        }

        switch self {
        case .loading:
            return false
        case .empty, .populated, .failed:
            return true
        }
    }
    
    var failedViewShouldBeHidden: Bool {
        guard currentOrOldData == nil else {
            return true
        }

        switch self {
        case .failed:
            return false
        case .empty, .loading, .populated:
            return true
        }
    }
    
    var postsViewModel: PostsView.Model {
        if let data = currentOrOldData {
            return .init(posts: data.posts)
        } else {
            return .empty
        }
    }
    
    var rightNavBarItem: UIBarButtonItem? {
        switch self {
        case .empty, .loading, .populated:
            return nil
        case .failed(let maybeOldData):
            if maybeOldData != nil {
                return UIBarButtonItem(
                    customView: UILabel().with(text: "Stale?")
                )
            } else {
                return nil
            }
        }
    }
}


fileprivate extension UILabel {
    // Fluent interface:
    func with(text: String) -> Self {
        self.text = text
        return self
    }
}
