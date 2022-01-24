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
        
        switch state {
        case .empty:
            _loadingView.isHidden = true
            _failedView.isHidden = true
            _detailView.model = .empty

        case .loading:
            _loadingView.isHidden = false
            _failedView.isHidden = true
            _detailView.model = .empty

        case .populated(let author, let filteredComments):
            _loadingView.isHidden = true
            _failedView.isHidden = true
            _detailView.model = .populated(
                body: _post.body,
                authorName: author.name,
                commentCount: filteredComments.count
            )

        case .failed:
            _loadingView.isHidden = true
            _failedView.isHidden = false
            _detailView.model = .empty
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"
        view.backgroundColor = .white

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

            switch result {

            case .failure:
                self._state = .failed

            case .success(let users):
                guard let author = users.filter({ $0.id == self._post.userId }).first else {
                    self._state = .failed
                    return
                }

                switch self._state {

                case .empty, .failed:
                    self._state = .loading(partial: .justAuthor(author))

                case .loading(let partial):
                    switch partial {
                    case .neither, .justAuthor:
                        self._state = .loading(partial: .justAuthor(author))
                    case .justFilteredComments(let comments):
                        self._state = .populated(author: author, filteredComments: comments)
                    }
                    
                case .populated(_, let comments):
                    self._state = .populated(author: author, filteredComments: comments)
                }
            }
        }

        _api.getComments { [weak self] result in
            guard let self = self else { return }

            switch result {

            case .failure:
                self._state = .failed

            case .success(let comments):
                let filteredComments = comments.on(self._post)

                switch self._state {

                case .empty, .failed:
                    self._state = .loading(partial: .justFilteredComments(filteredComments))

                case .loading(let partial):
                    switch partial {
                    case .neither, .justFilteredComments:
                        self._state = .loading(partial: .justFilteredComments(filteredComments))
                    case .justAuthor(let author):
                        self._state = .populated(author: author, filteredComments: filteredComments)
                    }
                    
                case .populated(let author, _):
                    self._state = .populated(author: author, filteredComments: filteredComments)
                }
            }
        }
    }
}
