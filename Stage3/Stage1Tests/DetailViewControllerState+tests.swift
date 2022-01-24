//
//  DetailViewControllerState+tests.swift
//  Stage1Tests
//
//  Created by Jason Pepas on 1/22/22.
//

import XCTest
@testable import Stage1

class DetailViewControllerState_tests: XCTestCase {
    
    func testWithUsersAPIResult() throws {
        let author: User = .init(id: 1, name: "bob")
        let users: [User] = [
            author,
            .init(id: 2, name: "alice")
        ]
        
        let authorPost: Post = .init(id: 1, userId: author.id, title: "title1", body: "body1")
        
        let filteredComments: [Comment] = [
            .init(id: 1, postId: 1),
            .init(id: 2, postId: 1),
        ]
        
        let inputsAndExpectedOutputs: [(DetailViewController.State, DetailViewController.State)] = [
            (.empty,
             .loading(partial: .justAuthor(author))),
            (.loading(partial: .justAuthor(author)),
             .loading(partial: .justAuthor(author))),
            (.loading(partial: .justFilteredComments(filteredComments)),
             .populated(author: author, filteredComments: filteredComments)),
        ]

        for (inputState, expectedOutputState) in inputsAndExpectedOutputs {
            XCTAssertEqual(
                inputState.with(result: .success(users), forPost: authorPost),
                expectedOutputState
            )
            let failure: Result<[User], Error> = .failure(HTTPError.badHTTPStatusCode(code: 500))
            XCTAssertEqual(
                inputState.with(result: failure, forPost: authorPost),
                .failed
            )
        }
    }

    func testWithUsers() throws {
        let author: User = .init(id: 1, name: "bob")
        let users: [User] = [
            author,
            .init(id: 2, name: "alice")
        ]
        
        let authorPost: Post = .init(id: 1, userId: author.id, title: "title1", body: "body1")
        
        let filteredComments: [Comment] = [
            .init(id: 1, postId: 1),
            .init(id: 2, postId: 1),
        ]
        
        let inputsAndExpectedOutputs: [(DetailViewController.State, DetailViewController.State)] = [
            (.empty,
             .loading(partial: .justAuthor(author))),
            (.loading(partial: .justAuthor(author)),
             .loading(partial: .justAuthor(author))),
            (.loading(partial: .justFilteredComments(filteredComments)),
             .populated(author: author, filteredComments: filteredComments)),
        ]

        for (inputState, expectedOutputState) in inputsAndExpectedOutputs {
            XCTAssertEqual(
                inputState.with(users: users, forPost: authorPost),
                expectedOutputState
            )
        }
    }

    func testWithCommentsAPIResult() throws {
        let author: User = .init(id: 1, name: "bob")
        let authorPost: Post = .init(id: 1, userId: author.id, title: "title1", body: "body1")
        
        let comments: [Comment] = [
            .init(id: 1, postId: 1),
            .init(id: 2, postId: 1),
            .init(id: 3, postId: 2),
            .init(id: 4, postId: 2),
        ]
        let filteredComments: [Comment] = [
            .init(id: 1, postId: 1),
            .init(id: 2, postId: 1),
        ]
        
        let inputsAndExpectedOutputs: [(DetailViewController.State, DetailViewController.State)] = [
            (.empty,
             .loading(partial: .justFilteredComments(filteredComments))),
            (.loading(partial: .justFilteredComments(filteredComments)),
             .loading(partial: .justFilteredComments(filteredComments))),
            (.loading(partial: .justAuthor(author)),
             .populated(author: author, filteredComments: filteredComments)),
        ]

        for (inputState, expectedOutputState) in inputsAndExpectedOutputs {
            XCTAssertEqual(
                inputState.with(result: .success(comments), forPost: authorPost),
                expectedOutputState
            )
            let failure: Result<[Comment], Error> = .failure(HTTPError.badHTTPStatusCode(code: 500))
            XCTAssertEqual(
                inputState.with(result: failure, forPost: authorPost),
                .failed
            )
        }
    }
    
    func testWithComments() throws {
        let author: User = .init(id: 1, name: "bob")
        let authorPost: Post = .init(id: 1, userId: author.id, title: "title1", body: "body1")
        
        let comments: [Comment] = [
            .init(id: 1, postId: 1),
            .init(id: 2, postId: 1),
            .init(id: 3, postId: 2),
            .init(id: 4, postId: 2),
        ]
        let filteredComments: [Comment] = [
            .init(id: 1, postId: 1),
            .init(id: 2, postId: 1),
        ]
        
        let inputsAndExpectedOutputs: [(DetailViewController.State, DetailViewController.State)] = [
            (.empty,
             .loading(partial: .justFilteredComments(filteredComments))),
            (.loading(partial: .justFilteredComments(filteredComments)),
             .loading(partial: .justFilteredComments(filteredComments))),
            (.loading(partial: .justAuthor(author)),
             .populated(author: author, filteredComments: filteredComments)),
        ]

        for (inputState, expectedOutputState) in inputsAndExpectedOutputs {
            XCTAssertEqual(
                inputState.with(comments: comments, forPost: authorPost),
                expectedOutputState
            )
        }
    }
    
    func testLoadingViewVisibility() throws {
        let post: Post = .init(id: 1, userId: 1, title: "title1", body: "body1")
        let comments: [Comment] = [.init(id: 1, postId: post.id)]
        let author: User = .init(id: 1, name: "bob")

        for state: DetailViewController.State in [
            .empty,
            .populated(author: author, filteredComments: comments),
            .failed
        ] {
            XCTAssertTrue(state.loadingViewShouldBeHidden)
        }
        
        for state: DetailViewController.State in [
            .loading(partial: .neither)
        ] {
            XCTAssertFalse(state.loadingViewShouldBeHidden)
        }
    }
    
    func testFailedViewVisibility() throws {
        let post: Post = .init(id: 1, userId: 1, title: "title1", body: "body1")
        let comments: [Comment] = [.init(id: 1, postId: post.id)]
        let author: User = .init(id: 1, name: "bob")

        for state: DetailViewController.State in [
            .empty,
            .loading(partial: .neither),
            .populated(author: author, filteredComments: comments),
        ] {
            XCTAssertTrue(state.failedViewShouldBeHidden)
        }
        
        for state: DetailViewController.State in [
            .failed
        ] {
            XCTAssertFalse(state.failedViewShouldBeHidden)
        }
    }
    
    func testDetailViewModel() throws {
        let post: Post = .init(id: 1, userId: 1, title: "title1", body: "body1")
        let comments: [Comment] = [.init(id: 1, postId: post.id)]
        let author: User = .init(id: 1, name: "bob")

        for state: DetailViewController.State in [
            .empty,
            .loading(partial: .neither),
            .failed
        ] {
            XCTAssertEqual(
                state.detailViewModel(forPost: post),
                .empty
            )
        }

        for state: DetailViewController.State in [
            .populated(author: author, filteredComments: comments)
        ] {
            XCTAssertEqual(
                state.detailViewModel(forPost: post),
                .populated(body: post.body, authorName: author.name, commentCount: comments.count)
            )
        }
    }
}
