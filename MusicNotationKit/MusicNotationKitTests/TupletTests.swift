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
    let tone2 = Tone(accidental: .sharp, noteLetter: .b, octave: .octave1)
    let tone3 = Tone(accidental: .natural, noteLetter: .d, octave: .octave1)
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
    var sixteenthNote: Note!

    override func setUp() {
        super.setUp()
        quarterNote1 = Note(noteDuration: .quarter, tone: tone1)
        quarterNote2 = Note(noteDuration: .quarter, tone: tone1)
        quarterNote3 = Note(noteDuration: .quarter, tone: tone2)
        eighthNote = Note(noteDuration: .eighth, tone: tone1)
        quarterChord = Note(noteDuration: .quarter, tones: [tone1, tone2, tone3])
        eighthChord = Note(noteDuration: .eighth, tones: [tone1, tone2, tone3])
        sixteenthNote = Note(noteDuration: .sixteenth, tone: tone1)
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

    // MARK: - note(at:)
    // MARK: Failures

    func testNoteAtForInvalidIndexNegative() {
        assertThrowsError(TupletError.invalidIndex) {
            let tuplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
            _ = try tuplet.note(at: -1)
        }
    }

    func testNoteAtForInvalidIndexTooLarge() {
        assertThrowsError(TupletError.invalidIndex) {
            let tuplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
            _ = try tuplet.note(at: 5)
        }
    }

    // MARK: Successes

    func testNoteAtSuccess() {
        assertNoErrorThrown() {
            let tuplet = try Tuplet(5, .eighth, notes: [eighthNote, eighthNote, eighthRest, eighthNote, eighthNote])
            let note = try tuplet.note(at: 2)
            XCTAssertEqual(note, eighthRest)
        }
    }

    // MARK: - replaceNote<T: NoteCollection>(at:with:T)
    // MARK: Failures

    func testReplaceNoteWithNoteTooLong() {
        assertThrowsError(TupletError.replacementNotSameDuration) {
            var tuplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
            try tuplet.replaceNote(at: 1, with: quarterNote1)
        }
    }

    func testReplaceNoteWithNoteTooShort() {
        assertThrowsError(TupletError.replacementNotSameDuration) {
            var tuplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
            try tuplet.replaceNote(at: 0, with: eighthNote)
        }
    }

    func testReplaceNoteInTupletWithNoteTooShort() {
        assertThrowsError(TupletError.replacementNotSameDuration) {
            let triplet = try? Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
            XCTAssertNotNil(triplet)
            var tuplet = try Tuplet(5, .quarter, notes: [
                triplet!, quarterNote1, quarterNote2, quarterNote3
                ])
            try tuplet.replaceNote(at: 1, with: eighthNote)
        }
    }

    func testReplaceNoteInTupletWithNoteTooLong() {
        assertThrowsError(TupletError.replacementNotSameDuration) {
            let triplet = try? Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
            XCTAssertNotNil(triplet)
            var tuplet = try Tuplet(5, .eighth, notes: [
                triplet!, eighthNote, eighthNote, eighthNote
                ])
            try tuplet.replaceNote(at: 1, with: quarterNote1)
        }
    }

    func testReplaceNoteWithTupletTooLong() {
        assertThrowsError(TupletError.replacementNotSameDuration) {
            let triplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
            var tuplet = try Tuplet(5, .eighth, notes: [eighthNote, eighthNote, eighthNote, eighthNote, eighthNote])
            try tuplet.replaceNote(at: 0, with: triplet)
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
            let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
            var tuplet = try Tuplet(5,
                                    .quarter,
                                    notes: [triplet, quarterNote1, quarterNote2, quarterNote3])
            try tuplet.replaceNote(at: 1, with: quarterNote1)
            XCTAssertEqual(try tuplet.note(at: 0), quarterNote1)
            XCTAssertEqual(try tuplet.note(at: 1), quarterNote1)
            XCTAssertEqual(try tuplet.note(at: 2), quarterNote3)
            XCTAssertEqual(try tuplet.note(at: 3), quarterNote1)
            XCTAssertEqual(try tuplet.note(at: 4), quarterNote2)
            XCTAssertEqual(try tuplet.note(at: 5), quarterNote3)
        }
    }

    // MARK: - replaceNote<T: NoteCollection>(at:with:[T])
    // MARK: Failures

    func testReplaceNoteWithArrayOfNotesTooLong() {
        assertThrowsError(TupletError.replacementNotSameDuration) {
            var triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
            try triplet.replaceNote(at: 1, with: [eighthNote, eighthNote, eighthNote])
        }
    }

    func testReplaceNoteWithArrayOfNotesTooShort() {
        assertThrowsError(TupletError.replacementNotSameDuration) {
            var triplet = try Tuplet(3,
                                     NoteDuration(value: .quarter, dotCount: 1),
                                     notes: [dottedQuarterNote, dottedQuarterNote, dottedQuarterNote])
            try triplet.replaceNote(at: 1, with: [eighthNote, eighthNote])
        }
    }

    func testReplaceNoteInTupletWithArrayOfNotesTooLong() {
        assertThrowsError(TupletError.replacementNotSameDuration) {
            let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
            var tuplet = try Tuplet(5,
                                    .quarter,
                                    notes: [triplet, quarterNote1, quarterNote2, quarterNote3])
            try tuplet.replaceNote(at: 2, with: [quarterNote1, quarterNote2])
        }
    }

    func testReplaceNoteInTupletWithArrayOfNotesTooShort() {
        assertThrowsError(TupletError.replacementNotSameDuration) {
            let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
            var tuplet = try Tuplet(5,
                                    .quarter,
                                    notes: [triplet, quarterNote1, quarterNote2, quarterNote3])
            try tuplet.replaceNote(at: 0, with: [eighthNote])
        }
    }

    func testReplaceNoteInTupletWithArrayOfTupletsTooLong() {
        assertThrowsError(TupletError.replacementNotSameDuration) {
            let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
            var tuplet = try Tuplet(5,
                                    .quarter,
                                    notes: [triplet, quarterNote1, quarterNote2, quarterNote3])
            let newTuplet = try Tuplet(5, .eighth, notes: [eighthNote, eighthNote, eighthNote, eighthNote, eighthNote])
            try tuplet.replaceNote(at: 0, with: [newTuplet])
        }
    }

    func testReplaceNoteInTupletWithArrayOfTupletsTooShort() {
        assertThrowsError(TupletError.replacementNotSameDuration) {
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

    func testReplaceNoteWithArrayOfNotesSameDuration() {
        assertNoErrorThrown {
            var tuplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
            try tuplet.replaceNote(at: 0, with: [eighthNote, eighthNote])
            XCTAssertEqual(try tuplet.note(at: 0), eighthNote)
            XCTAssertEqual(try tuplet.note(at: 1), eighthNote)
            XCTAssertEqual(try tuplet.note(at: 2), quarterNote2)
            XCTAssertEqual(try tuplet.note(at: 3), quarterNote3)
        }
    }

    func testReplaceNoteWithArrayOfRestsSameDuration() {
        assertNoErrorThrown {
            var tuplet = try Tuplet(3,
                                    NoteDuration(value: .quarter, dotCount: 1),
                                    notes: [dottedQuarterNote, dottedQuarterNote, dottedQuarterNote])
            try tuplet.replaceNote(at: 1, with: [eighthRest, eighthRest, eighthRest])
            XCTAssertEqual(try tuplet.note(at: 0), dottedQuarterNote)
            XCTAssertEqual(try tuplet.note(at: 1), eighthRest)
            XCTAssertEqual(try tuplet.note(at: 2), eighthRest)
            XCTAssertEqual(try tuplet.note(at: 3), eighthRest)
            XCTAssertEqual(try tuplet.note(at: 4), dottedQuarterNote)
        }
    }

    func testReplaceNoteInTupletWithArrayOfNotesSameDuration() {
        assertNoErrorThrown {
            let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
            var tuplet = try Tuplet(5, .quarter, notes: [quarterNote1, triplet, quarterNote2, quarterNote3])
            try tuplet.replaceNote(at: 2, with: [eighthNote, eighthNote])
            XCTAssertEqual(try tuplet.note(at: 0), quarterNote1)
            XCTAssertEqual(try tuplet.note(at: 1), quarterNote1)
            XCTAssertEqual(try tuplet.note(at: 2), eighthNote)
            XCTAssertEqual(try tuplet.note(at: 3), eighthNote)
            XCTAssertEqual(try tuplet.note(at: 4), quarterNote3)
            XCTAssertEqual(try tuplet.note(at: 5), quarterNote2)
            XCTAssertEqual(try tuplet.note(at: 6), quarterNote3)
        }
    }

    func testReplaceNoteWithArrayOfTupletsSameDuration() {
        assertNoErrorThrown {
            var tuplet = try Tuplet(5,
                                    .quarter,
                                    notes: [quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1])
            let triplet = try Tuplet(3, .sixteenth, notes: [sixteenthNote, sixteenthNote, sixteenthNote])
            try tuplet.replaceNote(at: 1, with: [triplet, triplet])
            XCTAssertEqual(try tuplet.note(at: 0), quarterNote1)
            XCTAssertEqual(try tuplet.note(at: 1), sixteenthNote)
            XCTAssertEqual(try tuplet.note(at: 2), sixteenthNote)
            XCTAssertEqual(try tuplet.note(at: 3), sixteenthNote)

            XCTAssertEqual(try tuplet.note(at: 4), sixteenthNote)
            XCTAssertEqual(try tuplet.note(at: 5), sixteenthNote)
            XCTAssertEqual(try tuplet.note(at: 6), sixteenthNote)

            XCTAssertEqual(try tuplet.note(at: 7), quarterNote1)
            XCTAssertEqual(try tuplet.note(at: 8), quarterNote1)
            XCTAssertEqual(try tuplet.note(at: 9), quarterNote1)
        }
    }

    // MARK: - replaceNotes<T: NoteCollection>(in:with:T)
    // MARK: Failures

    func testReplaceNotesWithNoteTooLarge() {
        assertThrowsError(TupletError.replacementNotSameDuration) {
            var tuplet = try Tuplet(5,
                                    .sixteenth,
                                    notes: [sixteenthNote, sixteenthNote, sixteenthNote, sixteenthNote, sixteenthNote])
            try tuplet.replaceNotes(in: 1...2,
                                    with: quarterNote1)
        }
    }

    func testReplaceNotesWithNoteTooShort() {
        assertThrowsError(TupletError.replacementNotSameDuration) {
            var tuplet = try Tuplet(5,
                                    .quarter,
                                    notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2])
            try tuplet.replaceNotes(in: 2...3,
                                    with: eighthNote)
        }
    }

    func testReplaceNotesInTupletWithNoteTooLarge() {
        assertThrowsError(TupletError.replacementNotSameDuration) {
            let triplet = try Tuplet(3, .sixteenth, notes: [sixteenthNote, sixteenthNote, sixteenthNote])
            var tuplet = try Tuplet(5,
                                    .sixteenth,
                                    notes: [sixteenthNote, triplet, sixteenthNote, sixteenthNote])
            try tuplet.replaceNotes(in: 1...2,
                                    with: quarterNote1)
        }
    }

    func testReplaceNotesInTupletWithNoteTooShort() {
        assertThrowsError(TupletError.replacementNotSameDuration) {
            let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
            var tuplet = try Tuplet(5,
                                    .quarter,
                                    notes: [quarterNote1, triplet, quarterNote2, quarterNote3])
            try tuplet.replaceNotes(in: 1...2,
                                    with: sixteenthNote)
        }
    }

    func testReplaceNotesWithTupletTooLarge() {
        assertThrowsError(TupletError.replacementNotSameDuration) {
            var tuplet = try Tuplet(5,
                                    .quarter,
                                    notes: [quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1])
            let replacementTuplet = try Tuplet(
                7,
                .quarter,
                notes: [quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1])
            try tuplet.replaceNotes(in: 1...2, with: replacementTuplet)
        }
    }

    func testReplaceNotesWithTupletTooShort() {
        assertThrowsError(TupletError.replacementNotSameDuration) {
            var tuplet = try Tuplet(5,
                                    .quarter,
                                    notes: [quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1])
            let replacementTuplet = try Tuplet(3,
                                               .quarter,
                                               notes: [quarterNote1, quarterNote1, quarterNote1])
            try tuplet.replaceNotes(in: 1...3, with: replacementTuplet)
        }
    }

    func testReplaceNotesInTupletWithTupletTooLarge() {
        assertThrowsError(TupletError.replacementNotSameDuration) {
            let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote1, quarterNote1])
            var tuplet = try Tuplet(5,
                                    .quarter,
                                    notes: [quarterNote1, triplet, quarterNote1, quarterNote1])
            let replacementTuplet = try Tuplet(
                7,
                .quarter,
                notes: [quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1])
            try tuplet.replaceNotes(in: 1...2, with: replacementTuplet)
        }
    }

    func testReplaceNotesInTupletWithTupletTooShort() {
        assertThrowsError(TupletError.replacementNotSameDuration) {
            let nestedTuplet = try Tuplet(
                7,
                .quarter,
                notes: [quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1])
            var tuplet = try Tuplet(
                9,
                .quarter,
                notes: [quarterNote1, nestedTuplet, quarterNote1, quarterNote1, quarterNote1, quarterNote1])
            let replacementTuplet = try Tuplet(
                3,
                .quarter,
                notes: [quarterNote1, quarterNote1, quarterNote1])
            try tuplet.replaceNotes(in: 2...5, with: replacementTuplet)
        }
    }

    func testReplaceNotesInMultipleTupletsNotCompletelyCoveredWithNoteSameDuration() {
        // If the note range to replace covers only part of a tuplet, it should fail.
        assertThrowsError(TupletError.rangeToReplaceMustFullyCoverMultipleTuplets) {
            let triplet = try Tuplet(3, .sixteenth, notes: [sixteenthNote, sixteenthNote, sixteenthNote])
            var tuplet = try Tuplet(5, .sixteenth, notes: [sixteenthNote, triplet, triplet])
            try tuplet.replaceNotes(in: 1...5, with: quarterNote1)
        }
    }
    
    func testReplaceNotesInMultipleTupletsNotCompletelyCoveredWithTupletSameDuration() {
        // If the note range to replace covers only part of a tuplet, it should fail.
        assertThrowsError(TupletError.rangeToReplaceMustFullyCoverMultipleTuplets) {
            let triplet = try Tuplet(3, .sixteenth, notes: [sixteenthNote, sixteenthNote, sixteenthNote])
            var tuplet = try Tuplet(5, .sixteenth, notes: [sixteenthNote, triplet, triplet])
            let replacementTuplet = try Tuplet(
                5,
                .sixteenth,
                notes: [sixteenthNote, sixteenthNote, sixteenthNote, sixteenthNote, sixteenthNote])
            try tuplet.replaceNotes(in: 1...5, with: replacementTuplet)
        }
    }

    // MARK: Successes

    func testReplaceNotesWithNoteSameDuration() {
        assertNoErrorThrown {
            var tuplet = try Tuplet(5, .eighth, notes: [eighthNote, eighthNote, eighthNote, eighthNote, eighthNote])
            try tuplet.replaceNotes(in: 2...3, with: quarterNote1)
            XCTAssertEqual(try tuplet.note(at: 0), eighthNote)
            XCTAssertEqual(try tuplet.note(at: 1), eighthNote)
            XCTAssertEqual(try tuplet.note(at: 2), quarterNote1)
            XCTAssertEqual(try tuplet.note(at: 3), eighthNote)
        }
    }

    func testReplaceNotesWithTupletSameDuration() {
        assertNoErrorThrown {
            var tuplet = try Tuplet(5, .eighth, notes: [eighthNote, eighthNote, eighthNote, eighthNote, eighthNote])
            let triplet = try Tuplet(3, .eighth, notes: [eighthChord, eighthNote, eighthRest])
            try tuplet.replaceNotes(in: 0...1, with: triplet)
            XCTAssertEqual(try tuplet.note(at: 0), eighthChord)
            XCTAssertEqual(try tuplet.note(at: 1), eighthNote)
            XCTAssertEqual(try tuplet.note(at: 2), eighthRest)
            XCTAssertEqual(try tuplet.note(at: 3), eighthNote)
            XCTAssertEqual(try tuplet.note(at: 4), eighthNote)
            XCTAssertEqual(try tuplet.note(at: 5), eighthNote)
        }
    }

    func testReplaceNotesFromTupletAndNonTupletWithNoteSameDuration() {
        assertNoErrorThrown {
            let triplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
            var tuplet = try Tuplet(5, .eighth, notes: [eighthNote, eighthNote, triplet, eighthNote])
            try tuplet.replaceNotes(in: 2...5, with: dottedQuarterNote)
            XCTAssertEqual(try tuplet.note(at: 0), eighthNote)
            XCTAssertEqual(try tuplet.note(at: 1), eighthNote)
            XCTAssertEqual(try tuplet.note(at: 2), dottedQuarterNote)
        }
    }

    func testReplaceNotesFromTupletAndNonTupletWithTupletSameDuration() {
        assertNoErrorThrown {
            let triplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
            var tuplet = try Tuplet(5, .eighth, notes: [eighthNote, eighthNote, triplet, eighthNote])
            let quadruplet = try Tuplet(4, .eighth, notes: [eighthChord, eighthRest, eighthNote, eighthChord])
            try tuplet.replaceNotes(in: 2...5, with: quadruplet)
            XCTAssertEqual(try tuplet.note(at: 0), eighthNote)
            XCTAssertEqual(try tuplet.note(at: 1), eighthNote)
            XCTAssertEqual(try tuplet.note(at: 2), eighthChord)
            XCTAssertEqual(try tuplet.note(at: 3), eighthRest)
            XCTAssertEqual(try tuplet.note(at: 4), eighthNote)
            XCTAssertEqual(try tuplet.note(at: 5), eighthChord)
        }
    }

    func testReplaceNotesFrom2FullTupletsWithNoteSameDuration() {
        assertNoErrorThrown {
            let triplet = try Tuplet(3, .sixteenth, notes: [sixteenthNote, sixteenthNote, sixteenthNote])
            var tuplet = try Tuplet(5, .sixteenth, notes: [sixteenthNote, triplet, triplet])
            try tuplet.replaceNotes(in: 1...6, with: quarterNote1)
            XCTAssertEqual(try tuplet.note(at: 0), sixteenthNote)
            XCTAssertEqual(try tuplet.note(at: 1), quarterNote1)
        }
    }

    func testReplaceNotesFrom2FullTupletsWithTupletSameDuration() {
        assertNoErrorThrown {
            let triplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
            var tuplet = try Tuplet(5, .eighth, notes: [eighthNote, triplet, triplet])
            let replacementTuplet = try Tuplet(5,
                                               .eighth,
                                               notes: [eighthChord, eighthNote, eighthRest, eighthNote, eighthChord])
            try tuplet.replaceNotes(in: 1...6, with: replacementTuplet)
            XCTAssertEqual(try tuplet.note(at: 0), eighthNote)
            XCTAssertEqual(try tuplet.note(at: 1), eighthChord)
            XCTAssertEqual(try tuplet.note(at: 2), eighthNote)
            XCTAssertEqual(try tuplet.note(at: 3), eighthRest)
            XCTAssertEqual(try tuplet.note(at: 4), eighthNote)
            XCTAssertEqual(try tuplet.note(at: 5), eighthChord)
        }
    }

    // MARK: - replaceNotes<T: NoteCollection>(in:with:[T])
    // replaceNotes<T: NoteCollection>(in:with:T) calls this method, so we will just do one sanity check for failure
    // and success. There is missing coverage of multi-nested tuplets, and that will be checked here too.

    // MARK: Failures

    func testReplaceNotesInTupletWithNotesTooLarge() {
        assertThrowsError(TupletError.replacementNotSameDuration) {
            var tuplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
            try tuplet.replaceNotes(in: 0...1, with: [eighthNote, eighthNote, eighthNote])
        }
    }

    // MARK: Successes

    func testReplaceNotesInMultiNestedCompoundTupletWithNotesOfSameDuration() {
        assertNoErrorThrown {
            let triplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
            let quintuplet = try Tuplet(5, .eighth, notes: [triplet, triplet, eighthNote])
            var tuplet = try Tuplet(9, .eighth, notes: [triplet, quintuplet, eighthNote, eighthNote, eighthNote])
            try tuplet.replaceNotes(in: 6...8, with: [eighthRest, eighthRest])
            XCTAssertEqual(try tuplet.note(at: 0), eighthNote)
            XCTAssertEqual(try tuplet.note(at: 1), eighthNote)
            XCTAssertEqual(try tuplet.note(at: 2), eighthNote)
            XCTAssertEqual(try tuplet.note(at: 3), eighthNote)
            XCTAssertEqual(try tuplet.note(at: 4), eighthNote)
            XCTAssertEqual(try tuplet.note(at: 5), eighthNote)

            XCTAssertEqual(try tuplet.note(at: 6), eighthRest)
            XCTAssertEqual(try tuplet.note(at: 7), eighthRest)

            XCTAssertEqual(try tuplet.note(at: 8), eighthNote)

            XCTAssertEqual(try tuplet.note(at: 9), eighthNote)
            XCTAssertEqual(try tuplet.note(at: 10), eighthNote)
            XCTAssertEqual(try tuplet.note(at: 11), eighthNote)
        }
    }

    func testReplaceNotesWithinMultiNestedCompoundTupletAndNotesWithNotesOfSameDuration() {
        assertNoErrorThrown {
            // Create same compound tuplet as above test
            let triplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
            let quintuplet = try Tuplet(5, .eighth, notes: [triplet, triplet, eighthNote])
            var tuplet = try Tuplet(9, .eighth, notes: [triplet, quintuplet, eighthNote, eighthNote, eighthNote])
            try tuplet.replaceNotes(in: 3...10, with: [quarterNote1, quarterNote1, eighthNote])
        }
    }

    // TODO: Equality tests

}
