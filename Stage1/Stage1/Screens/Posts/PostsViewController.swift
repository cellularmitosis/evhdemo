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
    
    private let _api: IAPI

    private var _posts: [Post]? = nil {
        didSet {
            _tableView.reloadData()
        }
    }
    
    private lazy var _tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.dataSource = self
        tv.delegate = self
        tv.register(PostTableViewCell.self, forCellReuseIdentifier: "PostTableViewCell")
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 44
        return tv
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
        title = "Posts"
        
        func assembleViewHierarchy() {
            for v in [_tableView] {
                v.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(v)
                NSLayoutConstraint.activate([
                    v.topAnchor.constraint(equalTo: view.topAnchor),
                    v.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    v.leftAnchor.constraint(equalTo: view.leftAnchor),
                    v.rightAnchor.constraint(equalTo: view.rightAnchor)
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
        if _posts == nil {
            _fetchPosts()
        }
    }
    
    @objc
    private func _applicationDidBecomeActive() {
        _fetchPosts()
    }
    
    private func _fetchPosts() {
        _posts = nil
        _errorLabel.text = nil
        _spinner.startAnimating()
        _api.getPosts { [weak self] result in
            guard let self = self else { return }

            self._spinner.stopAnimating()

            switch result {
            case .failure:
                self._errorLabel.text = "😭"
                self._posts = nil

            case .success(let posts):
                self._errorLabel.text = nil
                self._posts = posts
            }
        }
    }
}


// MARK: - UITableViewDataSource

extension PostsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _posts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath)
        guard let postCell = cell as? PostTableViewCell else {
            semiFatalError("❌ \(type(of: self)).\(#function) misconfigured cell types!")
            return cell
        }
        
        postCell.textLabel?.text = _posts?.get(at: indexPath.row)?.title
        return postCell
    }
}


// MARK: - UITableViewDelegate

extension PostsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectSelectedCells()
        guard let post = _posts?.get(at: indexPath.row) else {
            return
        }
        let vc = DetailViewController(post: post, api: _api)
        navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - PostTableViewCell

class PostTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textLabel?.font = .systemFont(ofSize: 16)
        textLabel?.numberOfLines = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
