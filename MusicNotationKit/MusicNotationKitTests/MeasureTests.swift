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
	
	func test_addNote() {
		XCTAssertEqual(measure.notes.count, 0)
		measure.addNote(Note(noteDuration: .Whole, tone: Tone(noteLetter: .C, octave: .Octave0)))
		measure.addNote(Note(noteDuration: .Quarter, tone: Tone(accidental: .Sharp, noteLetter: .D, octave: .Octave0)))
		measure.addNote(Note(noteDuration: .Whole))
		XCTAssertEqual(measure.notes.count, 3)
		print(measure)
	}
	
	func test_startTieAtIndex() {
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
		XCTAssertNil(note.tie)
		
		// Succeed if there is a next note
		measure.addNote(Note(noteDuration: .Eighth,
			tone: Tone(noteLetter: .C, octave: .Octave1)))
		do {
			try measure.startTieAtIndex(0)
			let note1 = measure.notes[0] as! Note
			let note2 = measure.notes[1] as! Note
			XCTAssertNotNil(note1.tie)
			XCTAssert(note1.tie == .Begin)
			XCTAssertNotNil(note2.tie)
			XCTAssert(note2.tie == .End)
		} catch {
			XCTFail(String(error))
		}
		
		// Succeed if the note is already the beginning of a tie
		do {
			try measure.startTieAtIndex(0)
		} catch {
			XCTFail(String(error))
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
		
		// Succeeds if it starts on the end of a tuplet and ends on another tuplet
		do {
			let note = Note(noteDuration: .Sixteenth,
				tone: Tone(noteLetter: .C, octave: .Octave1))
			let tuplet1 = try Tuplet(notes: [note, note, note])
			let tuplet2 = try Tuplet(notes: [note, note, note, note, note])
			measure.addTuplet(tuplet1)
			measure.addTuplet(tuplet2)
			try measure.startTieAtIndex(9)
			let note1 = noteFromMeasure(measure, noteIndex: 5, tupletIndex: 2)
			let note2 = noteFromMeasure(measure, noteIndex: 6, tupletIndex: 0)
			XCTAssert(note1.tie == .Begin)
			XCTAssert(note2.tie == .End)
		} catch {
			XCTFail()
		}
	}
	
	func test_removeTieAtIndex() {
		XCTAssertEqual(measure.notes.count, 0)
		measure.addNote(Note(noteDuration: .Eighth,
			tone: Tone(noteLetter: .C, octave: .Octave1)))
		measure.addNote(Note(noteDuration: .Eighth,
			tone: Tone(noteLetter: .C, octave: .Octave1)))
		measure.addNote(Note(noteDuration: .Eighth,
			tone: Tone(noteLetter: .C, octave: .Octave1)))
		measure.addNote(Note(noteDuration: .Eighth,
			tone: Tone(noteLetter: .C, octave: .Octave1)))
		
		// Fails if there is no note at the given index
		do {
			try measure.removeTieAtIndex(4)
			shouldFail()
		} catch MeasureError.NoteIndexOutOfRange {
		} catch {
			expected(MeasureError.NoteIndexOutOfRange, actual: error)
		}
		
		// Fails if it started on the end of the measure
		do {
			// Can't set the tie, because it will fail
			try measure.removeTieAtIndex(3)
			shouldFail()
		} catch MeasureError.NoNextNote {
		} catch {
			expected(MeasureError.NoNextNote, actual: error)
		}
		
		// Succeeds if there is no tie at the given index
		do {
			try measure.removeTieAtIndex(0)
			let firstNote = noteFromMeasure(measure, noteIndex: 0, tupletIndex: nil)
			let secondNote = noteFromMeasure(measure, noteIndex: 1, tupletIndex: nil)
			XCTAssertNil(firstNote.tie)
			XCTAssertNil(secondNote.tie)
		} catch MeasureError.NoTieBeginsAtIndex {
		} catch {
			expected(MeasureError.NoTieBeginsAtIndex, actual: error)
		}
		
		// Succeeds if index is beginning of a tie
		do {
			setTieAtIndex(0)
			try measure.removeTieAtIndex(0)
			let firstNote = noteFromMeasure(measure, noteIndex: 0, tupletIndex: nil)
			let secondNote = noteFromMeasure(measure, noteIndex: 1, tupletIndex: nil)
			XCTAssertNil(firstNote.tie)
			XCTAssertNil(secondNote.tie)
		} catch {
			XCTFail(String(error))
		}
		
		// Succeeds if index is end of a tie and beginning
		do {
			setTieAtIndex(0)
			setTieAtIndex(1)
			try measure.removeTieAtIndex(1)
			let firstNote = noteFromMeasure(measure, noteIndex: 1, tupletIndex: nil)
			let secondNote = noteFromMeasure(measure, noteIndex: 2, tupletIndex: nil)
			XCTAssert(firstNote.tie == .End)
			XCTAssertNil(secondNote.tie)
		} catch {
			XCTFail(String(error))
		}
		
		// Succeeds if tie starts in tuplet, and ends on a separate note
		let note = Note(noteDuration: .Sixteenth,
			tone: Tone(noteLetter: .C, octave: .Octave1))
		do {
			let tuplet = try Tuplet(notes: [note, note, note])
			measure.addTuplet(tuplet)
			measure.addNote(note)
		} catch {
			XCTFail()
		}
		do {
			setTieAtIndex(6)
			try measure.removeTieAtIndex(6)
			let firstNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 2)
			let secondNote = noteFromMeasure(measure, noteIndex: 5, tupletIndex: nil)
			XCTAssertNil(firstNote.tie)
			XCTAssertNil(secondNote.tie)
		} catch {
			XCTFail()
		}
		
		// Succeeds if tie starts and ends in the same tuplet
		do {
			setTieAtIndex(5)
			try measure.removeTieAtIndex(5)
			let firstNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 1)
			let secondNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 2)
			XCTAssertNil(firstNote.tie)
			XCTAssertNil(secondNote.tie)
		} catch {
			XCTFail()
		}
		
		// Succeeds if tie starts in a separate note and ends in a tuplet
		do {
			setTieAtIndex(4)
			try measure.removeTieAtIndex(4)
			let firstNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 0)
			let secondNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 1)
			XCTAssertNil(firstNote.tie)
			XCTAssertNil(secondNote.tie)
		} catch {
			XCTFail()
		}
		
		// Succeeds if tie starts in one tuplet and ends in another tuplet
		do {
			let tuplet1 = try Tuplet(notes: [note, note, note, note, note])
			let tuplet2 = try Tuplet(notes: [note, note, note])
			measure.addTuplet(tuplet1)
			measure.addTuplet(tuplet2)
			setTieAtIndex(11)
			try measure.removeTieAtIndex(11)
			let firstNote = noteFromMeasure(measure, noteIndex: 6, tupletIndex: 3)
			let secondNote = noteFromMeasure(measure, noteIndex: 7, tupletIndex: 0)
			XCTAssertNil(firstNote.tie)
			XCTAssertNil(secondNote.tie)
		} catch {
			XCTFail()
		}
	}
	
	func test_noteCollectionIndexFromNoteIndex() {
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
	
	private func setTieAtIndex(index: Int, functionName: String = #function, lineNum: Int = #line) {
		do {
			try measure.startTieAtIndex(index)
			let (noteIndex1, tupletIndex1) = try measure.noteCollectionIndexFromNoteIndex(index)
			let (noteIndex2, tupletIndex2) = try measure.noteCollectionIndexFromNoteIndex(index + 1)
			let firstNote = noteFromMeasure(measure, noteIndex: noteIndex1,
				tupletIndex: tupletIndex1)
			let secondNote = noteFromMeasure(measure, noteIndex: noteIndex2,
				tupletIndex: tupletIndex2)
			XCTAssert(firstNote.tie == .Begin || firstNote.tie == .BeginAndEnd,
				"\(functionName): \(lineNum)")
			XCTAssert(secondNote.tie == .End || secondNote.tie == .BeginAndEnd,
				"\(functionName): \(lineNum)")
		} catch {
			XCTFail("\(error) in \(functionName): \(lineNum)")
		}
	}
	
	private func noteFromMeasure(measure: Measure, noteIndex: Int, tupletIndex: Int?) -> Note {
		if let tupletIndex = tupletIndex {
			let tuplet = measure.notes[noteIndex] as! Tuplet
			return tuplet.notes[tupletIndex]
		} else {
			return measure.notes[noteIndex] as! Note
		}
	}
}
