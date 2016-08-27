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

    }

    func testInitFailForOddCountNoBaseCount() {
        // count specified is something not in 2-9 range and no base count specified
    }

    func testInitFailForEmptyNotes() {

    }

    func testInitFailForNotesSameDurationNotEnough() {

    }

    func testInitFailForNotesSameDurationTooMany() {

    }

    func testInitFailForNotesShorterNotEnough() {

    }

    func testInitFailForShorterTooMany() {

    }

    func testInitFailForLongerNotEnough() {

    }

    func testInitFailForLongerTooMany() {

    }

    func testInitFailForSameDurationWithRestsNotEnough() {

    }

    func testInitFailForMixedDurationsNotEnough() {

    }

    func testInitFailForMixedDurationsTooMan() {

    }

    func testInitFailForCompoundTupletTooLarge() {

    }

    func testInitFailForCompoundTupletTooSmall() {

    }

    // MARK: Successes

	func testInitSuccessForAllCombinations() {
		do {
			// Test 2 - 7
			let _ = try Tuplet(notes: [quarterNote1, quarterNote2])
			let _ = try Tuplet(notes: [quarterNote1, quarterNote2, quarterNote3])
			let _ = try Tuplet(notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1])
			let _ = try Tuplet(notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2])
			let _ = try Tuplet(notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3])
			let _ = try Tuplet(notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3, quarterNote1])
			// Test with a chord
			let _ = try Tuplet(notes: [quarterNote1, quarterChord])
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
}
