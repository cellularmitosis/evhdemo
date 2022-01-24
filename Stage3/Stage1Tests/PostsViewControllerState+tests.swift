//
//  PostsViewControllerState+tests.swift
//  Stage1Tests
//
//  Created by Jason Pepas on 1/22/22.
//

import XCTest
@testable import Stage1

class PostsViewControllerState_tests: XCTestCase {

    func testLoadingViewVisibility() throws {
        for state: PostsViewController.State in [
            .empty,
            .populated(posts: []),
            .failed
        ] {
            XCTAssertTrue(state.loadingViewShouldBeHidden)
        }
        
        for state: PostsViewController.State in [
            .loading
        ] {
            XCTAssertFalse(state.loadingViewShouldBeHidden)
        }
    }
    
    func testFailedViewVisibility() throws {
        for state: PostsViewController.State in [
            .empty,
            .loading,
            .populated(posts: [])
        ] {
            XCTAssertTrue(state.failedViewShouldBeHidden)
        }
        
        for state: PostsViewController.State in [
            .failed
        ] {
            XCTAssertFalse(state.failedViewShouldBeHidden)
        }
    }
    
    func testPostViewModel() throws {
        for state: PostsViewController.State in [
            .empty,
            .loading,
            .failed
        ] {
            XCTAssertEqual(state.postsViewModel, .empty)
        }

        let posts: [Post] = [.init(id: 1, userId: 1, title: "title1", body: "body1")]
        for state: PostsViewController.State in [
            .populated(posts: posts)
        ] {
            XCTAssertEqual(state.postsViewModel, .init(posts: posts))
        }
    }
}
