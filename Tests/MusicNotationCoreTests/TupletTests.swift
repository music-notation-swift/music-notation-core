//
//  TupletTests.swift
//  MusicNotationCore
//
//  Created by Kyle Sherman on 06/19/2015.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

@testable import MusicNotationCore
import Testing

@Suite final class TupletTests {
	let pitch1 = SpelledPitch(.a, .octave1)
	let pitch2 = SpelledPitch(.b, accidental: .sharp, .octave1)
	let pitch3 = SpelledPitch(.d, accidental: .natural, .octave1)
	let quarterRest = Note(restDuration: .quarter)
	let eighthRest = Note(restDuration: .eighth)
	let dottedQuarterNote = Note(noteDuration: try! NoteDuration(value: .quarter, dotCount: 1),
								 pitch: SpelledPitch(.c, .octave3))
	var quarterNote1: Note!
	var quarterNote2: Note!
	var quarterNote3: Note!
	var eighthNote: Note!
	var quarterChord: Note!
	var eighthChord: Note!
	var sixteenthNote: Note!

	init() {
		quarterNote1 = Note(noteDuration: .quarter, pitch: pitch1)
		quarterNote2 = Note(noteDuration: .quarter, pitch: pitch1)
		quarterNote3 = Note(noteDuration: .quarter, pitch: pitch2)
		eighthNote = Note(noteDuration: .eighth, pitch: pitch1)
		quarterChord = Note(noteDuration: .quarter, pitches: [pitch1, pitch2, pitch3])
		eighthChord = Note(noteDuration: .eighth, pitches: [pitch1, pitch2, pitch3])
		sixteenthNote = Note(noteDuration: .sixteenth, pitch: pitch1)
	}

	// MARK: - init(notes:)

	// MARK: Failures

