//
//  TupletTests.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 6/19/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

import XCTest
@testable import MusicNotationKit

class TupletTests: XCTestCase {

	let tone1 = Tone(noteLetter: .a, octave: .octave1)
	let tone2 = Tone(noteLetter: .b, accidental: .sharp, octave: .octave1)
	let tone3 = Tone(noteLetter: .d, accidental: .natural, octave: .octave1)
	let quarterRest = Note(noteDuration: .quarter)
	let eighthRest = Note(noteDuration: .eighth)
    let dottedQuarterNote = Note(noteDuration: try! NoteDuration(value: .quarter, dotCount: 1),
                                 tone: Tone(noteLetter: .c, octave: .octave3))
	var quarterNote1: Note!
	var quarterNote2: Note!
	var quarterNote3: Note!
	var eighthNote: Note!
	var quarterChord: Note!
	var eighthChord: Note!
	
    override func setUp() {
        super.setUp()
        quarterNote1 = Note(noteDuration: .quarter, tone: tone1)
        quarterNote2 = Note(noteDuration: .quarter, tone: tone1)
        quarterNote3 = Note(noteDuration: .quarter, tone: tone2)
        eighthNote = Note(noteDuration: .eighth, tone: tone1)
        quarterChord = Note(noteDuration: .quarter, tones: [tone1, tone2, tone3])
        eighthChord = Note(noteDuration: .eighth, tones: [tone1, tone2, tone3])
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // MARK: - init(notes:)
    // MARK: Failures

    func testInitFailForCountLessThan2() {
        assertThrowsError(TupletError.countMustBeLargerThan1) {
            let _ = try Tuplet(1, .quarter, notes: [quarterNote1])
        }
    }

    func testInitFailForOddCountNoBaseCount() {
        // count specified is something not in 2-9 range and no base count specified
        assertThrowsError(TupletError.countHasNoStandardRatio) {
            let _ = try Tuplet(
                10,
                .quarter,
                notes: [
                    quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2,
                    quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2
                ])
        }
    }

    func testInitFailForEmptyNotes() {
        // standard ratio
        assertThrowsError(TupletError.notesDoNotFillTuplet) {
            let _ = try Tuplet(3, .eighth, notes: [])
        }

        // non-standard ratio
        assertThrowsError(TupletError.notesDoNotFillTuplet) {
            let _ = try Tuplet(11, .eighth, inSpaceOf: 9, notes: [])
        }
    }

    func testInitFailForNotesSameDurationNotEnough() {
        // standard ratio
        assertThrowsError(TupletError.notesDoNotFillTuplet) {
            let _ = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2])
        }
        
