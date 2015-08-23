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
		let note = measure.notes[0] as! Note
		// TODO: XCTAssertNil was not working for some reason
		XCTAssert(note.tie == nil)
		
		// Succeed if there is a next note
		measure.addNote(Note(noteDuration: .Eighth,
			tone: Tone(noteLetter: .C, octave: .Octave1)))
		do {
			try measure.startTieAtIndex(0)
			let note1 = measure.notes[0] as! Note
			let note2 = measure.notes[1] as! Note
			// TODO: XCTAssertNotNil was not working for some reason
			XCTAssert(note1.tie != nil)
			XCTAssert(note1.tie == .Begin)
			XCTAssert(note2.tie != nil)
			XCTAssert(note2.tie == .End)
		} catch {
			XCTFail(String(error))
		}
		
		// Fail if the note is already the beginning of a tie
		do {
			try measure.startTieAtIndex(0)
			shouldFail()
		} catch MeasureError.NoteAlreadyTied {
		} catch {
			expected(MeasureError.NoteAlreadyTied, actual: error)
		}
		
		// Succeed if there is a next note and it's in a tuplet
		measure.addNote(Note(noteDuration: .Eighth,
			tone: Tone(noteLetter: .C, octave: .Octave1)))
		let notes = [
			Note(noteDuration: .Eighth, tone: Tone(noteLetter: .A, octave: .Octave1)),
			Note(noteDuration: .Eighth, tone: Tone(noteLetter: .A, octave: .Octave1)),
			Note(noteDuration: .Eighth, tone: Tone(noteLetter: .A, octave: .Octave1))
		]
		do {
			let tuplet = try Tuplet(notes: notes)
			measure.addTuplet(tuplet)
			try measure.startTieAtIndex(2)
			let note1 = measure.notes[2] as! Note
			let tuplet2 = measure.notes[3] as! Tuplet
			XCTAssert(note1.tie == .Begin)
			XCTAssert(tuplet2.notes[0].tie == .End)
		} catch {
			XCTFail(String(error))
		}
		
		// Fail if it is the last note of a tuplet and there is no next note
		do {
			try measure.startTieAtIndex(5)
			shouldFail()
		} catch MeasureError.NoNextNoteToTie {
		} catch {
			expected(MeasureError.NoNextNoteToTie, actual: error)
		}
		
		// Succeed if starting a tie on the note of an ending tie
		do {
			try measure.startTieAtIndex(3)
			let tuplet = measure.notes[3] as! Tuplet
			XCTAssert(tuplet.notes[0].tie == .BeginAndEnd)
			XCTAssert(tuplet.notes[1].tie == .End)
		} catch {
			XCTFail(String(error))
		}
		
		// Succeed if it starts on the end of a tuplet and there is a next note
		measure.addNote(Note(noteDuration: .Sixteenth,
			tone: Tone(noteLetter: .A, octave: .Octave1)))
		do {
			try measure.startTieAtIndex(5)
			let tuplet = measure.notes[3] as! Tuplet
			let note1 = measure.notes[4] as! Note
			XCTAssert(tuplet.notes[2].tie == .Begin)
			XCTAssert(note1.tie == .End)
		} catch {
			XCTFail(String(error))
		}
	}
	
	func testRemoveTieAtIndex() {
		XCTFail("Not implemented")
	}
	
	func testNoteCollectionIndexFromNoteIndex() {
		// NoteIndex should be the same if there are no tuplets
		measure.addNote(Note(noteDuration: .Quarter))
		measure.addNote(Note(noteDuration: .Quarter))
		measure.addNote(Note(noteDuration: .Quarter))
		do {
			let index = try measure.noteCollectionIndexFromNoteIndex(2)
			XCTAssertEqual(index.noteIndex, 2)
			XCTAssertNil(index.tupletIndex)
		} catch {
			XCTFail(String(error))
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
			let index = try measure.noteCollectionIndexFromNoteIndex(2)
			XCTAssertEqual(index.noteIndex, 1)
			XCTAssertNotNil(index.tupletIndex)
			XCTAssertEqual(index.tupletIndex!, 1)
			
			// Properly address regular note coming after a tuplet
			measure.addNote(Note(noteDuration: .Eighth))
			let index2 = try measure.noteCollectionIndexFromNoteIndex(4)
			XCTAssertEqual(index2.noteIndex, 2)
			XCTAssertNil(index2.tupletIndex)
		} catch {
			XCTFail(String(error))
		}
	}
}