	func testInitFailForCountLessThan2() async throws {
		#expect(throws: TupletError.countMustBeLargerThan1) {
			_ = try Tuplet(1, .quarter, notes: [quarterNote1])
		}
	}

	func testInitFailForOddCountNoBaseCount() async throws {
		// count specified is something not in 2-9 range and no base count specified
		#expect(throws: TupletError.countHasNoStandardRatio) {
			_ = try Tuplet(
				10,
				.quarter,
				notes: [
					quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2,
					quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2,
				]
			)
		}
	}

	func testInitFailForEmptyNotes() async throws {
		// standard ratio
		#expect(throws: TupletError.notesDoNotFillTuplet) {
			_ = try Tuplet(3, .eighth, notes: [])
		}

		// non-standard ratio
		#expect(throws: TupletError.notesDoNotFillTuplet) {
			_ = try Tuplet(11, .eighth, inSpaceOf: 9, notes: [])
		}
	}

	func testInitFailForNotesSameDurationNotEnough() async throws {
		// standard ratio
		#expect(throws: TupletError.notesDoNotFillTuplet) {
			_ = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2])
		}

		// non-standard ratio
		#expect(throws: TupletError.notesDoNotFillTuplet) {
			_ = try Tuplet(11, .quarter, inSpaceOf: 9, notes: [quarterNote1, quarterNote2, quarterNote3])
		}
	}

	func testInitFailForNotesSameDurationTooMany() async throws {
		// standard ratio
		#expect(throws: TupletError.notesOverfillTuplet) {
			_ = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1])
		}

		// non-standard ratio
		#expect(throws: TupletError.notesOverfillTuplet) {
			_ = try Tuplet(
				5,
				.quarter,
				inSpaceOf: 2,
				notes: [
					quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3, quarterNote1,
				]
			)
		}
	}

	func testInitFailForNotesShorterNotEnough() async throws {
		// standard ratio
		#expect(throws: TupletError.notesDoNotFillTuplet) {
			_ = try Tuplet(4, .quarter, notes: [eighthNote, eighthNote, quarterNote1])
		}

		// non-standard ratio
		#expect(throws: TupletError.notesDoNotFillTuplet) {
			_ = try Tuplet(
				5,
				.quarter,
				inSpaceOf: 3,
				notes: [
					eighthNote, eighthNote,
					eighthNote, eighthNote,
					quarterNote3,
				]
			)
		}
	}

	func testInitFailForShorterTooMany() async throws {
		// standard ratio
		#expect(throws: TupletError.notesOverfillTuplet) {
			_ = try Tuplet(
				4,
				.quarter,
				notes: [
					eighthNote, eighthNote, eighthNote, eighthNote, quarterNote1, quarterNote2, quarterNote3,
				]
			)
		}

		// non-standard ratio
		#expect(throws: TupletError.notesOverfillTuplet) {
			_ = try Tuplet(
				5,
				.quarter,
				inSpaceOf: 2,
				notes: [
					quarterNote1, quarterNote2, quarterNote3,
					eighthNote, eighthNote, quarterNote1, eighthNote,
				]
			)
		}
	}

	func testInitFailForLongerNotEnough() async throws {
		// standard ratio
		#expect(throws: TupletError.notesDoNotFillTuplet) {
			_ = try Tuplet(4, .eighth, notes: [quarterNote1, eighthNote])
		}

		// non-standard ratio
		#expect(throws: TupletError.notesDoNotFillTuplet) {
			_ = try Tuplet(11, .eighth, inSpaceOf: 9, notes: [eighthNote, eighthNote, quarterNote1])
		}
	}

	func testInitFailForLongerTooMany() async throws {
		// standard ratio
		#expect(throws: TupletError.notesOverfillTuplet) {
			_ = try Tuplet(
				5,
				.eighth,
				notes: [
					eighthNote, quarterNote1, eighthNote, quarterNote2,
				]
			)
		}

		// non-standard ratio
		#expect(throws: TupletError.notesOverfillTuplet) {
			_ = try Tuplet(
				5,
				.eighth,
				inSpaceOf: 2,
				notes: [
					eighthNote, quarterNote1, eighthNote, quarterNote2,
				]
			)
		}
	}

	func testInitFailForSameDurationWithRestsNotEnough() async throws {
		// standard ratio
		#expect(throws: TupletError.notesDoNotFillTuplet) {
			_ = try Tuplet(3, .quarter, notes: [quarterNote1, quarterRest])
		}

		// non-standard ratio
		#expect(throws: TupletError.notesDoNotFillTuplet) {
			_ = try Tuplet(11, .quarter, inSpaceOf: 9, notes: [quarterNote1, quarterRest, quarterNote3])
		}
	}

	func testInitFailForCompoundTupletTooLarge() async throws {
		#expect(throws: TupletError.notesOverfillTuplet) {
			// This is worth 4 quarter notes
			let quintuplet = try? Tuplet(
				5,
				.quarter,
				notes: [
					quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2,
				]
			)
			#expect(quintuplet != nil)
			// 8 quarter notes long instead of 7
			_ = try Tuplet(
				7,
				.quarter,
				notes: [
					quarterNote1, quarterNote2, quarterNote3, quarterNote1,
					quintuplet!,
				]
			)
		}
	}

	func testInitFailForCompoundTupletTooSmall() async throws {
		#expect(throws: TupletError.notesDoNotFillTuplet) {
			let triplet = try? Tuplet(
				3,
				.quarter,
				notes: [
					quarterNote1, quarterNote2, quarterNote3,
				]
			)
			#expect(triplet != nil)
			_ = try Tuplet(
				7,
				.quarter,
				notes: [
					quarterNote1, quarterNote2, quarterNote3,
					triplet!,
				]
			)
		}
	}

	// MARK: Successes

	@Test func initSuccessForAllStandardCombinations() async throws {
		// Test 2 - 9
		_ = try Tuplet(
			2,
			.quarter,
			notes: [
				quarterNote1, quarterNote2,
			]
		)
		_ = try Tuplet(
			3,
			.quarter,
			notes: [
				quarterNote1, quarterNote2, quarterNote3,
			]
		)
		_ = try Tuplet(
			4,
			.quarter,
			notes: [
				quarterNote1, quarterNote2, quarterNote3, quarterNote1,
			]
		)
		_ = try Tuplet(
			5,
			.quarter,
			notes: [
				quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2,
			]
		)
		_ = try Tuplet(
			6,
			.quarter,
			notes: [
				quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3,
			]
		)
		_ = try Tuplet(
			7,
			.quarter,
			notes: [
				quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3, quarterNote1,
			]
		)
		_ = try Tuplet(
			8,
			.quarter,
			notes: [
				quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3, quarterNote1,
				quarterNote2,
			]
		)
		_ = try Tuplet(
			9,
			.quarter,
			notes: [
				quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3, quarterNote1,
				quarterNote2, quarterNote3,
			]
		)
		// Test with a chord
		_ = try Tuplet(
			2,
			.quarter,
			notes: [
				quarterNote1, quarterChord,
			]
		)
	}

	@Test func initSuccessForStandardMixedDurations() async throws {
		_ = try Tuplet(
			5,
			.quarter,
			notes: [
				quarterNote1, eighthNote, eighthNote, quarterNote2, quarterNote3, eighthNote, eighthNote,
			]
		)
	}

	func testInitSuccessForStandardDottedBase() async throws {
		let baseDuration = try? NoteDuration(value: .quarter, dotCount: 1)
        #expect(baseDuration != nil)
		_ = try Tuplet(
			3,
			baseDuration!,
			notes: [
				dottedQuarterNote, dottedQuarterNote, dottedQuarterNote,
			]
		)
	}

	func testInitSuccessForStandardDottedBaseMixedDuration() async throws {
		let baseDuration = try? NoteDuration(value: .quarter, dotCount: 1)
        #expect(baseDuration != nil)
		_ = try Tuplet(
			3,
			baseDuration!,
			notes: [
				dottedQuarterNote, quarterNote1, eighthNote, dottedQuarterNote,
			]
		)
	}

	@Test func initSuccessForStandardCompound() async throws {
		let triplet = try? Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
        #expect(triplet != nil)
		_ = try Tuplet(
			5,
			.eighth,
			notes: [
				triplet!, eighthNote, eighthNote, eighthNote,
			]
		)
	}

	@Test func initSuccessForStandardWithRests() async throws {
		_ = try Tuplet(3, .quarter, notes: [quarterNote1, quarterRest, quarterNote3])
	}

	@Test func initSuccessForNonStandardSameDuration() async throws {
		_ = try Tuplet(
			7,
			.eighth,
			inSpaceOf: 6,
			notes: [
				eighthNote, eighthNote, eighthNote, eighthNote,
				eighthNote, eighthNote, eighthNote,
			]
		)
	}

	func testInitSuccessForNonStandardDottedBase() async throws {
		_ = try Tuplet(
			4,
			NoteDuration(value: .quarter, dotCount: 1),
			inSpaceOf: 2,
			notes: [
				dottedQuarterNote, dottedQuarterNote, dottedQuarterNote, dottedQuarterNote,
			]
		)
	}

	func testInitSuccessForNonStandardCompound() async throws {
		// Space of 4 eighth notes
		let quintuplet = try? Tuplet(5, .eighth, notes: [eighthNote, eighthNote, eighthNote, eighthNote, eighthNote])
		#expect(quintuplet != nil)
		_ = try Tuplet(
			11,
			.eighth,
			inSpaceOf: 9,
			notes: [
				quintuplet!, eighthNote, eighthNote, eighthNote,
				eighthNote, eighthNote, eighthNote, eighthNote,
			]
		)
	}

	func testInitSuccessForNonStandardNestedCompound() async throws {
        // Space of 4 eighth notes
        let triplet = try? Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
        #expect(triplet != nil)
        let quintuplet = try Tuplet(5, .eighth, notes: [eighthNote, eighthNote, eighthNote, triplet!])
        #expect(quintuplet != nil)
        _ = try Tuplet(
            11,
            .eighth,
            inSpaceOf: 9,
            notes: [
                quintuplet, eighthNote, eighthNote, eighthNote,
                eighthNote, eighthNote, eighthNote, eighthNote,
            ]
        )
	}

	@Test func initSuccessForNonStandardWithRests() async throws {
		_ = try Tuplet(
			7,
			.quarter,
			inSpaceOf: 6,
			notes: [
				quarterNote1, quarterNote2, quarterRest, quarterNote3,
				quarterRest, quarterRest, quarterNote1,
			]
		)
	}

	// MARK: - note(at:)

	// MARK: Failures

	@Test func noteAtForInvalidIndexNegative() async throws {
		#expect(throws: TupletError.invalidIndex) {
			let tuplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			_ = try tuplet.note(at: -1)
		}
	}

	func testNoteAtForInvalidIndexTooLarge() async throws {
		#expect(throws: TupletError.invalidIndex) {
			let tuplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			_ = try tuplet.note(at: 5)
		}
	}

	// MARK: Successes

	@Test func noteAtSuccess() async throws {
		let tuplet = try Tuplet(5, .eighth, notes: [eighthNote, eighthNote, eighthRest, eighthNote, eighthNote])
		let note = try tuplet.note(at: 2)
		#expect(note == eighthRest)
	}

	// MARK: - replaceNote<T: NoteCollection>(at:with:T)

	// MARK: Failures

	@Test func replaceNoteWithNoteTooLong() async throws {
		#expect(throws: TupletError.replacementNotSameDuration) {
			var tuplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			try tuplet.replaceNote(at: 1, with: quarterNote1)
		}
	}

	func testReplaceNoteWithNoteTooShort() async throws {
		#expect(throws: TupletError.replacementNotSameDuration) {
			var tuplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			try tuplet.replaceNote(at: 0, with: eighthNote)
		}
	}

	func testReplaceNoteInTupletWithNoteTooShort() async throws {
		#expect(throws: TupletError.replacementNotSameDuration) {
			let triplet = try? Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			XCTAssertNotNil(triplet)
			var tuplet = try Tuplet(5, .quarter, notes: [
				triplet!, quarterNote1, quarterNote2, quarterNote3,
			])
			try tuplet.replaceNote(at: 1, with: eighthNote)
		}
	}

	func testReplaceNoteInTupletWithNoteTooLong() async throws {
		#expect(throws: TupletError.replacementNotSameDuration) {
			let triplet = try? Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			XCTAssertNotNil(triplet)
			var tuplet = try Tuplet(5, .eighth, notes: [
				triplet!, eighthNote, eighthNote, eighthNote,
			])
			try tuplet.replaceNote(at: 1, with: quarterNote1)
		}
	}

	func testReplaceNoteWithTupletTooLong() async throws {
		#expect(throws: TupletError.replacementNotSameDuration) {
			let triplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			var tuplet = try Tuplet(5, .eighth, notes: [eighthNote, eighthNote, eighthNote, eighthNote, eighthNote])
			try tuplet.replaceNote(at: 0, with: triplet)
		}
	}

	// MARK: Successes

	func testReplaceNoteWithRestOfSameDuration() async throws {
		assertNoErrorThrown {
			var tuplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			try tuplet.replaceNote(at: 0, with: quarterRest)
			#expect(try tuplet.note(at: 0) == quarterRest)
			#expect(try tuplet.note(at: 1) == quarterNote2)
			#expect(try tuplet.note(at: 2) == quarterNote3)
		}
	}

	func testReplaceNoteInTupletWithRestOfSameDuration() async throws {
		assertNoErrorThrown {
			let triplet = try? Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			XCTAssertNotNil(triplet)
			var tuplet = try Tuplet(5, .quarter, notes: [
				triplet!, quarterNote1, quarterNote2, quarterNote3,
			])
			try tuplet.replaceNote(at: 1, with: quarterRest)
			#expect(try tuplet.note(at: 0) == quarterNote1)
			#expect(try tuplet.note(at: 1) == quarterRest)
			#expect(try tuplet.note(at: 2) == quarterNote3)
			#expect(try tuplet.note(at: 3) == quarterNote1)
			#expect(try tuplet.note(at: 4) == quarterNote2)
			#expect(try tuplet.note(at: 5) == quarterNote3)
		}
	}

	func testReplaceNoteWithNoteOfSameDuration() async throws {
		assertNoErrorThrown {
			var tuplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			try tuplet.replaceNote(at: 0, with: quarterNote3)
			#expect(try tuplet.note(at: 0) == quarterNote3)
			#expect(try tuplet.note(at: 1) == quarterNote2)
			#expect(try tuplet.note(at: 2) == quarterNote3)
		}
	}

	func testReplaceNoteInTupletWithNoteOfSameDuration() async throws {
		assertNoErrorThrown {
			let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			var tuplet = try Tuplet(5,
									.quarter,
									notes: [triplet, quarterNote1, quarterNote2, quarterNote3])
			try tuplet.replaceNote(at: 1, with: quarterNote1)
			#expect(try tuplet.note(at: 0) == quarterNote1)
			#expect(try tuplet.note(at: 1) == quarterNote1)
			#expect(try tuplet.note(at: 2) == quarterNote3)
			#expect(try tuplet.note(at: 3) == quarterNote1)
			#expect(try tuplet.note(at: 4) == quarterNote2)
			#expect(try tuplet.note(at: 5) == quarterNote3)
		}
	}

	func testReplaceNoteTieWithNoteOfSameDuration() async throws {
		assertNoErrorThrown {
			var beginTieNote = eighthNote!
			beginTieNote.tie = .begin
			var beginAndEndTieNote = eighthNote!
			beginAndEndTieNote.tie = .beginAndEnd
			var endTieNote = eighthNote!
			endTieNote.tie = .end

			var tupletBegin = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, beginTieNote])
			try tupletBegin.replaceNote(at: 2, with: eighthNote)
			#expect(try tupletBegin.note(at: 2) == beginTieNote)

			var tupletBeginAndEnd = try Tuplet(3, .eighth, notes: [eighthNote, beginTieNote, beginAndEndTieNote])
			try tupletBeginAndEnd.replaceNote(at: 2, with: eighthNote)
			#expect(try tupletBeginAndEnd.note(at: 2) == beginAndEndTieNote)

			var tupletEnd = try Tuplet(3, .eighth, notes: [endTieNote, eighthNote, eighthNote])
			try tupletEnd.replaceNote(at: 0, with: eighthNote)
			#expect(try tupletEnd.note(at: 0) == endTieNote)
		}
	}

	func testReplaceNoteTieWithTupletSameDuration() async throws {
		assertNoErrorThrown {
			var beginTieNote = quarterNote1!
			beginTieNote.tie = .begin
			var endTieNote = quarterNote1!
			endTieNote.tie = .end

			let triplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])

			var tupletBegin = try Tuplet(3, .quarter, notes: [quarterNote2, quarterNote2, beginTieNote])
			try tupletBegin.replaceNote(at: 2, with: triplet)
			var eighthNoteTieBegin = eighthNote!
			eighthNoteTieBegin.tie = .begin
			#expect(try tupletBegin.note(at: 2) == eighthNote)
			#expect(try tupletBegin.note(at: 3) == eighthNote)
			#expect(try tupletBegin.note(at: 4) == eighthNoteTieBegin)

			var tupletEnd = try Tuplet(3, .quarter, notes: [endTieNote, quarterNote2, quarterNote2])
			try tupletEnd.replaceNote(at: 0, with: triplet)
			var eighthNoteTieEnd = eighthNote!
			eighthNoteTieEnd.tie = .end
			#expect(try tupletEnd.note(at: 0) == eighthNoteTieEnd)
			#expect(try tupletEnd.note(at: 1) == eighthNote)
			#expect(try tupletEnd.note(at: 2) == eighthNote)
		}
	}

	func testReplaceNoteBeginAndEndTieWithTupletSameDuration() async throws {
		assertNoErrorThrown {
			var beginTieNote = quarterNote1!
			beginTieNote.tie = .begin
			var beginAndEndTieNote = quarterNote1!
			beginAndEndTieNote.tie = .beginAndEnd

			let triplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			var tuplet = try Tuplet(3, .quarter, notes: [quarterNote1, beginTieNote, beginAndEndTieNote])
			try tuplet.replaceNote(at: 2, with: triplet)
		}
	}

	// MARK: - replaceNote<T: NoteCollection>(at:with:[T])

	// MARK: Failures

	func testReplaceNoteWithArrayOfNotesTooLong() async throws {
		#expect(throws: TupletError.replacementNotSameDuration) {
			var triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			try triplet.replaceNote(at: 1, with: [eighthNote, eighthNote, eighthNote])
		}
	}

	func testReplaceNoteWithArrayOfNotesTooShort() async throws {
		#expect(throws: TupletError.replacementNotSameDuration) {
			var triplet = try Tuplet(3,
									 NoteDuration(value: .quarter, dotCount: 1),
									 notes: [dottedQuarterNote, dottedQuarterNote, dottedQuarterNote])
			try triplet.replaceNote(at: 1, with: [eighthNote, eighthNote])
		}
	}

	func testReplaceNoteInTupletWithArrayOfNotesTooLong() async throws {
		#expect(throws: TupletError.replacementNotSameDuration) {
			let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			var tuplet = try Tuplet(5,
									.quarter,
									notes: [triplet, quarterNote1, quarterNote2, quarterNote3])
			try tuplet.replaceNote(at: 2, with: [quarterNote1, quarterNote2])
		}
	}

	func testReplaceNoteInTupletWithArrayOfNotesTooShort() async throws {
		#expect(throws: TupletError.replacementNotSameDuration) {
			let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			var tuplet = try Tuplet(5,
									.quarter,
									notes: [triplet, quarterNote1, quarterNote2, quarterNote3])
			try tuplet.replaceNote(at: 0, with: [eighthNote])
		}
	}

	func testReplaceNoteInTupletWithArrayOfTupletsTooLong() async throws {
		#expect(throws: TupletError.replacementNotSameDuration) {
			let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			var tuplet = try Tuplet(5,
									.quarter,
									notes: [triplet, quarterNote1, quarterNote2, quarterNote3])
			let newTuplet = try Tuplet(5, .eighth, notes: [eighthNote, eighthNote, eighthNote, eighthNote, eighthNote])
			try tuplet.replaceNote(at: 0, with: [newTuplet])
		}
	}

	func testReplaceNoteInTupletWithArrayOfTupletsTooShort() async throws {
		#expect(throws: TupletError.replacementNotSameDuration) {
			let triplet = try Tuplet(3,
									 NoteDuration(value: .quarter, dotCount: 1),
									 notes: [dottedQuarterNote, dottedQuarterNote, dottedQuarterNote])
			var tuplet = try Tuplet(5,
									NoteDuration(value: .quarter, dotCount: 1),
									notes: [triplet, dottedQuarterNote, dottedQuarterNote, dottedQuarterNote])
			let newTuplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			try tuplet.replaceNote(at: 0, with: [newTuplet])
		}
	}

	// MARK: Successes

	func testReplaceNoteWithArrayOfNotesSameDuration() async throws {
		var tuplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
		try tuplet.replaceNote(at: 0, with: [eighthNote, eighthNote])
		#expect(try tuplet.note(at: 0) == eighthNote)
		#expect(try tuplet.note(at: 1) == eighthNote)
		#expect(try tuplet.note(at: 2) == quarterNote2)
		#expect(try tuplet.note(at: 3) == quarterNote3)
	}

	func testReplaceNoteWithArrayOfRestsSameDuration() async throws {
		var tuplet = try Tuplet(3,
								NoteDuration(value: .quarter, dotCount: 1),
								notes: [dottedQuarterNote, dottedQuarterNote, dottedQuarterNote])
		try tuplet.replaceNote(at: 1, with: [eighthRest, eighthRest, eighthRest])
		#expect(try tuplet.note(at: 0) == dottedQuarterNote)
		#expect(try tuplet.note(at: 1) == eighthRest)
		#expect(try tuplet.note(at: 2) == eighthRest)
		#expect(try tuplet.note(at: 3) == eighthRest)
		#expect(try tuplet.note(at: 4) == dottedQuarterNote)
	}

	func testReplaceNoteInTupletWithArrayOfNotesSameDuration() async throws {
		let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
		var tuplet = try Tuplet(5, .quarter, notes: [quarterNote1, triplet, quarterNote2, quarterNote3])
		try tuplet.replaceNote(at: 2, with: [eighthNote, eighthNote])
		#expect(try tuplet.note(at: 0) == quarterNote1)
		#expect(try tuplet.note(at: 1) == quarterNote1)
		#expect(try tuplet.note(at: 2) == eighthNote)
		#expect(try tuplet.note(at: 3) == eighthNote)
		#expect(try tuplet.note(at: 4) == quarterNote3)
		#expect(try tuplet.note(at: 5) == quarterNote2)
		#expect(try tuplet.note(at: 6) == quarterNote3)
	}

	func testReplaceNoteWithArrayOfTupletsSameDuration() async throws {
		var tuplet = try Tuplet(5,
								.quarter,
								notes: [quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1])
		let triplet = try Tuplet(3, .sixteenth, notes: [sixteenthNote, sixteenthNote, sixteenthNote])
		try tuplet.replaceNote(at: 1, with: [triplet, triplet])
		#expect(try tuplet.note(at: 0) == quarterNote1)
		#expect(try tuplet.note(at: 1) == sixteenthNote)
		#expect(try tuplet.note(at: 2) == sixteenthNote)
		#expect(try tuplet.note(at: 3) == sixteenthNote)

		#expect(try tuplet.note(at: 4) == sixteenthNote)
		#expect(try tuplet.note(at: 5) == sixteenthNote)
		#expect(try tuplet.note(at: 6) == sixteenthNote)

		#expect(try tuplet.note(at: 7) == quarterNote1)
		#expect(try tuplet.note(at: 8) == quarterNote1)
		#expect(try tuplet.note(at: 9) == quarterNote1)
	}

    @Test func replaceNoteBeginTieWithArrayOfNotesSameDuration() async throws {
		var beginNote = quarterNote1!
		beginNote.tie = .begin

		var tuplet = try Tuplet(3, .quarter, notes: [quarterNote2, quarterNote3, beginNote])
		try tuplet.replaceNote(at: 2, with: [eighthNote, eighthNote])
		var eighthBegin = eighthNote!
		eighthBegin.tie = .begin
		#expect(try tuplet.note(at: 0) == quarterNote2)
		#expect(try tuplet.note(at: 1) == quarterNote3)
		#expect(try tuplet.note(at: 2) == eighthNote)
		#expect(try tuplet.note(at: 3) == eighthBegin)
	}

    @Test func replaceNoteBeginTieWithArrayOfTupletsSameDuration() async throws {
		var beginNote = quarterNote1!
		beginNote.tie = .begin

		let triplet = try Tuplet(3, .sixteenth, notes: [sixteenthNote, sixteenthNote, sixteenthNote])
		var tuplet = try Tuplet(5, .eighth, notes: [eighthNote, eighthNote, eighthNote, beginNote])
		try tuplet.replaceNote(at: 3, with: [triplet, triplet])
		var sixteenthBegin = sixteenthNote!
		sixteenthBegin.tie = .begin
		#expect(try tuplet.note(at: 0) == eighthNote)
		#expect(try tuplet.note(at: 1) == eighthNote)
		#expect(try tuplet.note(at: 2) == eighthNote)
		#expect(try tuplet.note(at: 3) == sixteenthNote)
		#expect(try tuplet.note(at: 4) == sixteenthNote)
		#expect(try tuplet.note(at: 5) == sixteenthNote)
		#expect(try tuplet.note(at: 6) == sixteenthNote)
		#expect(try tuplet.note(at: 7) == sixteenthNote)
		#expect(try tuplet.note(at: 8) == sixteenthBegin)
	}

    @Test func replaceNoteEndTieWithArrayOfNotesSameDuration() async throws {
		var endNote = quarterNote1!
		endNote.tie = .end

		var tuplet = try Tuplet(3, .quarter, notes: [endNote, quarterNote2, quarterNote3])
		try tuplet.replaceNote(at: 0, with: [eighthNote, eighthNote])
		var eighthEnd = eighthNote!
		eighthEnd.tie = .end
		#expect(try tuplet.note(at: 0) == eighthEnd)
		#expect(try tuplet.note(at: 1) == eighthNote)
		#expect(try tuplet.note(at: 2) == quarterNote2)
		#expect(try tuplet.note(at: 3) == quarterNote3)
	}

    @Test func replaceNoteEndTieWithArrayOfTupletsSameDuration() async throws {
        var endNote = quarterNote1!
        endNote.tie = .end

        let triplet = try Tuplet(3, .sixteenth, notes: [sixteenthNote, sixteenthNote, sixteenthNote])
        var tuplet = try Tuplet(5, .eighth, notes: [endNote, eighthNote, eighthNote, eighthNote])
        try tuplet.replaceNote(at: 0, with: [triplet, triplet])
        var sixteenthEnd = sixteenthNote!
        sixteenthEnd.tie = .end
        #expect(try tuplet.note(at: 0) == sixteenthEnd)
        #expect(try tuplet.note(at: 1) == sixteenthNote)
        #expect(try tuplet.note(at: 2) == sixteenthNote)
        #expect(try tuplet.note(at: 3) == sixteenthNote)
        #expect(try tuplet.note(at: 4) == sixteenthNote)
        #expect(try tuplet.note(at: 5) == sixteenthNote)
        #expect(try tuplet.note(at: 6) == eighthNote)
        #expect(try tuplet.note(at: 7) == eighthNote)
        #expect(try tuplet.note(at: 8) == eighthNote)
    }

	func testReplaceNoteBeginAndEndTieWithArrayOfNotes() async throws {
		assertNoErrorThrown {
			var beginAndEndNote = quarterNote1!
			beginAndEndNote.tie = .beginAndEnd
			var beginNote = quarterNote2!
			beginNote.tie = .begin

			var tuplet = try Tuplet(3, .quarter, notes: [quarterNote1, beginNote, beginAndEndNote])
			try tuplet.replaceNote(at: 2, with: [eighthNote, eighthNote])
			var endEighth = eighthNote!
			endEighth.tie = .end
			var beginEighth = eighthNote!
			beginEighth.tie = .begin
			#expect(try tuplet.note(at: 0) == quarterNote1)
			#expect(try tuplet.note(at: 1) == beginNote)
			#expect(try tuplet.note(at: 2) == endEighth)
			#expect(try tuplet.note(at: 3) == beginEighth)
		}
	}

	// MARK: - replaceNotes<T: NoteCollection>(in:with:T)

	// MARK: Failures

    @Test func replaceNotesWithNoteTooLarge() async throws {
		#expect(throws: TupletError.replacementNotSameDuration) {
			var tuplet = try Tuplet(5,
									.sixteenth,
									notes: [sixteenthNote, sixteenthNote, sixteenthNote, sixteenthNote, sixteenthNote])
			try tuplet.replaceNotes(in: 1 ... 2,
									with: quarterNote1)
		}
	}

    @Test func replaceNotesWithNoteTooShort() async throws {
		#expect(throws: TupletError.replacementNotSameDuration) {
			var tuplet = try Tuplet(5,
									.quarter,
									notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2])
			try tuplet.replaceNotes(in: 2 ... 3,
									with: eighthNote)
		}
	}

    @Test func replaceNotesInTupletWithNoteTooLarge() async throws {
		#expect(throws: TupletError.replacementNotSameDuration) {
			let triplet = try Tuplet(3, .sixteenth, notes: [sixteenthNote, sixteenthNote, sixteenthNote])
			var tuplet = try Tuplet(5,
									.sixteenth,
									notes: [sixteenthNote, triplet, sixteenthNote, sixteenthNote])
			try tuplet.replaceNotes(in: 1 ... 2,
									with: quarterNote1)
		}
	}

    @Test func replaceNotesInTupletWithNoteTooShort() async throws {
		#expect(throws: TupletError.replacementNotSameDuration) {
			let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			var tuplet = try Tuplet(5,
									.quarter,
									notes: [quarterNote1, triplet, quarterNote2, quarterNote3])
			try tuplet.replaceNotes(in: 1 ... 2,
									with: sixteenthNote)
		}
	}

    @Test func replaceNotesWithTupletTooLarge() async throws {
		#expect(throws: TupletError.replacementNotSameDuration) {
			var tuplet = try Tuplet(5,
									.quarter,
									notes: [quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1])
			let replacementTuplet = try Tuplet(
				7,
				.quarter,
				notes: [quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1]
			)
			try tuplet.replaceNotes(in: 1 ... 2, with: replacementTuplet)
		}
	}

    @Test func replaceNotesWithTupletTooShort() async throws {
		#expect(throws: TupletError.replacementNotSameDuration) {
			var tuplet = try Tuplet(5,
									.quarter,
									notes: [quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1])
			let replacementTuplet = try Tuplet(3,
											   .quarter,
											   notes: [quarterNote1, quarterNote1, quarterNote1])
			try tuplet.replaceNotes(in: 1 ... 3, with: replacementTuplet)
		}
	}

    @Test func replaceNotesInTupletWithTupletTooLarge() async throws {
		#expect(throws: TupletError.replacementNotSameDuration) {
			let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote1, quarterNote1])
			var tuplet = try Tuplet(5,
									.quarter,
									notes: [quarterNote1, triplet, quarterNote1, quarterNote1])
			let replacementTuplet = try Tuplet(
				7,
				.quarter,
				notes: [quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1]
			)
			try tuplet.replaceNotes(in: 1 ... 2, with: replacementTuplet)
		}
	}

    @Test func replaceNotesInTupletWithTupletTooShort() async throws {
		#expect(throws: TupletError.replacementNotSameDuration) {
			let nestedTuplet = try Tuplet(
				7,
				.quarter,
				notes: [quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1]
			)
			var tuplet = try Tuplet(
				9,
				.quarter,
				notes: [quarterNote1, nestedTuplet, quarterNote1, quarterNote1, quarterNote1, quarterNote1]
			)
			let replacementTuplet = try Tuplet(
				3,
				.quarter,
				notes: [quarterNote1, quarterNote1, quarterNote1]
			)
			try tuplet.replaceNotes(in: 2 ... 5, with: replacementTuplet)
		}
	}

    @Test func replaceNotesInMultipleTupletsNotCompletelyCoveredWithNoteSameDuration() async throws {
		// If the note range to replace covers only part of a tuplet, it should fail.
		#expect(throws: TupletError.rangeToReplaceMustFullyCoverMultipleTuplets) {
			let triplet = try Tuplet(3, .sixteenth, notes: [sixteenthNote, sixteenthNote, sixteenthNote])
			var tuplet = try Tuplet(5, .sixteenth, notes: [sixteenthNote, triplet, triplet])
			try tuplet.replaceNotes(in: 1 ... 5, with: quarterNote1)
		}
	}

    @Test func replaceNotesInMultipleTupletsNotCompletelyCoveredWithTupletSameDuration() async throws {
		// If the note range to replace covers only part of a tuplet, it should fail.
		#expect(throws: TupletError.rangeToReplaceMustFullyCoverMultipleTuplets) {
			let triplet = try Tuplet(3, .sixteenth, notes: [sixteenthNote, sixteenthNote, sixteenthNote])
			var tuplet = try Tuplet(5, .sixteenth, notes: [sixteenthNote, triplet, triplet])
			let replacementTuplet = try Tuplet(
				5,
				.sixteenth,
				notes: [sixteenthNote, sixteenthNote, sixteenthNote, sixteenthNote, sixteenthNote]
			)
			try tuplet.replaceNotes(in: 1 ... 5, with: replacementTuplet)
		}
	}

	func testReplaceNotesWithFirstNoteBeginAndEndTieWithNoteSameDuration() async throws {
		#expect(throws: TupletError.invalidTieState) {
			var beginAndEnd = eighthNote!
			beginAndEnd.tie = .beginAndEnd
			var end = eighthNote!
			end.tie = .end
			var tuplet = try Tuplet(3, .eighth, notes: [beginAndEnd, end, eighthNote])
			try tuplet.replaceNotes(in: 0 ... 1, with: quarterNote1)
		}
	}

	func testReplaceNotesWithLastNoteBeginAndEndTieWithNoteSameDuration() async throws {
		#expect(throws: TupletError.invalidTieState) {
			var beginAndEnd = eighthNote!
			beginAndEnd.tie = .beginAndEnd
			var begin = eighthNote!
			begin.tie = .begin
			var tuplet = try Tuplet(3, .eighth, notes: [eighthNote, begin, beginAndEnd])
			try tuplet.replaceNotes(in: 1 ... 2, with: quarterNote1)
		}
	}

	// MARK: Successes

	func testReplaceNotesWithNoteSameDuration() async throws {
		assertNoErrorThrown {
			var tuplet = try Tuplet(5, .eighth, notes: [eighthNote, eighthNote, eighthNote, eighthNote, eighthNote])
			try tuplet.replaceNotes(in: 2 ... 3, with: quarterNote1)
			#expect(try tuplet.note(at: 0) == eighthNote)
			#expect(try tuplet.note(at: 1) == eighthNote)
			#expect(try tuplet.note(at: 2) == quarterNote1)
			#expect(try tuplet.note(at: 3) == eighthNote)
		}
	}

	func testReplaceNotesWithTupletSameDuration() async throws {
		assertNoErrorThrown {
			var tuplet = try Tuplet(5, .eighth, notes: [eighthNote, eighthNote, eighthNote, eighthNote, eighthNote])
			let triplet = try Tuplet(3, .eighth, notes: [eighthChord, eighthNote, eighthRest])
			try tuplet.replaceNotes(in: 0 ... 1, with: triplet)
			#expect(try tuplet.note(at: 0) == eighthChord)
			#expect(try tuplet.note(at: 1) == eighthNote)
			#expect(try tuplet.note(at: 2) == eighthRest)
			#expect(try tuplet.note(at: 3) == eighthNote)
			#expect(try tuplet.note(at: 4) == eighthNote)
			#expect(try tuplet.note(at: 5) == eighthNote)
		}
	}

	func testReplaceNotesFromTupletAndNonTupletWithNoteSameDuration() async throws {
		assertNoErrorThrown {
			let triplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			var tuplet = try Tuplet(5, .eighth, notes: [eighthNote, eighthNote, triplet, eighthNote])
			try tuplet.replaceNotes(in: 2 ... 5, with: dottedQuarterNote)
			#expect(try tuplet.note(at: 0) == eighthNote)
			#expect(try tuplet.note(at: 1) == eighthNote)
			#expect(try tuplet.note(at: 2) == dottedQuarterNote)
		}
	}

	func testReplaceNotesFromTupletAndNonTupletWithTupletSameDuration() async throws {
		assertNoErrorThrown {
			let triplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			var tuplet = try Tuplet(5, .eighth, notes: [eighthNote, eighthNote, triplet, eighthNote])
			let quadruplet = try Tuplet(4, .eighth, notes: [eighthChord, eighthRest, eighthNote, eighthChord])
			try tuplet.replaceNotes(in: 2 ... 5, with: quadruplet)
			#expect(try tuplet.note(at: 0) == eighthNote)
			#expect(try tuplet.note(at: 1) == eighthNote)
			#expect(try tuplet.note(at: 2) == eighthChord)
			#expect(try tuplet.note(at: 3) == eighthRest)
			#expect(try tuplet.note(at: 4) == eighthNote)
			#expect(try tuplet.note(at: 5) == eighthChord)
		}
	}

	func testReplaceNotesFrom2FullTupletsWithNoteSameDuration() async throws {
		assertNoErrorThrown {
			let triplet = try Tuplet(3, .sixteenth, notes: [sixteenthNote, sixteenthNote, sixteenthNote])
			var tuplet = try Tuplet(5, .sixteenth, notes: [sixteenthNote, triplet, triplet])
			try tuplet.replaceNotes(in: 1 ... 6, with: quarterNote1)
			#expect(try tuplet.note(at: 0) == sixteenthNote)
			#expect(try tuplet.note(at: 1) == quarterNote1)
		}
	}

	func testReplaceNotesFrom2FullTupletsWithTupletSameDuration() async throws {
		assertNoErrorThrown {
			let triplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			var tuplet = try Tuplet(5, .eighth, notes: [eighthNote, triplet, triplet])
			let replacementTuplet = try Tuplet(5,
											   .eighth,
											   notes: [eighthChord, eighthNote, eighthRest, eighthNote, eighthChord])
			try tuplet.replaceNotes(in: 1 ... 6, with: replacementTuplet)
			#expect(try tuplet.note(at: 0) == eighthNote)
			#expect(try tuplet.note(at: 1) == eighthChord)
			#expect(try tuplet.note(at: 2) == eighthNote)
			#expect(try tuplet.note(at: 3) == eighthRest)
			#expect(try tuplet.note(at: 4) == eighthNote)
			#expect(try tuplet.note(at: 5) == eighthChord)
		}
	}

	// MARK: - replaceNotes<T: NoteCollection>(in:with:[T])

	// replaceNotes<T: NoteCollection>(in:with:T) calls this method, so we will just do one sanity check for failure
	// and success. There is missing coverage of multi-nested tuplets, and that will be checked here too.

	// MARK: Failures

	func testReplaceNotesInTupletWithNotesTooLarge() async throws {
		#expect(throws: TupletError.replacementNotSameDuration) {
			var tuplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			try tuplet.replaceNotes(in: 0 ... 1, with: [eighthNote, eighthNote, eighthNote])
		}
	}

	func testReplaceNotesInvalidRangeOutOfBounds() async throws {
		#expect(throws: TupletError.invalidIndex) {
			var tuplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			try tuplet.replaceNotes(in: 1 ... 4, with: [eighthNote, eighthNote, eighthNote, eighthNote])
		}
	}

	// MARK: Successes

	func testReplaceNotesInMultiNestedCompoundTupletWithNotesOfSameDuration() async throws {
		let triplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
		let quintuplet = try Tuplet(5, .eighth, notes: [triplet, triplet, eighthNote])
		var tuplet = try Tuplet(9, .eighth, notes: [triplet, quintuplet, eighthNote, eighthNote, eighthNote])
		try tuplet.replaceNotes(in: 6 ... 8, with: [eighthRest, eighthRest])
		#expect(try tuplet.note(at: 0) == eighthNote)
		#expect(try tuplet.note(at: 1) == eighthNote)
		#expect(try tuplet.note(at: 2) == eighthNote)
		#expect(try tuplet.note(at: 3) == eighthNote)
		#expect(try tuplet.note(at: 4) == eighthNote)
		#expect(try tuplet.note(at: 5) == eighthNote)

		#expect(try tuplet.note(at: 6) == eighthRest)
		#expect(try tuplet.note(at: 7) == eighthRest)

		#expect(try tuplet.note(at: 8) == eighthNote)

		#expect(try tuplet.note(at: 9) == eighthNote)
		#expect(try tuplet.note(at: 10) == eighthNote)
		#expect(try tuplet.note(at: 11) == eighthNote)
	}

	func replaceNotesWithinMultiNestedCompoundTupletAndNotesWithNotesOfSameDuration() async throws {
		// Create same compound tuplet as above test
		let triplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
		let quintuplet = try Tuplet(5, .eighth, notes: [triplet, triplet, eighthNote])
		var tuplet = try Tuplet(9, .eighth, notes: [triplet, quintuplet, eighthNote, eighthNote, eighthNote])
		let notes: [Note] = [quarterNote1, quarterNote1, eighthRest]
		try tuplet.replaceNotes(in: 3 ... 10, with: notes)
		#expect(try tuplet.note(at: 0) == eighthNote)
		#expect(try tuplet.note(at: 1) == eighthNote)
		#expect(try tuplet.note(at: 2) == eighthNote)
		#expect(try tuplet.note(at: 3) == quarterNote1)
		#expect(try tuplet.note(at: 4) == quarterNote1)
		#expect(try tuplet.note(at: 5) == eighthRest)
		#expect(try tuplet.note(at: 6) == eighthNote)
		#expect(try tuplet.note(at: 7) == eighthNote)
	}

	@Test func replaceNotesFromFirstToLastInTupletWithNotesOfSameDuration() async throws {
		let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
		var tuplet = try Tuplet(3, .quarter, notes: [quarterNote1, triplet])
		try tuplet.replaceNotes(in: 0 ... 3, with: [quarterNote3, quarterNote2, quarterNote1])
		#expect(try tuplet.note(at: 0) == quarterNote3)
		#expect(try tuplet.note(at: 1) == quarterNote2)
		#expect(try tuplet.note(at: 2) == quarterNote1)
	}

	func testReplaceNotesFromFirstToSecondToLastInTupletWithNotesOfSameDuration() async throws {
		let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
		var tuplet = try Tuplet(5, .quarter, notes: [quarterNote1, triplet, quarterNote2, quarterNote3])
		try tuplet.replaceNotes(in: 0 ... 3, with: [quarterNote3, quarterNote2, quarterNote1])
		#expect(try tuplet.note(at: 0) == quarterNote3)
		#expect(try tuplet.note(at: 1) == quarterNote2)
		#expect(try tuplet.note(at: 2) == quarterNote1)
		#expect(try tuplet.note(at: 3) == quarterNote2)
		#expect(try tuplet.note(at: 4) == quarterNote3)
	}

	// MARK: - isCompound

	func testIsCompoundTrue() async throws {
		let triplet = try? Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
		#expect(triplet != nil)
		let compound = try Tuplet(
			5,
			.eighth,
			notes: [
				triplet!, eighthNote, eighthNote, eighthNote,
			]
		)
		#expect(compound.isCompound)
	}

	func testIsCompoundFalse() async throws {
		let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
		#expect(!triplet.isCompound)
	}

	// MARK: - ==(lhs:rhs:)

	// MARK: Failures

	func testEqualityDifferentNumberOfNotes() async throws {
		let tuplet1 = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
		let tuplet2 = try Tuplet(3, .eighth, notes: [quarterNote1, eighthNote])
		#expect(tuplet1 != tuplet2)
	}

	func testEqualityDifferentNotes() async throws {
		let tuplet1 = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
		let tuplet2 = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote1, quarterNote1])
		#expect(tuplet1 != tuplet2)
	}

	func testEqualitySameNotesDifferentTimingCount() async throws {
		let tuplet1 = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
		let tuplet2 = try Tuplet(3, .eighth, inSpaceOf: 1, notes: [eighthNote, eighthNote, eighthNote])
		#expect(tuplet1 != tuplet2)
	}

	@Test func equalityDifferentDuration() async throws {
		let tuplet1 = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
		let tuplet2 = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote1, quarterNote1])
		#expect(tuplet1 != tuplet2)
	}

	// MARK: Success

	@Test func equalityTrue() async throws {
		let tuplet1 = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
		let tuplet2 = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
		#expect(tuplet1 == tuplet2)
	}
}
