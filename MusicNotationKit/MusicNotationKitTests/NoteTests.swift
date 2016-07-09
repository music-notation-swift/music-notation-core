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

    var note: Note!

    override func setUp() {
        super.setUp()
        note = Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1))
    }

    // MARK: - modifyTie(_:)
    // MARK: Failures

    func testModifyTieBeginAndEndTryBegin() {
        note.tie = .beginAndEnd
        do {
            try note.modifyTie(.begin)
            shouldFail()
        } catch NoteError.invalidRequestedTieState {
        } catch {
            expected(NoteError.invalidRequestedTieState, actual: error)
        }
        XCTAssert(note.tie == .beginAndEnd)
    }

    func testModifyTieBeginAndEndTryEnd() {
        note.tie = .beginAndEnd
        do {
            try note.modifyTie(.end)
            shouldFail()
        } catch NoteError.invalidRequestedTieState {
        } catch {
            expected(NoteError.invalidRequestedTieState, actual: error)
        }
    }

    // MARK: Successes

    func testModifyTieNilTryBegin() {
        note.tie = nil
        do {
            try note.modifyTie(.begin)
            XCTAssert(note.tie == .begin)
        } catch {
            XCTFail(String(error))
        }
    }

    func testModifyTieNilTryEnd() {
        note.tie = nil
        do {
            try note.modifyTie(.end)
            XCTAssert(note.tie == .end)
        } catch {
            XCTFail(String(error))
        }
    }

    func testModifyTieNilTryBeginAndEnd() {
        note.tie = nil
        do {
            try note.modifyTie(.beginAndEnd)
            XCTAssert(note.tie == .beginAndEnd)
        } catch {
            XCTFail(String(error))
        }
    }

    func testModifyTieBeginTryEnd() {
        note.tie = .begin
        do {
            try note.modifyTie(.end)
            XCTAssert(note.tie == .beginAndEnd)
        } catch {
            XCTFail(String(error))
        }
    }

    func testModifyTieEndTryBegin() {
        note.tie = .end
        do {
            try note.modifyTie(.begin)
            XCTAssert(note.tie == .beginAndEnd)
        } catch {
            XCTFail(String(error))
        }
    }

    func testModifyTieBeginTryBegin() {
        note.tie = .begin
        do {
            try note.modifyTie(.begin)
            XCTAssert(note.tie == .begin)
        } catch {
            XCTFail(String(error))
        }
    }

    func testModifyTieBeginAndEndTryBeginAndEnd() {
        note.tie = .end
        do {
            try note.modifyTie(.end)
            XCTAssert(note.tie == .end)
        } catch {
            XCTFail(String(error))
        }
    }

    func testModifyTieEndTryEnd() {
        note.tie = .beginAndEnd
        do {
            try note.modifyTie(.beginAndEnd)
            XCTAssert(note.tie == .beginAndEnd)
        } catch {
            XCTFail(String(error))
        }
    }

    // MARK: - removeTie()
    // MARK: Failures

    func testRemoveTieNilTryBeginAndEnd() {
        do {
            note.tie = nil
            try note.removeTie(.beginAndEnd)
            shouldFail()
        } catch NoteError.invalidRequestedTieState {
        } catch {
            expected(NoteError.invalidRequestedTieState, actual: error)
        }
    }

    func testRemoveTieEndTryBegin() {
        // Requested state doesn't match
        do {
            note.tie = .end
            try note.removeTie(.begin)
            shouldFail()
        } catch NoteError.invalidRequestedTieState {
        } catch {
            expected(NoteError.invalidRequestedTieState, actual: error)
        }
    }

    func testRemoveTieBeginTryEnd() {
        // Requested state doesn't match
        do {
            note.tie = .begin
            try note.removeTie(.end)
            shouldFail()
        } catch NoteError.invalidRequestedTieState {
        } catch {
            expected(NoteError.invalidRequestedTieState, actual: error)
        }
    }

    // MARK: Successes

    func testRemoveTieBegin() {
        do {
            note.tie = .begin
            try note.removeTie(.begin)
            XCTAssertNil(note.tie)
        } catch {
            XCTFail(String(error))
        }
    }

    func testRemoveTieEnd() {
        do {
            note.tie = .end
            try note.removeTie(.end)
            XCTAssertNil(note.tie)
        } catch {
            XCTFail(String(error))
        }
    }

    func testRemoveTieBeginAndEndTryBegin() {
        do {
            note.tie = .beginAndEnd
            try note.removeTie(.begin)
            XCTAssert(note.tie == .end)
        } catch {
            XCTFail(String(error))
        }
    }

    func testRemoveTieBeginAndEndTryEnd() {
        do {
            note.tie = .beginAndEnd
            try note.removeTie(.end)
            XCTAssert(note.tie == .begin)
        } catch {
            XCTFail(String(error))
        }
    }

    func testRemoveTieNilTryBegin() {
        do {
            note.tie = nil
            try note.removeTie(.begin)
            XCTAssertNil(note.tie)
        } catch {
            XCTFail(String(error))
        }
    }

    func testRemoveTieNilTryEnd() {
        do {
            note.tie = nil
            try note.removeTie(.end)
            XCTAssertNil(note.tie)
        } catch {
            XCTFail(String(error))
        }
    }
}
