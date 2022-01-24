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
        case loading
        case populated(posts: [Post])
        case failed
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
            guard let self = self else { return }
            let vc = DetailViewController(post: post, api: self._api)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return p
    }()

    private let _loadingView = LoadingView()
    
    private lazy var _failedView: FailedView = {
        let f = FailedView()
        f.didTap = { [weak self] in
            guard let self = self else { return }
            self._fetchPosts()
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

        switch state {

        case .empty:
            _loadingView.isHidden = true
            _failedView.isHidden = true
            _postsView.model = .empty
            
        case .loading:
            _loadingView.isHidden = false
            _failedView.isHidden = true
            _postsView.model = .empty
            
        case .populated(let posts):
            _loadingView.isHidden = true
            _failedView.isHidden = true
            _postsView.model = .init(posts: posts)
            
        case .failed:
            _loadingView.isHidden = true
            _failedView.isHidden = false
            _postsView.model = .empty
        }
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
        // When focused, refresh if needed.
        switch _state {
        case .empty, .failed:
            _fetchPosts()
        case .loading, .populated:
            break
        }
    }
    
    @objc
    private func _applicationDidBecomeActive() {
        // When app is foregrounded, unconditionally refresh.
        _fetchPosts()
    }
    
    /// Reverts to .loading and fetches /posts.
    private func _fetchPosts() {
        _state = .loading
        
        _api.getPosts { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure:
                self._state = .failed

            case .success(let posts):
                self._state = .populated(posts: posts)
            }
        }
    }
}
