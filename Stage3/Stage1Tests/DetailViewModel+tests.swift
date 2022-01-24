//
//  DetailViewModel+tests.swift
//  Stage1Tests
//
//  Created by Jason Pepas on 1/22/22.
//

import XCTest
@testable import Stage1

class DetailViewModel_tests: XCTestCase {

    func testAuthorLabel() throws {
        let emptyModel: DetailView.Model = .empty
        XCTAssertEqual(emptyModel.authorLabel, nil)
        
        let populatedModel: DetailView.Model = .populated(
            body: "body",
            authorName: "Bob",
            commentCount: 3
        )
        XCTAssertEqual(populatedModel.authorLabel, "by Bob")
    }
    
    func testCommentCountLabel() throws {
        let emptyModel: DetailView.Model = .empty
        XCTAssertEqual(emptyModel.commentCountLabel, nil)
        
        let noCommentsModel: DetailView.Model = .populated(
            body: "body",
            authorName: "bob",
            commentCount: 0
        )
        XCTAssertEqual(noCommentsModel.commentCountLabel, "No comments")
        
        let oneCommentModel: DetailView.Model = .populated(
            body: "body",
            authorName: "bob",
            commentCount: 1
        )
        XCTAssertEqual(oneCommentModel.commentCountLabel, "1 comment")
        
        let manyCommentsModel: DetailView.Model = .populated(
            body: "body",
            authorName: "bob",
            commentCount: 42
        )
        XCTAssertEqual(manyCommentsModel.commentCountLabel, "42 comments")
    }
}
