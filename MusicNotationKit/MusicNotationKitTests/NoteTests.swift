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

    var note = Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1))

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
            try note.modifyTie(.begin)
            XCTAssert(note.tie == .begin)
            note.tie = nil
            try note.modifyTie(.end)
            XCTAssert(note.tie == .end)
            note.tie = nil
            try note.modifyTie(.beginAndEnd)
            XCTAssert(note.tie == .beginAndEnd)
            note.tie = .begin
            try note.modifyTie(.end)
            XCTAssert(note.tie == .beginAndEnd)
            note.tie = .end
            try note.modifyTie(.begin)
            XCTAssert(note.tie == .beginAndEnd)
            note.tie = .begin
            try note.modifyTie(.begin)
            XCTAssert(note.tie == .begin)
            note.tie = .end
            try note.modifyTie(.end)
            XCTAssert(note.tie == .end)
            note.tie = .beginAndEnd
            try note.modifyTie(.beginAndEnd)
            XCTAssert(note.tie == .beginAndEnd)
        } catch {
            XCTFail(String(error))
        }

        // Failure
        note.tie = .beginAndEnd
        do {
            try note.modifyTie(.begin)
            shouldFail()
        } catch NoteError.invalidRequestedTieState {
        } catch {
            expected(NoteError.invalidRequestedTieState, actual: error)
        }

        XCTAssert(note.tie == .beginAndEnd)
        do {
            try note.modifyTie(.end)
            shouldFail()
        } catch NoteError.invalidRequestedTieState {
        } catch {
            expected(NoteError.invalidRequestedTieState, actual: error)
        }
    }

    func test_removeTie() {
        XCTAssertNil(note.tie)
        // Succeed if .Begin
        do {
            note.tie = .begin
            try note.removeTie(.begin)
            XCTAssertNil(note.tie)
        } catch {
            XCTFail(String(error))
        }

        // Succeed if .End
        do {
            note.tie = .end
            try note.removeTie(.end)
            XCTAssertNil(note.tie)
        } catch {
            XCTFail(String(error))
        }

        // Succeed if .BeginAndEnd, request .Begin
        do {
            note.tie = .beginAndEnd
            try note.removeTie(.begin)
            XCTAssert(note.tie == .end)
        } catch {
            XCTFail(String(error))
        }

        // Succeed if .BeginAndEnd, request .End
        do {
            note.tie = .beginAndEnd
            try note.removeTie(.end)
            XCTAssert(note.tie == .begin)
        } catch {
            XCTFail(String(error))
        }

        // Succeed if nil already, request .Begin
        do {
            note.tie = nil
            try note.removeTie(.begin)
            XCTAssertNil(note.tie)
        } catch {
            XCTFail(String(error))
        }

        // Succeed if nil already, request .End
        do {
            note.tie = nil
            try note.removeTie(.end)
            XCTAssertNil(note.tie)
        } catch {
            XCTFail(String(error))
        }

        // Succeed if nil already, request .Begin
        do {
            note.tie = nil
            try note.removeTie(.begin)
            XCTAssertNil(note.tie)
        } catch {
            XCTFail(String(error))
        }
        
        // Fail if request .BeginAndEnd
        do {
            note.tie = nil
            try note.removeTie(.beginAndEnd)
            shouldFail()
        } catch NoteError.invalidRequestedTieState {
        } catch {
            expected(NoteError.invalidRequestedTieState, actual: error)
        }
        
        // Fail if request (Begin) doesn't match
        do {
            note.tie = .end
            try note.removeTie(.begin)
            shouldFail()
        } catch NoteError.invalidRequestedTieState {
        } catch {
            expected(NoteError.invalidRequestedTieState, actual: error)
        }
        
        // Fail if request (End) doesn't match
        do {
            note.tie = .begin
            try note.removeTie(.end)
            shouldFail()
        } catch NoteError.invalidRequestedTieState {
        } catch {
            expected(NoteError.invalidRequestedTieState, actual: error)
        }
    }
}
