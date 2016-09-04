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
        do {
            let _ = try Tuplet(1, .quarter, notes: [quarterNote1])
            shouldFail()
        } catch TupletError.countMustBeLargerThan1 {
        } catch {
            expected(TupletError.countMustBeLargerThan1, actual: error)
        }
    }

    func testInitFailForOddCountNoBaseCount() {
        // count specified is something not in 2-9 range and no base count specified
        do {
            let _ = try Tuplet(
                10,
                .quarter,
                notes: [
                    quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2,
                    quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2
                ])
            shouldFail()
        } catch TupletError.countHasNoStandardRatio {
        } catch {
            expected(TupletError.countHasNoStandardRatio, actual: error)
        }
    }

    func testInitFailForEmptyNotes() {
        // standard ratio
        do {
            let _ = try Tuplet(3, .eighth, notes: [])
            shouldFail()
        } catch TupletError.notesDoNotFillTuplet {
        } catch {
            expected(TupletError.notesDoNotFillTuplet, actual: error)
        }

        // non-standard ratio
        do {
            let _ = try Tuplet(11, .eighth, inSpaceOf: 9, notes: [])
            shouldFail()
        } catch TupletError.notesDoNotFillTuplet {
        } catch {
            expected(TupletError.notesDoNotFillTuplet, actual: error)
        }
    }

    func testInitFailForNotesSameDurationNotEnough() {
        // standard ratio
        do {
            let _ = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2])
            shouldFail()
        } catch TupletError.notesDoNotFillTuplet {
        } catch {
            expected(TupletError.notesDoNotFillTuplet, actual: error)
        }

        // non-standard ratio
        do {
            let _ = try Tuplet(11, .quarter, inSpaceOf: 9, notes: [quarterNote1, quarterNote2, quarterNote3])
            shouldFail()
        } catch TupletError.notesDoNotFillTuplet {
        } catch {
            expected(TupletError.notesDoNotFillTuplet, actual: error)
        }
    }

    func testInitFailForNotesSameDurationTooMany() {
        // standard ratio
        do {
            let _ = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1])
            shouldFail()
        } catch TupletError.notesOverfillTuplet {
        } catch {
            expected(TupletError.notesOverfillTuplet, actual: error)
        }

        // non-standard ratio
        do {
            let _ = try Tuplet(
                5,
                .quarter,
                inSpaceOf: 2,
                notes: [
                    quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3, quarterNote1
                ])
            shouldFail()
        } catch TupletError.notesOverfillTuplet {
        } catch {
            expected(TupletError.notesOverfillTuplet, actual: error)
        }
    }

    func testInitFailForNotesShorterNotEnough() {
        // standard ratio
        do {
            let _ = try Tuplet(4, .quarter, notes: [eighthNote, eighthNote, quarterNote1])
            shouldFail()
        } catch TupletError.notesDoNotFillTuplet {
        } catch {
            expected(TupletError.notesDoNotFillTuplet, actual: error)
        }

        // non-standard ratio
        do {
            let _ = try Tuplet(
                5,
                .quarter,
                inSpaceOf: 3,
                notes: [
                    eighthNote, eighthNote,
                    eighthNote, eighthNote,
                    quarterNote3
                ])
            shouldFail()
        } catch TupletError.notesDoNotFillTuplet {
        } catch {
            expected(TupletError.notesDoNotFillTuplet, actual: error)
        }
    }

    func testInitFailForShorterTooMany() {
        // standard ratio
        do {
            let _ = try Tuplet(
                4,
                .quarter,
                notes: [
                    eighthNote, eighthNote, eighthNote, eighthNote, quarterNote1, quarterNote2, quarterNote3
                ])
            shouldFail()
        } catch TupletError.notesOverfillTuplet {
        } catch {
            expected(TupletError.notesOverfillTuplet, actual: error)
        }

        // non-standard ratio
        do {
            let _ = try Tuplet(
                5,
                .quarter,
                inSpaceOf: 2,
                notes: [
                    quarterNote1, quarterNote2, quarterNote3,
                    eighthNote, eighthNote, quarterNote1, eighthNote
                ])
            shouldFail()
        } catch TupletError.notesOverfillTuplet {
        } catch {
            expected(TupletError.notesOverfillTuplet, actual: error)
        }
    }

    func testInitFailForLongerNotEnough() {
        // standard ratio
        do {
            let _ = try Tuplet(4, .eighth, notes: [quarterNote1, eighthNote])
            shouldFail()
        } catch TupletError.notesDoNotFillTuplet {
        } catch {
            expected(TupletError.notesDoNotFillTuplet, actual: error)
        }

        // non-standard ratio
        do {
            let _ = try Tuplet(11, .eighth, inSpaceOf: 9, notes: [eighthNote, eighthNote, quarterNote1])
            shouldFail()
        } catch TupletError.notesDoNotFillTuplet {
        } catch {
            expected(TupletError.notesDoNotFillTuplet, actual: error)
        }
    }

    func testInitFailForLongerTooMany() {
        // standard ratio
        do {
            let _ = try Tuplet(
                5,
                .eighth,
                notes: [
                    eighthNote, quarterNote1, eighthNote, quarterNote2
                ])
            shouldFail()
        } catch TupletError.notesOverfillTuplet {
        } catch {
            expected(TupletError.notesOverfillTuplet, actual: error)
        }

        // non-standard ratio
        do {
            let _ = try Tuplet(
                5,
                .eighth,
                inSpaceOf: 2,
                notes: [
                    eighthNote, quarterNote1, eighthNote, quarterNote2
                ])
            shouldFail()
        } catch TupletError.notesOverfillTuplet {
        } catch {
            expected(TupletError.notesOverfillTuplet, actual: error)
        }
    }

    func testInitFailForSameDurationWithRestsNotEnough() {
        // standard ratio
        do {
            let _ = try Tuplet(3, .quarter, notes: [quarterNote1, quarterRest])
            shouldFail()
        } catch TupletError.notesDoNotFillTuplet {
        } catch {
            expected(TupletError.notesDoNotFillTuplet, actual: error)
        }

        // non-standard ratio
        do {
            let _ = try Tuplet(11, .quarter, inSpaceOf: 9, notes: [quarterNote1, quarterRest, quarterNote3])
            shouldFail()
        } catch TupletError.notesDoNotFillTuplet {
        } catch {
            expected(TupletError.notesDoNotFillTuplet, actual: error)
        }
    }

    func testInitFailForCompoundTupletTooLarge() {
        do {
            // This is worth 4 quarter notes
            let quintuplet = try? Tuplet(
                5,
                .quarterNote,
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
                    quintuplet
                ])
        } catch TupletError.notesOverfillTuplet {
        } catch {
            expected(TupletError.notesOverfillTuplet, actual: error)
        }
    }

    func testInitFailForCompoundTupletTooSmall() {
        do {
            let triplet = try? Tuplet(
                3,
                .quarterNote,
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
        } catch TupletError.notesDoNotFillTuplet {
        } catch {
            expected(TupletError.notesDoNotFillTuplet, actual: error)
        }
    }

    // MARK: Successes

	func testInitSuccessForAllStandardCombinations() {
		do {
			// Test 2 - 9
			let _ = try Tuplet(
                notes: [
                    quarterNote1, quarterNote2
                ])
			let _ = try Tuplet(
                notes: [
                    quarterNote1, quarterNote2, quarterNote3
                ])
            let _ = try Tuplet(
                notes: [
                    quarterNote1, quarterNote2, quarterNote3, quarterNote1
                ])
            let _ = try Tuplet(
                notes: [
                    quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2
                ])
            let _ = try Tuplet(
                notes: [
                    quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3
                ])
            let _ = try Tuplet(
                notes: [
                    quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3, quarterNote1
                ])
            let _ = try Tuplet(
                notes: [
                    quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3, quarterNote1,
                    quarterNote2
                ])
            let _ = try Tuplet(
                notes: [
                    quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3, quarterNote1,
                    quarterNote2, quarterNote3
                ])
			// Test with a chord
			let _ = try Tuplet(
                notes: [
                    quarterNote1, quarterChord
                ])
		} catch {
			XCTFail(String(describing: error))
		}
	}

    func testInitSuccessForStandardMixedDurations() {
        do {
            let _ = try Tuplet(
                5,
                .quarter,
                notes: [
                    quarterNote1, eighthNote, eighthNote, quarterNote2, quarterNote3, eighthNote, eighthNote
                ])
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testInitSuccessForStandardDottedBase() {
        do {
            let baseDuration = try? NoteDuration(value: .quarter, dotCount: 1)
            XCTAssertNotNil(baseDuration)
            let _ = try Tuplet(
                3,
                baseDuration!,
                notes: [
                    dottedQuarterNote, dottedQuarterNote, dottedQuarterNote
                ])
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testInitSuccessForStandardDottedBaseMixedDuration() {
        do {
            let baseDuration = try? NoteDuration(value: .quarter, dotCount: 1)
            XCTAssertNotNil(baseDuration)
            let _ = try Tuplet(
                3,
                baseDuration!,
                notes: [
                    dottedQuarterNote, quarterNote1, eighthNote, dottedQuarterNote
                ])
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testInitSuccessForStandardCompound() {
        do {
            let triplet = try? Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
            XCTAssertNotNil(triplet)
            let _ = try Tuplet(
                5,
                .eighth,
                notes: [
                    triplet!, eighthNote, eighthNote, eighthNote
                ]
            )
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testInitSuccessForStandardWithRests() {
        do {
            let _ = try Tuplet(3, .quarter, notes: [quarterNote1, quarterRest, quarterNote3])
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testInitSuccessForNonStandardSameDuration() {
        do {
            let _ = try Tuplet(
                7,
                .eighth,
                inSpaceOf: 6,
                notes: [
                    eighthNote, eighthNote, eighthNote, eighthNote,
                    eighthNote, eighthNote, eighthNote
                ])
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testInitSuccessForNonStandardDottedBase() {
        do {
            let _ = try Tuplet(
                4,
                dottedQuarterNote,
                inSpaceOf: 2,
                notes: [
                    dottedQuarterNote, dottedQuarterNote, dottedQuarterNote, dottedQuarterNote,
                ])
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testInitSuccessForNonStandardCompound() {
        do {
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
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testInitSuccessForNonStandardNestedCompound() {
        do {
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
                    quintuplet!, eighthNote, eighthNote, eighthNote,
                    eighthNote, eighthNote, eighthNote, eighthNote
                ])
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testInitSuccessForNonStandardWithRests() {
        do {
            let _ = try Tuplet(
                7,
                .quarter,
                inSpaceOf: 6,
                notes: [
                    quarterNote1, quarterNote2, quarterRest, quarterNote3,
                    quarterRest, quarterRest, quarterNote1
                ])
        } catch {
            XCTFail(String(describing: error))
        }
    }

    // MARK: - replaceNote(at:with:Note)
    // MARK: Failures

    func testReplaceNoteWithNoteTooLong() {

    }

    func testReplaceNoteWithNoteTooShort() {

    }

    func testReplaceNoteInTupletWithNoteTooShort() {

    }

    func testReplaceNoteInTupletWithNoteTooLong() {

    }

    // MARK: Successes

    func testReplaceNoteWithRestOfSameDuration() {

    }

    func testReplaceNoteInTupletWithRestOfSameDuration() {

    }

    func testReplaceNoteWithNoteOfSameDuration() {

    }

    func testReplaceNoteWithNotesOfShorterDuration() {

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
