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
		let timeSignature = TimeSignature(topNumber: 4, bottomNumber: 4, tempo: 120)
		let key = Key(noteLetter: .C)
		let note = Note(noteDuration: .Sixteenth,
			tone: Tone(noteLetter: .C, octave: .Octave1))
		let tuplet = try! Tuplet(notes: [note, note, note])
		let measure1 = Measure(
			timeSignature: timeSignature,
			key: key,
			notes: [note, note, note, note, tuplet]
		)
		let measure2 = Measure(
			timeSignature: timeSignature,
			key: key,
			notes: [tuplet, note, note]
		)
		let measure3 = Measure(
			timeSignature: timeSignature,
			key: key,
			notes: [note, note, note, note, tuplet]
		)
		let measure4 = Measure(
			timeSignature: timeSignature,
			key: key,
			notes: [note, note, note, note]
		)
		let measure5 = Measure(
			timeSignature: timeSignature,
			key: key,
			notes: [tuplet, note, note, note, note]
		)
		let measure6 = Measure(
			timeSignature: timeSignature,
			key: key,
			notes: [tuplet, tuplet, note, note]
		)
		let repeat1 = try! MeasureRepeat(measures: [measure4])
		let repeat2 = try! MeasureRepeat(measures: [measure4, measure4], repeatCount: 2)
		staff.appendMeasure(measure1)
		staff.appendMeasure(measure2)
		staff.appendMeasure(measure3)
		staff.appendMeasure(measure4)
		staff.appendMeasure(measure5)
		staff.appendRepeat(repeat1) // index = 5
		staff.appendRepeat(repeat2) // index = 7
		staff.appendMeasure(measure6) // index = 13
    }

	// MARK: - startTieFromNoteAtIndex(_:, inMeasureAtIndex:)
	// MARK: Failures
	
	func testStartTieFailIfNoteIndexInvalid() {
		do {
			try staff.startTieFromNoteAtIndex(10, inMeasureAtIndex: 0)
			shouldFail()
		} catch StaffErrors.NoteIndexOutOfRange {
		} catch {
			expected(StaffErrors.NoteIndexOutOfRange, actual: error)
		}
	}
	
	func testStartTieFailIfMeasureIndexInvalid() {
		do {
			try staff.startTieFromNoteAtIndex(0, inMeasureAtIndex: 10)
			shouldFail()
		} catch StaffErrors.MeasureIndexOutOfRange {
		} catch {
			expected(StaffErrors.MeasureIndexOutOfRange, actual: error)
		}
	}
	
	func testStartTieFailIfNoNextNote() {
		do {
			try staff.startTieFromNoteAtIndex(3, inMeasureAtIndex: 2)
			shouldFail()
		} catch StaffErrors.NoNextNoteToTie {
		} catch {
			expected(StaffErrors.NoNextNoteToTie, actual: error)
		}
	}
	
	func testStartTieFailIfLastNoteOfTupletAndNoNextNote() {
		do {
			try staff.startTieFromNoteAtIndex(6, inMeasureAtIndex: 2)
			shouldFail()
		} catch StaffErrors.NoNextNoteToTie {
		} catch {
			expected(StaffErrors.NoNextNoteToTie, actual: error)
		}
	}
	
	func testStartTieFailIfLastNoteOfSingleMeasureRepeat() {
		// Reason: can't finish in the next measure
		do {
			try staff.startTieFromNoteAtIndex(3, inMeasureAtIndex: 5)
			shouldFail()
		} catch StaffErrors.NoNextNoteToTie {
		} catch {
			expected(StaffErrors.NoNextNoteToTie, actual: error)
		}
	}
	
	func testStartTieFailIfLastNoteInLastMeasureOfMultiMeasureRepeat() {
		do {
			try staff.startTieFromNoteAtIndex(3, inMeasureAtIndex: 6)
			shouldFail()
		} catch StaffErrors.NoNextNoteToTie {
		} catch {
			expected(StaffErrors.NoNextNoteToTie, actual: error)
		}
	}
	
	func testStartTieFailIfNotesWithinRepeatAfterTheFirstCount() {
		do {
			try staff.startTieFromNoteAtIndex(0, inMeasureAtIndex: 8)
			shouldFail()
		} catch StaffErrors.RepeatedMeasureCannotHaveTie {
		} catch {
			expected(StaffErrors.RepeatedMeasureCannotHaveTie, actual: error)
		}
	}
	
	// MARK: Successes
	
	func testStartTieWithinMeasureIfHasNextNote() {
		do {
			let firstNoteIndex = 0
			let firstMeasureIndex = 0
			try staff.startTieFromNoteAtIndex(firstNoteIndex, inMeasureAtIndex: firstMeasureIndex)
			let measure = staff.notesHolders[firstMeasureIndex] as! Measure
			let firstNote = measure.notes[firstNoteIndex] as! Note
			let secondNote = measure.notes[firstNoteIndex + 1] as! Note
			XCTAssert(firstNote.tie == .Begin)
			XCTAssert(secondNote.tie == .End)
		} catch {
			XCTFail(String(error))
		}
	}
	
	func testStartTieWithinMeasureIfAlreadyEndOfTie() {
		do {
			let firstNoteIndex = 0
			let firstMeasureIndex = 0
			try staff.startTieFromNoteAtIndex(firstNoteIndex, inMeasureAtIndex: firstMeasureIndex)
			try staff.startTieFromNoteAtIndex(firstNoteIndex + 1, inMeasureAtIndex: firstMeasureIndex)
			let measure = staff.notesHolders[firstMeasureIndex] as! Measure
			let firstNote = measure.notes[firstNoteIndex] as! Note
			let secondNote = measure.notes[firstNoteIndex + 1] as! Note
			let thirdNote = measure.notes[firstNoteIndex + 2] as! Note
			XCTAssert(firstNote.tie == .Begin)
			XCTAssert(secondNote.tie == .BeginAndEnd)
			XCTAssert(thirdNote.tie == .End)
		} catch {
			XCTFail(String(error))
		}
	}
	
	func testStartTieWithinMeasureTupletToTuplet() {
		do {
			let firstNoteIndex = 2
			let firstMeasureIndex = 13
			try staff.startTieFromNoteAtIndex(firstNoteIndex, inMeasureAtIndex: firstMeasureIndex)
			let measure = staff.notesHolders[firstMeasureIndex] as! Measure
			let firstNote = (measure.notes[0] as! Tuplet).notes[2]
			let secondNote = (measure.notes[1] as! Tuplet).notes[0]
			XCTAssert(firstNote.tie == .Begin)
			XCTAssert(secondNote.tie == .End)
		} catch {
			XCTFail(String(error))
		}
	}
	
	func testStartTieAcrossMeasuresNoteToNote() {
		do {
			let firstNoteIndex = 4
			let firstMeasureIndex = 1
			try staff.startTieFromNoteAtIndex(firstNoteIndex, inMeasureAtIndex: firstMeasureIndex)
			let firstMeasure = staff.notesHolders[firstMeasureIndex] as! Measure
			let secondMeasure = staff.notesHolders[firstMeasureIndex + 1] as! Measure
			let firstNote = firstMeasure.notes[2] as! Note
			let secondNote = secondMeasure.notes[0] as! Note
			XCTAssert(firstNote.tie == .Begin)
			XCTAssert(secondNote.tie == .End)
		} catch {
			XCTFail(String(error))
		}
	}
	
	func testStartTieAcrossMeasuresNoteToTuplet() {
		do {
			let firstNoteIndex = 3
			let firstMeasureIndex = 3
			try staff.startTieFromNoteAtIndex(firstNoteIndex, inMeasureAtIndex: firstMeasureIndex)
			let firstMeasure = staff.notesHolders[firstMeasureIndex] as! Measure
			let secondMeasure = staff.notesHolders[firstMeasureIndex + 1] as! Measure
			let firstNote = firstMeasure.notes[3] as! Note
			let secondNote = (secondMeasure.notes[0] as! Tuplet).notes[0]
			XCTAssert(firstNote.tie == .Begin)
			XCTAssert(secondNote.tie == .End)
		} catch {
			XCTFail(String(error))
		}
	}
	
	func testStartTieAcrossMeasuresTupletToNote() {
		do {
			let firstNoteIndex = 6
			let firstMeasureIndex = 2
			try staff.startTieFromNoteAtIndex(firstNoteIndex, inMeasureAtIndex: firstMeasureIndex)
			let firstMeasure = staff.notesHolders[firstMeasureIndex] as! Measure
			let secondMeasure = staff.notesHolders[firstMeasureIndex + 1] as! Measure
			let firstNote = (firstMeasure.notes[4] as! Tuplet).notes[2]
			let secondNote = secondMeasure.notes[0] as! Note
			XCTAssert(firstNote.tie == .Begin)
			XCTAssert(secondNote.tie == .End)
		} catch {
			XCTFail(String(error))
		}
	}
	
	func testStartTieAcrossMeasuresTupletToTuplet() {
		do {
			let firstNoteIndex = 6
			let firstMeasureIndex = 0
			try staff.startTieFromNoteAtIndex(firstNoteIndex, inMeasureAtIndex: firstMeasureIndex)
			let firstMeasure = staff.notesHolders[firstMeasureIndex] as! Measure
			let secondMeasure = staff.notesHolders[firstMeasureIndex + 1] as! Measure
			let firstNote = (firstMeasure.notes[4] as! Tuplet).notes[2]
			let secondNote = (secondMeasure.notes[0] as! Tuplet).notes[0]
			XCTAssert(firstNote.tie == .Begin)
			XCTAssert(secondNote.tie == .End)
		} catch {
			XCTFail(String(error))
		}
	}
	
	func testStartTieBothNotesWithinSingleMeasureRepeat() {
		do {
			let firstNoteIndex = 0
			let firstMeasureIndex = 5
			try staff.startTieFromNoteAtIndex(firstNoteIndex, inMeasureAtIndex: firstMeasureIndex)
			let firstMeasure = (staff.notesHolders[firstMeasureIndex] as! MeasureRepeat).measures[0]
			let firstNote = firstMeasure.notes[firstNoteIndex] as! Note
			let secondNote = firstMeasure.notes[firstNoteIndex + 1] as! Note
			XCTAssert(firstNote.tie == .Begin)
			XCTAssert(secondNote.tie == .End)
		} catch {
			XCTFail(String(error))
		}
	}
	
	func testStartTieBothNotesWithinMultiMeasureRepeat() {
		do {
			let firstNoteIndex = 0
			let firstMeasureIndex = 7
			try staff.startTieFromNoteAtIndex(firstNoteIndex, inMeasureAtIndex: firstMeasureIndex)
			let firstMeasure = (staff.notesHolders[firstMeasureIndex] as! MeasureRepeat).measures[0]
			let firstNote = firstMeasure.notes[firstNoteIndex] as! Note
			let secondNote = firstMeasure.notes[firstNoteIndex + 1] as! Note
			XCTAssert(firstNote.tie == .Begin)
			XCTAssert(secondNote.tie == .End)
		} catch {
			XCTFail(String(error))
		}
	}
	
	func testStartTieNotesFromContiguousMeasuresWithinRepeat() {
		do {
			let firstNoteIndex = 3
			let firstMeasureIndex = 7
			try staff.startTieFromNoteAtIndex(firstNoteIndex, inMeasureAtIndex: firstMeasureIndex)
			let measureRepeat = staff.notesHolders[firstMeasureIndex] as! MeasureRepeat
			let firstMeasure = measureRepeat.measures[0]
			let secondMeasure = measureRepeat.measures[1]
			let firstNote = firstMeasure.notes[firstNoteIndex] as! Note
			let secondNote = secondMeasure.notes[0] as! Note
			XCTAssert(firstNote.tie == .Begin)
			XCTAssert(secondNote.tie == .End)
		} catch {
			XCTFail(String(error))
		}
	}
	
	// MARK: - removeTieFromNoteAtIndex(_:, inMeasureAtIndex:)
	// MARK: Failures
	
	func testRemoveTieFailIfNoteIndexInvalid() {
		do {
			try staff.removeTieFromNoteAtIndex(10, inMeasureAtIndex: 0)
			shouldFail()
		} catch StaffErrors.NoteIndexOutOfRange {
		} catch {
			expected(StaffErrors.NoteIndexOutOfRange, actual: error)
		}
	}
	
	func testRemoveTieFailIfMeasureIndexInvalid() {
		do {
			try staff.removeTieFromNoteAtIndex(0, inMeasureAtIndex: 10)
			shouldFail()
		} catch StaffErrors.MeasureIndexOutOfRange {
		} catch {
			expected(StaffErrors.MeasureIndexOutOfRange, actual: error)
		}
	}
	
	func testRemoveTieFailIfNotTied() {
		do {
			try staff.removeTieFromNoteAtIndex(0, inMeasureAtIndex: 0)
			shouldFail()
		} catch StaffErrors.NotBeginningOfTie {
		} catch {
			expected(StaffErrors.NotBeginningOfTie, actual: error)
		}
	}
	
	func testRemoveTieFailIfNotBeginningOfTie() {
		do {
			try staff.startTieFromNoteAtIndex(0, inMeasureAtIndex: 0)
			try staff.removeTieFromNoteAtIndex(1, inMeasureAtIndex: 0)
			shouldFail()
		} catch StaffErrors.NotBeginningOfTie {
		} catch {
			expected(StaffErrors.NotBeginningOfTie, actual: error)
		}
	}
	
	// MARK: Successes
	
	func testRemoveTieWithinMeasureNoteToNote() {
		do {
			let firstNoteIndex = 0
			let firstMeasureIndex = 0
			try staff.startTieFromNoteAtIndex(firstNoteIndex, inMeasureAtIndex: firstMeasureIndex)
			try staff.removeTieFromNoteAtIndex(firstNoteIndex, inMeasureAtIndex: firstMeasureIndex)
			let measure = staff.notesHolders[firstMeasureIndex] as! Measure
			let firstNote = measure.notes[firstNoteIndex] as! Note
			let secondNote = measure.notes[firstNoteIndex + 1] as! Note
			XCTAssertNil(firstNote.tie)
			XCTAssertNil(secondNote.tie)
		} catch {
			XCTFail(String(error))
		}
	}
	
	func testRemoveTieWithinMeasureWithinTuplet() {
		do {
			let firstNoteIndex = 4
			let firstMeasureIndex = 0
			try staff.startTieFromNoteAtIndex(firstNoteIndex, inMeasureAtIndex: firstMeasureIndex)
			try staff.removeTieFromNoteAtIndex(firstNoteIndex, inMeasureAtIndex: firstMeasureIndex)
			let measure = staff.notesHolders[firstMeasureIndex] as! Measure
			let firstNote = measure.notes[firstNoteIndex] as! Note
			let secondNote = measure.notes[firstNoteIndex + 1] as! Note
			XCTAssertNil(firstNote.tie)
			XCTAssertNil(secondNote.tie)
		} catch {
			XCTFail(String(error))
		}
	}
	
	func testRemoveTieWithinMeasureFromTupletToNote() {
		do {
			let firstNoteIndex = 2
			let firstMeasureIndex = 1
			try staff.startTieFromNoteAtIndex(firstNoteIndex, inMeasureAtIndex: firstMeasureIndex)
			try staff.removeTieFromNoteAtIndex(firstNoteIndex, inMeasureAtIndex: firstMeasureIndex)
			let measure = staff.notesHolders[firstMeasureIndex] as! Measure
			let firstNote = measure.notes[firstNoteIndex] as! Note
			let secondNote = measure.notes[firstNoteIndex + 1] as! Note
			XCTAssertNil(firstNote.tie)
			XCTAssertNil(secondNote.tie)
		} catch {
			XCTFail(String(error))
		}
	}

	func testRemoveTieWithinMeasureFromTupletToNewTuplet() {
		do {
			let firstNoteIndex = 2
			let firstMeasureIndex = 11
			try staff.startTieFromNoteAtIndex(firstNoteIndex, inMeasureAtIndex: firstMeasureIndex)
			try staff.removeTieFromNoteAtIndex(firstNoteIndex, inMeasureAtIndex: firstMeasureIndex)
			let measure = staff.notesHolders[firstMeasureIndex] as! Measure
			let firstNote = measure.notes[firstNoteIndex] as! Note
			let secondNote = measure.notes[firstNoteIndex + 1] as! Note
			XCTAssertNil(firstNote.tie)
			XCTAssertNil(secondNote.tie)
		} catch {
			XCTFail(String(error))
		}
	}

	func testRemoveTieAcrossMeasuresFromTupletToNote() {
		do {
			let firstNoteIndex = 6
			let firstMeasureIndex = 2
			try staff.startTieFromNoteAtIndex(firstNoteIndex, inMeasureAtIndex: firstMeasureIndex)
			try staff.removeTieFromNoteAtIndex(firstNoteIndex, inMeasureAtIndex: firstMeasureIndex)
			let measure1 = staff.notesHolders[firstMeasureIndex] as! Measure
			let measure2 = staff.notesHolders[firstMeasureIndex + 1] as! Measure
			let firstNote = measure1.notes[firstNoteIndex] as! Note
			let secondNote = measure2.notes[0] as! Note
			XCTAssertNil(firstNote.tie)
			XCTAssertNil(secondNote.tie)
		} catch {
			XCTFail(String(error))
		}
	}

	func testRemoveTieAcrosssMeasuresFromTupletToNewTuplet() {
		do {
			let firstNoteIndex = 6
			let firstMeasureIndex = 0
			try staff.startTieFromNoteAtIndex(firstNoteIndex, inMeasureAtIndex: firstMeasureIndex)
			try staff.removeTieFromNoteAtIndex(firstNoteIndex, inMeasureAtIndex: firstMeasureIndex + 1)
			let measure1 = staff.notesHolders[firstMeasureIndex] as! Measure
			let measure2 = staff.notesHolders[firstMeasureIndex + 1] as! Measure
			let firstNote = measure1.notes[firstNoteIndex] as! Note
			let secondNote = measure2.notes[0] as! Note
			XCTAssertNil(firstNote.tie)
			XCTAssertNil(secondNote.tie)
		} catch {
			XCTFail(String(error))
		}
	}
	
	func testremoveTieFromNoteAtIndexThatIsBeginAndEnd() {
		do {
			let firstNoteIndex = 0
			let firstMeasureIndex = 0
			try staff.startTieFromNoteAtIndex(firstNoteIndex, inMeasureAtIndex: firstMeasureIndex)
			try staff.startTieFromNoteAtIndex(firstNoteIndex + 1, inMeasureAtIndex: firstMeasureIndex)
			try staff.removeTieFromNoteAtIndex(firstNoteIndex + 1, inMeasureAtIndex: firstMeasureIndex)
			let measure = staff.notesHolders[firstMeasureIndex] as! Measure
			let firstNote = measure.notes[firstNoteIndex] as! Note
			let secondNote = measure.notes[firstNoteIndex + 1] as! Note
			let thirdNote = measure.notes[firstNoteIndex + 2] as! Note
			XCTAssert(firstNote.tie == .Begin)
			XCTAssert(secondNote.tie == .End)
			XCTAssertNil(thirdNote.tie)
		} catch {
			XCTFail(String(error))
		}
	}
	
	// MARK: - notesHolderIndexFromMeasureIndex(_: Int) -> (Int, Int?, Bool)
	// MARK: Failures
	
	func testNotesHolderIndexForOutOfRangeMeasureIndex() {
		do {
			let _ = try staff.notesHolderIndexFromMeasureIndex(20)
			shouldFail()
		} catch StaffErrors.MeasureIndexOutOfRange {
		} catch {
			expected(StaffErrors.MeasureIndexOutOfRange, actual: error)
		}
	}
	
	// MARK: Successes
	
	func testNotesHolderIndexForNoRepeats() {
		do {
			let indexes = try staff.notesHolderIndexFromMeasureIndex(2)
			XCTAssertEqual(indexes.notesHolderIndex, 2)
			XCTAssertNil(indexes.repeatMeasureIndex)
		} catch {
			XCTFail(String(error))
		}
	}
	
	func testNotesHolderIndexForOriginalRepeatedMeasure() {
		do {
			let indexes = try staff.notesHolderIndexFromMeasureIndex(8)
			XCTAssertEqual(indexes.notesHolderIndex, 6)
			XCTAssertEqual(indexes.repeatMeasureIndex, 1)
			XCTAssertEqual(indexes.isRepeatedMeasure, false)
		} catch {
			XCTFail(String(error))
		}
	}
	
	func testNotesHolderIndexForRepeatedMeasure() {
		do {
			let indexes = try staff.notesHolderIndexFromMeasureIndex(9)
			XCTAssertEqual(indexes.notesHolderIndex, 6)
			XCTAssertEqual(indexes.repeatMeasureIndex, 0)
			XCTAssertEqual(indexes.isRepeatedMeasure, true)
		} catch {
			XCTFail(String(error))
		}
	}
	
	func testNotesHolderIndexForAfterRepeat() {
		do {
			let indexes = try staff.notesHolderIndexFromMeasureIndex(13)
			XCTAssertEqual(indexes.notesHolderIndex, 7)
			XCTAssertNil(indexes.repeatMeasureIndex)
		} catch {
			XCTFail(String(error))
		}
	}
}
