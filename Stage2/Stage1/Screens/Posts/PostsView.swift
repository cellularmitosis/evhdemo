//
//  PostsView.swift
//  Stage1
//
//  Created by Jason Pepas on 1/22/22.
//

import UIKit


/// The primary view of a PostsViewController.
class PostsView: UIView {
    
    struct Model: Equatable {
        let posts: [Post]
        
        static var empty: Model = .init(posts: [])
    }
    
    var model: Model = .empty {
        didSet {
            _apply(model: model, oldModel: oldValue)
        }
    }
    
    var didTapPost: ((_ index: Int, Post)->Void)? = nil
    
    // MARK: - Internals
    
    private lazy var _tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.dataSource = self
        tv.delegate = self
        tv.register(reuseIdentifiableClass: PostCell.self)
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 44
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        func assembleViewHierarchy() {
            for v in [_tableView] {
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
    
    private func _apply(model: Model, oldModel: Model?) {
        guard model != oldModel else {
            return
        }
        
        _tableView.reloadData()
    }
}


// MARK: - UITableViewDataSource

extension PostsView: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PostCell = tableView.dequeueReusableCell(at: indexPath)
        cell.textLabel?.text = model.posts.get(at: indexPath.row)?.title
        return cell
    }
}


// MARK: - UITableViewDelegate

extension PostsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectSelectedCells()
        guard let post = model.posts.get(at: indexPath.row) else {
            return
        }
        didTapPost?(indexPath.row, post)
    }
}
