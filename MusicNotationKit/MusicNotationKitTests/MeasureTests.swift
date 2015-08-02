//
//  MeasureTests.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 7/13/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

import XCTest
@testable import MusicNotationKit

class MeasureTests: XCTestCase {

	var measure: Measure = Measure(
		timeSignature: TimeSignature(topNumber: 4, bottomNumber: 4, tempo: 120),
		key: Key(noteLetter: .C))
	
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
		measure = Measure(
			timeSignature: TimeSignature(topNumber: 4, bottomNumber: 4, tempo: 120),
			key: Key(noteLetter: .C))
    }
	
	func testAddNote() {
		XCTAssertEqual(measure.notes.count, 0)
		measure.addNote(Note(noteDuration: .Whole))
		XCTAssertEqual(measure.notes.count, 1)
	}
	
	func testStartTieAtIndex() {
		XCTAssertEqual(measure.notes.count, 0)
		measure.addNote(Note(noteDuration: .Quarter,
			tone: Tone(noteLetter: .C, octave: .Octave1)))
		
		// Fail if no next note
		do {
			try measure.startTieAtIndex(0)
			shouldFail()
		} catch MeasureError.NoNextNoteToTie {
		} catch {
			expected(MeasureError.NoNextNoteToTie, actual: error)
		}
		
		// Succeed if there is a next note
		measure.addNote(Note(noteDuration: .Eighth,
			tone: Tone(noteLetter: .C, octave: .Octave1)))
		do {
			try measure.startTieAtIndex(0)
		} catch {
			XCTFail()
		}
	}
	
	func testNoteCollectionIndexFromNoteIndex() {
		// NoteIndex should be the same if there are no tuplets
		measure.addNote(Note(noteDuration: .Quarter))
		measure.addNote(Note(noteDuration: .Quarter))
		measure.addNote(Note(noteDuration: .Quarter))
		if let index = measure.noteCollectionIndexFromNoteIndex(2) {
			XCTAssertEqual(index.noteIndex, 2)
			XCTAssertNil(index.tupletIndex)
		} else {
			XCTFail()
		}
		
		// Re-initialize measure so that it's empty
		setUp()
		
		// NoteIndex should be the beginning of the tuplet if the index specified
		// is within the tuplet, and tupletIndex should be the index of the note
		// within the tuplet
		measure.addNote(Note(noteDuration: .Quarter))
		do {
			let note1 = Note(noteDuration: .Eighth,
				tone: Tone(noteLetter: .A, octave: .Octave1))
			let note2 = Note(noteDuration: .Eighth,
				tone: Tone(noteLetter: .B, octave: .Octave1))
			let note3 = Note(noteDuration: .Eighth,
				tone: Tone(noteLetter: .C, octave: .Octave1))
			try measure.addTuplet(Tuplet(notes: [note1, note2, note3]))
			if let index = measure.noteCollectionIndexFromNoteIndex(2) {
				XCTAssertEqual(index.noteIndex, 1)
				XCTAssertNotNil(index.tupletIndex)
				XCTAssertEqual(index.tupletIndex!, 1)
			}
			
			// Properly address regular note coming after a tuplet
			measure.addNote(Note(noteDuration: .Eighth))
			if let index = measure.noteCollectionIndexFromNoteIndex(4) {
				XCTAssertEqual(index.noteIndex, 4)
				XCTAssertNil(index.tupletIndex)
			}
		} catch {
			XCTFail()
		}
	}
}
