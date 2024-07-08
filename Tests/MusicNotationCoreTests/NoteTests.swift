//
//  NoteTests.swift
//  MusicNotationCore
//
//  Created by Kyle Sherman on 06/15/2015.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

@testable import MusicNotationCore
import Testing

@Suite final class NoteTests {
	var note: Note!

	init() {
		note = Note(noteDuration: .eighth, pitch: SpelledPitch(.c, .octave1))
	}

	// MARK: - modifyTie(_:)

	// MARK: Failures

	func testModifyTieBeginAndEndTryBegin() async throws {
		note.tie = .beginAndEnd
		#expect(throws: NoteError.invalidRequestedTieState) {
			try note.modifyTie(.begin)
		}
	}

	func testModifyTieBeginAndEndTryEnd() async throws {
		note.tie = .beginAndEnd
		#expect(throws: NoteError.invalidRequestedTieState) {
			try note.modifyTie(.end)
		}
	}

	// MARK: Successes

	func testModifyTieNilTryBegin() async throws {
		note.tie = nil
		try note.modifyTie(.begin)
		#expect(note.tie == .begin)
	}

	func testModifyTieNilTryEnd() async throws {
		note.tie = nil
		try note.modifyTie(.end)
		#expect(note.tie == .end)
	}

	func testModifyTieNilTryBeginAndEnd() async throws {
		note.tie = nil
		try note.modifyTie(.beginAndEnd)
		#expect(note.tie == .beginAndEnd)
	}

	func testModifyTieBeginTryEnd() async throws {
		note.tie = .begin
		try note.modifyTie(.end)
		#expect(note.tie == .beginAndEnd)
	}

	func testModifyTieEndTryBegin() async throws {
		note.tie = .end
		try note.modifyTie(.begin)
		#expect(note.tie == .beginAndEnd)
	}

	func testModifyTieBeginTryBegin() async throws {
		note.tie = .begin
		try note.modifyTie(.begin)
		#expect(note.tie == .begin)
	}

	func testModifyTieBeginAndEndTryBeginAndEnd() async throws {
		note.tie = .end
		try note.modifyTie(.end)
		#expect(note.tie == .end)
	}

	func testModifyTieEndTryEnd() async throws {
		note.tie = .beginAndEnd
		try note.modifyTie(.beginAndEnd)
		#expect(note.tie == .beginAndEnd)
	}

	// MARK: - removeTie()

	// MARK: Failures

	func testRemoveTieNilTryBeginAndEnd() async throws {
		note.tie = nil

		#expect(throws: NoteError.invalidRequestedTieState) {
			try note.removeTie(.beginAndEnd)
		}
	}

	func testRemoveTieEndTryBegin() async throws {
		// Requested state doesn't match
		note.tie = .end
		#expect(throws: NoteError.invalidRequestedTieState) {
			try note.removeTie(.begin)
		}
	}

	func testRemoveTieBeginTryEnd() async throws {
		// Requested state doesn't match
		note.tie = .begin
		#expect(throws: NoteError.invalidRequestedTieState) {
			try note.removeTie(.end)
		}
	}

	// MARK: Successes

	func testRemoveTieBegin() async throws {
		note.tie = .begin
		try note.removeTie(.begin)
		#expect(note.tie == nil)
	}

	func testRemoveTieEnd() async throws {
		note.tie = .end
		try note.removeTie(.end)
		#expect(note.tie == nil)
	}

	func testRemoveTieBeginAndEndTryBegin() async throws {
		note.tie = .beginAndEnd
		try note.removeTie(.begin)
		#expect(note.tie == .end)
	}

	func testRemoveTieBeginAndEndTryEnd() async throws {
		note.tie = .beginAndEnd
		try note.removeTie(.end)
		#expect(note.tie == .begin)
	}

	func testRemoveTieNilTryBegin() async throws {
		note.tie = nil
		try note.removeTie(.begin)
		#expect(note.tie == nil)
	}

	func testRemoveTieNilTryEnd() async throws {
		note.tie = nil
		try note.removeTie(.end)
		#expect(note.tie == nil)
	}
}