        // non-standard ratio
        assertThrowsError(TupletError.notesDoNotFillTuplet) {
            let _ = try Tuplet(11, .quarter, inSpaceOf: 9, notes: [quarterNote1, quarterNote2, quarterNote3])
        }
    }

    func testInitFailForNotesSameDurationTooMany() {
        // standard ratio
        assertThrowsError(TupletError.notesOverfillTuplet) {
            let _ = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1])
        }

        // non-standard ratio
        assertThrowsError(TupletError.notesOverfillTuplet) {
            let _ = try Tuplet(
                5,
                .quarter,
                inSpaceOf: 2,
                notes: [
                    quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3, quarterNote1
                ])
        }
    }

    func testInitFailForNotesShorterNotEnough() {
        // standard ratio
        assertThrowsError(TupletError.notesDoNotFillTuplet) {
            let _ = try Tuplet(4, .quarter, notes: [eighthNote, eighthNote, quarterNote1])
        }

        // non-standard ratio
        assertThrowsError(TupletError.notesDoNotFillTuplet) {
            let _ = try Tuplet(
                5,
                .quarter,
                inSpaceOf: 3,
                notes: [
                    eighthNote, eighthNote,
                    eighthNote, eighthNote,
                    quarterNote3
                ])
        }
    }

    func testInitFailForShorterTooMany() {
        // standard ratio
        assertThrowsError(TupletError.notesOverfillTuplet) {
            let _ = try Tuplet(
                4,
                .quarter,
                notes: [
                    eighthNote, eighthNote, eighthNote, eighthNote, quarterNote1, quarterNote2, quarterNote3
                ])
        }

        // non-standard ratio
        assertThrowsError(TupletError.notesOverfillTuplet) {
            let _ = try Tuplet(
                5,
                .quarter,
                inSpaceOf: 2,
                notes: [
                    quarterNote1, quarterNote2, quarterNote3,
                    eighthNote, eighthNote, quarterNote1, eighthNote
                ])
        }
    }

    func testInitFailForLongerNotEnough() {
        // standard ratio
        assertThrowsError(TupletError.notesDoNotFillTuplet) {
            let _ = try Tuplet(4, .eighth, notes: [quarterNote1, eighthNote])
        }

        // non-standard ratio
        assertThrowsError(TupletError.notesDoNotFillTuplet) {
            let _ = try Tuplet(11, .eighth, inSpaceOf: 9, notes: [eighthNote, eighthNote, quarterNote1])
        }
    }

    func testInitFailForLongerTooMany() {
        // standard ratio
        assertThrowsError(TupletError.notesOverfillTuplet) {
            let _ = try Tuplet(
                5,
                .eighth,
                notes: [
                    eighthNote, quarterNote1, eighthNote, quarterNote2
                ])
        }

        // non-standard ratio
        assertThrowsError(TupletError.notesOverfillTuplet) {
            let _ = try Tuplet(
                5,
                .eighth,
                inSpaceOf: 2,
                notes: [
                    eighthNote, quarterNote1, eighthNote, quarterNote2
                ])
        }
    }

    func testInitFailForSameDurationWithRestsNotEnough() {
        // standard ratio
        assertThrowsError(TupletError.notesDoNotFillTuplet) {
            let _ = try Tuplet(3, .quarter, notes: [quarterNote1, quarterRest])
        }

        // non-standard ratio
        assertThrowsError(TupletError.notesDoNotFillTuplet) {
            let _ = try Tuplet(11, .quarter, inSpaceOf: 9, notes: [quarterNote1, quarterRest, quarterNote3])
        }
    }

    func testInitFailForCompoundTupletTooLarge() {
        assertThrowsError(TupletError.notesOverfillTuplet) {
            // This is worth 4 quarter notes
            let quintuplet = try? Tuplet(
                5,
                .quarter,
                notes: [
                    quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2
                ])
            XCTAssertNotNil(quintuplet)
            // 8 quarter notes long instead of 7
            let _ = try Tuplet(
                7,
                .quarter,
                notes: [
                    quarterNote1, quarterNote2, quarterNote3, quarterNote1,
                    quintuplet!
                ])
        }
    }

    func testInitFailForCompoundTupletTooSmall() {
        assertThrowsError(TupletError.notesDoNotFillTuplet) {
            let triplet = try? Tuplet(
                3,
                .quarter,
                notes: [
                    quarterNote1, quarterNote2, quarterNote3
                ])
            XCTAssertNotNil(triplet)
            let _ = try Tuplet(
                7,
                .quarter,
                notes: [
                    quarterNote1, quarterNote2, quarterNote3,
                    triplet!
                ])
        }
    }

    // MARK: Successes

	func testInitSuccessForAllStandardCombinations() {
        assertNoErrorThrown {
			// Test 2 - 9
			let _ = try Tuplet(
                2,
                .quarter,
                notes: [
                    quarterNote1, quarterNote2
                ])
			let _ = try Tuplet(
                3,
                .quarter,
                notes: [
                    quarterNote1, quarterNote2, quarterNote3
                ])
            let _ = try Tuplet(
                4,
                .quarter,
                notes: [
                    quarterNote1, quarterNote2, quarterNote3, quarterNote1
                ])
            let _ = try Tuplet(
                5,
                .quarter,
                notes: [
                    quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2
                ])
            let _ = try Tuplet(
                6,
                .quarter,
                notes: [
                    quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3
                ])
            let _ = try Tuplet(
                7,
                .quarter,
                notes: [
                    quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3, quarterNote1
                ])
            let _ = try Tuplet(
                8,
                .quarter,
                notes: [
                    quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3, quarterNote1,
                    quarterNote2
                ])
            let _ = try Tuplet(
                9,
                .quarter,
                notes: [
                    quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3, quarterNote1,
                    quarterNote2, quarterNote3
                ])
			// Test with a chord
			let _ = try Tuplet(
                2,
                .quarter,
                notes: [
                    quarterNote1, quarterChord
                ])
		}
	}

    func testInitSuccessForStandardMixedDurations() {
        assertNoErrorThrown {
            let _ = try Tuplet(
                5,
                .quarter,
                notes: [
                    quarterNote1, eighthNote, eighthNote, quarterNote2, quarterNote3, eighthNote, eighthNote
                ])
        }
    }

    func testInitSuccessForStandardDottedBase() {
        assertNoErrorThrown {
            let baseDuration = try? NoteDuration(value: .quarter, dotCount: 1)
            XCTAssertNotNil(baseDuration)
            let _ = try Tuplet(
                3,
                baseDuration!,
                notes: [
                    dottedQuarterNote, dottedQuarterNote, dottedQuarterNote
                ])
        }
    }

    func testInitSuccessForStandardDottedBaseMixedDuration() {
        assertNoErrorThrown {
            let baseDuration = try? NoteDuration(value: .quarter, dotCount: 1)
            XCTAssertNotNil(baseDuration)
            let _ = try Tuplet(
                3,
                baseDuration!,
                notes: [
                    dottedQuarterNote, quarterNote1, eighthNote, dottedQuarterNote
                ])
        }
    }

    func testInitSuccessForStandardCompound() {
        assertNoErrorThrown {
            let triplet = try? Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
            XCTAssertNotNil(triplet)
            let _ = try Tuplet(
                5,
                .eighth,
                notes: [
                    triplet!, eighthNote, eighthNote, eighthNote
                ]
            )
        }
    }

    func testInitSuccessForStandardWithRests() {
        assertNoErrorThrown {
            let _ = try Tuplet(3, .quarter, notes: [quarterNote1, quarterRest, quarterNote3])
        }
    }

    func testInitSuccessForNonStandardSameDuration() {
        assertNoErrorThrown {
            let _ = try Tuplet(
                7,
                .eighth,
                inSpaceOf: 6,
                notes: [
                    eighthNote, eighthNote, eighthNote, eighthNote,
                    eighthNote, eighthNote, eighthNote
                ])
        }
    }

    func testInitSuccessForNonStandardDottedBase() {
        assertNoErrorThrown {
            let _ = try Tuplet(
                4,
                NoteDuration(value: .quarter, dotCount: 1),
                inSpaceOf: 2,
                notes: [
                    dottedQuarterNote, dottedQuarterNote, dottedQuarterNote, dottedQuarterNote,
                ])
        }
    }

    func testInitSuccessForNonStandardCompound() {
        assertNoErrorThrown {
            // Space of 4 eighth notes
            let quintuplet = try? Tuplet(5, .eighth, notes: [eighthNote, eighthNote, eighthNote, eighthNote, eighthNote])
            XCTAssertNotNil(quintuplet)
            let _ = try Tuplet(
                11,
                .eighth,
                inSpaceOf: 9,
                notes: [
                    quintuplet!, eighthNote, eighthNote, eighthNote,
                    eighthNote, eighthNote, eighthNote, eighthNote
                ])
        }
    }

    func testInitSuccessForNonStandardNestedCompound() {
        assertNoErrorThrown {
            // Space of 4 eighth notes
            let triplet = try? Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
            XCTAssertNotNil(triplet)
            let quintuplet = try Tuplet(5, .eighth, notes: [eighthNote, eighthNote, eighthNote, triplet!])
            XCTAssertNotNil(quintuplet)
            let _ = try Tuplet(
                11,
                .eighth,
                inSpaceOf: 9,
                notes: [
                    quintuplet, eighthNote, eighthNote, eighthNote,
                    eighthNote, eighthNote, eighthNote, eighthNote
                ])
        }
    }

    func testInitSuccessForNonStandardWithRests() {
        assertNoErrorThrown {
            let _ = try Tuplet(
                7,
                .quarter,
                inSpaceOf: 6,
                notes: [
                    quarterNote1, quarterNote2, quarterRest, quarterNote3,
                    quarterRest, quarterRest, quarterNote1
                ])
        }
    }

    // MARK: - replaceNote(at:with:Note)
    // MARK: Failures

    func testReplaceNoteWithNoteTooLong() {
        assertThrowsError(TupletError.replacingCollectionNotSameDuration) {
            var tuplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
            try tuplet.replaceNote(at: 1, with: quarterNote1)
        }
    }

    func testReplaceNoteWithNoteTooShort() {
        assertThrowsError(TupletError.replacingCollectionNotSameDuration) {
            var tuplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
            try tuplet.replaceNote(at: 0, with: eighthNote)
        }
    }

    func testReplaceNoteInTupletWithNoteTooShort() {
        assertThrowsError(TupletError.replacingCollectionNotSameDuration) {
            let triplet = try? Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
            XCTAssertNotNil(triplet)
            var tuplet = try Tuplet(5, .quarter, notes: [
                triplet!, quarterNote1, quarterNote2, quarterNote3
                ])
            try tuplet.replaceNote(at: 1, with: eighthNote)
        }
    }

    func testReplaceNoteInTupletWithNoteTooLong() {
        assertThrowsError(TupletError.replacingCollectionNotSameDuration) {
            let triplet = try? Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
            XCTAssertNotNil(triplet)
            var tuplet = try Tuplet(5, .eighth, notes: [
                triplet!, eighthNote, eighthNote, eighthNote
                ])
            try tuplet.replaceNote(at: 1, with: quarterNote1)
        }
    }

    // MARK: Successes

    func testReplaceNoteWithRestOfSameDuration() {
        assertNoErrorThrown {
            var tuplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
            try tuplet.replaceNote(at: 0, with: quarterRest)
            XCTAssertEqual(try tuplet.note(at: 0), quarterRest)
            XCTAssertEqual(try tuplet.note(at: 1), quarterNote2)
            XCTAssertEqual(try tuplet.note(at: 2), quarterNote3)
        }
    }

    func testReplaceNoteInTupletWithRestOfSameDuration() {
        assertNoErrorThrown {
            let triplet = try? Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
            XCTAssertNotNil(triplet)
            var tuplet = try Tuplet(5, .quarter, notes: [
                triplet!, quarterNote1, quarterNote2, quarterNote3
                ])
            try tuplet.replaceNote(at: 1, with: quarterRest)
            XCTAssertEqual(try tuplet.note(at: 0), quarterNote1)
            XCTAssertEqual(try tuplet.note(at: 1), quarterRest)
            XCTAssertEqual(try tuplet.note(at: 2), quarterNote3)
            XCTAssertEqual(try tuplet.note(at: 3), quarterNote1)
            XCTAssertEqual(try tuplet.note(at: 4), quarterNote2)
            XCTAssertEqual(try tuplet.note(at: 5), quarterNote3)
        }
    }

    func testReplaceNoteWithNoteOfSameDuration() {
        assertNoErrorThrown {
            var tuplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
            try tuplet.replaceNote(at: 0, with: quarterNote3)
            XCTAssertEqual(try tuplet.note(at: 0), quarterNote3)
            XCTAssertEqual(try tuplet.note(at: 1), quarterNote2)
            XCTAssertEqual(try tuplet.note(at: 2), quarterNote3)
        }
    }

    func testReplaceNoteInTupletWithNoteOfSameDuration() {
        assertNoErrorThrown {
            let triplet = try? Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
            XCTAssertNotNil(triplet)
            var tuplet = try Tuplet(5, .quarter, notes: [
                triplet!, quarterNote1, quarterNote2, quarterNote3
                ])
            try tuplet.replaceNote(at: 1, with: quarterNote1)
            XCTAssertEqual(try tuplet.note(at: 0), quarterNote1)
            XCTAssertEqual(try tuplet.note(at: 1), quarterNote1)
            XCTAssertEqual(try tuplet.note(at: 2), quarterNote3)
            XCTAssertEqual(try tuplet.note(at: 3), quarterNote1)
            XCTAssertEqual(try tuplet.note(at: 4), quarterNote2)
            XCTAssertEqual(try tuplet.note(at: 5), quarterNote3)
        }
    }

    // MARK: - replaceNote(at:with:[Note])
    // MARK: Failures

    // MARK: Successes


    // MARK: - replaceNote(at:with:Tuplet)
    // MARK: Failures

    func testReplaceNoteWithTupletTooLong() {

    }

    func testReplaceNoteWithTupletTooShort() {

    }

    func testReplaceNoteInTupletWithTupletTooLong() {

    }

    func testReplaceNoteInTupletWithTupletTooShort() {

    }

    // MARK: Successes

    // MARK: - replaceNotes(in:with:Note)
    // MARK: Failures

    // MARK: Successes

    // MARK: - replaceNotes(in:with:[Note])
    // MARK: Failures

    // MARK: Successes

    // MARK: - replaceNotes(in:with:Tuplet)
    // MARK: Failures

    // MARK: Successes
}
