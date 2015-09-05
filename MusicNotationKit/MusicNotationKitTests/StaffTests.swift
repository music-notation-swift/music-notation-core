//
//  StaffTests.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 9/5/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

import XCTest
@testable import MusicNotationKit

class StaffTests: XCTestCase {

	var staff: Staff!
	
    override func setUp() {
        super.setUp()
		staff = Staff(clef: .Treble, instrument: .Guitar6)
		let note = Note(noteDuration: .Sixteenth,
			tone: Tone(noteLetter: .C, octave: .Octave1))
		let tuplet = try! Tuplet(notes: [note, note, note])
		let measure1 = Measure(timeSignature: TimeSignature(
			topNumber: 4, bottomNumber: 4, tempo: 120),
			key: Key(noteLetter: .C),
			notes: [note, note, note, note, tuplet])
		let measure2 = Measure(timeSignature: TimeSignature(
			topNumber: 4, bottomNumber: 4, tempo: 120),
			key: Key(noteLetter: .C),
			notes: [tuplet, note, note])
		let measure3 = Measure(timeSignature: TimeSignature(
			topNumber: 4, bottomNumber: 4, tempo: 120),
			key: Key(noteLetter: .C),
			notes: [note, note, note, note, tuplet])
		let measure4 = Measure(timeSignature: TimeSignature(
			topNumber: 4, bottomNumber: 4, tempo: 120),
			key: Key(noteLetter: .C),
			notes: [note, note, note, note])
		let measure5 = Measure(timeSignature: TimeSignature(
			topNumber: 4, bottomNumber: 4, tempo: 120),
			key: Key(noteLetter: .C),
			notes: [tuplet, note, note, note, note])
		staff.appendMeasure(measure1)
		staff.appendMeasure(measure2)
		staff.appendMeasure(measure3)
		staff.appendMeasure(measure4)
		staff.appendMeasure(measure5)
    }

	func test_startTieFromNote() {
		// MARK: - Failures
		// MARK: Fail if noteIndex is invalid
		do {
			try staff.startTieFromNote(10, inMeasureAtIndex: 0)
			shouldFail()
		} catch StaffErrors.NoteIndexOutOfRange {
		} catch {
			expected(StaffErrors.NoteIndexOutOfRange, actual: error)
		}
		
		// MARK: Fail if measureIndex is invalid
		do {
			try staff.startTieFromNote(0, inMeasureAtIndex: 10)
			shouldFail()
		} catch StaffErrors.MeasureIndexOutOfRange {
		} catch {
			expected(StaffErrors.MeasureIndexOutOfRange, actual: error)
		}
		
		// MARK: Fail if no next note
		do {
			try staff.startTieFromNote(3, inMeasureAtIndex: 2)
			shouldFail()
		} catch StaffErrors.NoNextNoteToTie {
		} catch {
			expected(StaffErrors.NoNextNoteToTie, actual: error)
		}
		
		// MARK: Fail if it is the last note of a tuplet and there is no next note
		do {
			try staff.startTieFromNote(6, inMeasureAtIndex: 2)
			shouldFail()
		} catch StaffErrors.NoNextNoteToTie {
		} catch {
			expected(StaffErrors.NoNextNoteToTie, actual: error)
		}
		
		// MARK: - Successes
		// MARK: - Context: within a measure
		
		// MARK: Succeed if there is a next note
		do {
			let firstNoteIndex = 0
			let firstMeasureIndex = 0
			try staff.startTieFromNote(firstNoteIndex,
				inMeasureAtIndex: firstMeasureIndex)
			let measure = staff.notesHolders[firstMeasureIndex] as! Measure
			let firstNote = measure.notes[firstNoteIndex] as! Note
			let secondNote = measure.notes[firstNoteIndex + 1] as! Note
			XCTAssert(firstNote.tie == .Begin)
			XCTAssert(secondNote.tie == .End)
		} catch {
			XCTFail(String(error))
		}
		
		// MARK: - Context: crossing measures
		
		// MARK: Succeed if first is a note and second is a note
		do {
			try staff.startTieFromNote(4, inMeasureAtIndex: 1)
			let firstMeasure = staff.notesHolders[1] as! Measure
			let secondMeasure = staff.notesHolders[2] as! Measure
			let firstNote = firstMeasure.notes[2] as! Note
			let secondNote = secondMeasure.notes[0] as! Note
			XCTAssert(firstNote.tie == .Begin)
			XCTAssert(secondNote.tie == .End)
		} catch {
			XCTFail(String(error))
		}
		
		// MARK: Succeed if first is a note, second is note in tuplet
		do {
			try staff.startTieFromNote(3, inMeasureAtIndex: 3)
			let firstMeasure = staff.notesHolders[3] as! Measure
			let secondMeasure = staff.notesHolders[4] as! Measure
			let firstNote = firstMeasure.notes[3] as! Note
			let secondNote = (secondMeasure.notes[0] as! Tuplet).notes[0]
			XCTAssert(firstNote.tie == .Begin)
			XCTAssert(secondNote.tie == .End)
		} catch {
			XCTFail(String(error))
		}
		
		// MARK: Succeed if first is a note in a tuplet, second is a note
		do {
			try staff.startTieFromNote(6, inMeasureAtIndex: 2)
			let firstMeasure = staff.notesHolders[2] as! Measure
			let secondMeasure = staff.notesHolders[3] as! Measure
			let firstNote = (firstMeasure.notes[4] as! Tuplet).notes[2] 
			let secondNote = secondMeasure.notes[0] as! Note
			XCTAssert(firstNote.tie == .Begin)
			XCTAssert(secondNote.tie == .End)
		} catch {
			XCTFail(String(error))
		}
		
		// MARK: Succeed if first is a note in a tuplet, second is a note in a tuplet
		do {
			try staff.startTieFromNote(6, inMeasureAtIndex: 0)
			let firstMeasure = staff.notesHolders[0] as! Measure
			let secondMeasure = staff.notesHolders[1] as! Measure
			let firstNote = (firstMeasure.notes[4] as! Tuplet).notes[2]
			let secondNote = (secondMeasure.notes[0] as! Tuplet).notes[0]
			XCTAssert(firstNote.tie == .Begin)
			XCTAssert(secondNote.tie == .End)
		} catch {
			XCTFail(String(error))
		}
	}
	
	func test_removeTieFromNote() {
		
	}
}
