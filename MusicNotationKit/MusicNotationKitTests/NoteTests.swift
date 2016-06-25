//
//  NoteTests.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 6/15/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

import XCTest
@testable import MusicNotationKit

class NoteTests: XCTestCase {

    var note = Note(noteDuration: .Eighth, tone: Tone(noteLetter: .C, octave: .Octave1))

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_modifyTie() {
        XCTAssertNil(note.tie)
        // Success
        do {
            try note.modifyTie(.Begin)
            XCTAssert(note.tie == .Begin)
            note.tie = nil
            try note.modifyTie(.End)
            XCTAssert(note.tie == .End)
            note.tie = nil
            try note.modifyTie(.BeginAndEnd)
            XCTAssert(note.tie == .BeginAndEnd)
            note.tie = .Begin
            try note.modifyTie(.End)
            XCTAssert(note.tie == .BeginAndEnd)
            note.tie = .End
            try note.modifyTie(.Begin)
            XCTAssert(note.tie == .BeginAndEnd)
            note.tie = .Begin
            try note.modifyTie(.Begin)
            XCTAssert(note.tie == .Begin)
            note.tie = .End
            try note.modifyTie(.End)
            XCTAssert(note.tie == .End)
            note.tie = .BeginAndEnd
            try note.modifyTie(.BeginAndEnd)
            XCTAssert(note.tie == .BeginAndEnd)
        } catch {
            XCTFail(String(error))
        }

        // Failure
        note.tie = .BeginAndEnd
        do {
            try note.modifyTie(.Begin)
            shouldFail()
        } catch NoteError.InvalidRequestedTieState {
        } catch {
            expected(NoteError.InvalidRequestedTieState, actual: error)
        }

        XCTAssert(note.tie == .BeginAndEnd)
        do {
            try note.modifyTie(.End)
            shouldFail()
        } catch NoteError.InvalidRequestedTieState {
        } catch {
            expected(NoteError.InvalidRequestedTieState, actual: error)
        }
    }

    func test_removeTie() {
        XCTAssertNil(note.tie)
        // Succeed if .Begin
        do {
            note.tie = .Begin
            try note.removeTie(.Begin)
            XCTAssertNil(note.tie)
        } catch {
            XCTFail(String(error))
        }

        // Succeed if .End
        do {
            note.tie = .End
            try note.removeTie(.End)
            XCTAssertNil(note.tie)
        } catch {
            XCTFail(String(error))
        }

        // Succeed if .BeginAndEnd, request .Begin
        do {
            note.tie = .BeginAndEnd
            try note.removeTie(.Begin)
            XCTAssert(note.tie == .End)
        } catch {
            XCTFail(String(error))
        }

        // Succeed if .BeginAndEnd, request .End
        do {
            note.tie = .BeginAndEnd
            try note.removeTie(.End)
            XCTAssert(note.tie == .Begin)
        } catch {
            XCTFail(String(error))
        }

        // Succeed if nil already, request .Begin
        do {
            note.tie = nil
            try note.removeTie(.Begin)
            XCTAssertNil(note.tie)
        } catch {
            XCTFail(String(error))
        }

        // Succeed if nil already, request .End
        do {
            note.tie = nil
            try note.removeTie(.End)
            XCTAssertNil(note.tie)
        } catch {
            XCTFail(String(error))
        }

        // Succeed if nil already, request .Begin
        do {
            note.tie = nil
            try note.removeTie(.Begin)
            XCTAssertNil(note.tie)
        } catch {
            XCTFail(String(error))
        }
        
        // Fail if request .BeginAndEnd
        do {
            note.tie = nil
            try note.removeTie(.BeginAndEnd)
            shouldFail()
        } catch NoteError.InvalidRequestedTieState {
        } catch {
            expected(NoteError.InvalidRequestedTieState, actual: error)
        }
        
        // Fail if request (Begin) doesn't match
        do {
            note.tie = .End
            try note.removeTie(.Begin)
            shouldFail()
        } catch NoteError.InvalidRequestedTieState {
        } catch {
            expected(NoteError.InvalidRequestedTieState, actual: error)
        }
        
        // Fail if request (End) doesn't match
        do {
            note.tie = .Begin
            try note.removeTie(.End)
            shouldFail()
        } catch NoteError.InvalidRequestedTieState {
        } catch {
            expected(NoteError.InvalidRequestedTieState, actual: error)
        }
    }
}
