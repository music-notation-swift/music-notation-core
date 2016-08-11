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
        key: Key(noteLetter: .c))

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        measure = Measure(
            timeSignature: TimeSignature(topNumber: 4, bottomNumber: 4, tempo: 120),
            key: Key(noteLetter: .c))
    }

    func test_addNote() {
        XCTAssertEqual(measure.notes.count, 0)
        measure.addNote(Note(noteDuration: .whole, tone: Tone(noteLetter: .c, octave: .octave0)))
        measure.addNote(Note(noteDuration: .quarter, tone: Tone(accidental: .sharp, noteLetter: .d, octave: .octave0)))
        measure.addNote(Note(noteDuration: .whole))
        XCTAssertEqual(measure.notes.count, 3)
        print(measure)
    }
	
	func testInsertNoteInvalidIndex() {
		XCTAssertEqual(measure.notes.count, 0)
		do {
			try measure.insertNote(Note(noteDuration: .whole), at: 1)
		} catch MeasureError.noteIndexOutOfRange {
		} catch {
			expected(MeasureError.noteIndexOutOfRange, actual:error)
		}
	}
	
	func testInsertNote() {
		XCTAssertEqual(measure.notes.count, 0)
		let note1 = Note(noteDuration: .whole)
		let note2 = Note(noteDuration: .eighth)
		let note3 = Note(noteDuration: .quarter)
		measure.addNote(note1)
		measure.addNote(note2)
		do {
			try measure.insertNote(note3, at: 1)
			XCTAssertEqual(measure.notes.count, 3)
			print(measure)
			
			let resultNote1 = measure.notes[0] as! Note
			let resultNote2 = measure.notes[1] as! Note
			let resultNote3 = measure.notes[2] as! Note
			XCTAssertEqual(resultNote1, note1)
			XCTAssertEqual(resultNote2, note3)
			XCTAssertEqual(resultNote3, note2)
		} catch {
			XCTFail(String(error))
		}

	}
	
    func test_startTieAt() {
        XCTAssertEqual(measure.notes.count, 0)
        measure.addNote(Note(noteDuration: .quarter,
            tone: Tone(noteLetter: .c, octave: .octave1)))

        // Succeed if there is no next note, but only change the note to Begin
        do {
            try measure.startTie(at: 0)
            let note = measure.notes[0] as! Note
            XCTAssertNotNil(note.tie)
            XCTAssert(note.tie == .begin)
        } catch {
            XCTFail(String(error))
        }

        // FIXME: When I refactor the tests to small ones, this will not be needed
        try! measure.removeTie(at: 0)

        // Succeed if there is a next note
        measure.addNote(Note(noteDuration: .eighth,
            tone: Tone(noteLetter: .c, octave: .octave1)))
        do {
            try measure.startTie(at: 0)
            let note1 = measure.notes[0] as! Note
            let note2 = measure.notes[1] as! Note
            XCTAssertNotNil(note1.tie)
            XCTAssert(note1.tie == .begin)
            XCTAssertNotNil(note2.tie)
            XCTAssert(note2.tie == .end)
        } catch {
            XCTFail(String(error))
        }

        // Succeed if the note is already the beginning of a tie
        do {
            try measure.startTie(at: 0)
            let note1 = measure.notes[0] as! Note
            let note2 = measure.notes[1] as! Note
            XCTAssert(note1.tie == .begin)
            XCTAssert(note2.tie == .end)
        } catch {
            XCTFail(String(error))
        }

        // Succeed if there is a next note and it's in a tuplet
        measure.addNote(Note(noteDuration: .eighth,
            tone: Tone(noteLetter: .c, octave: .octave1)))
        let notes = [
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1))
        ]
        do {
            let tuplet = try Tuplet(notes: notes)
            measure.addTuplet(tuplet)
            try measure.startTie(at: 2)
            let note1 = measure.notes[2] as! Note
            let tuplet2 = measure.notes[3] as! Tuplet
            XCTAssert(note1.tie == .begin)
            XCTAssert(tuplet2.notes[0].tie == .end)
        } catch {
            XCTFail(String(error))
        }

        // Succeed if it is the last note of a tuplet and there is no next note. Just change to Begin
        do {
            try measure.startTie(at: 5)
            let tuplet = measure.notes[3] as! Tuplet
            XCTAssert(tuplet.notes[2].tie == .begin)
        } catch {
            XCTFail(String(error))
        }
        // FIXME: When I refactor the tests to small ones, this will not be needed
        try! measure.removeTie(at: 5)

        // Succeed if starting a tie on the note of an ending tie
        do {
            try measure.startTie(at: 3)
            let tuplet = measure.notes[3] as! Tuplet
            XCTAssert(tuplet.notes[0].tie == .beginAndEnd)
            XCTAssert(tuplet.notes[1].tie == .end)
        } catch {
            XCTFail(String(error))
        }

        // Succeed if it starts on the end of a tuplet and there is a next note
        measure.addNote(Note(noteDuration: .sixteenth,
            tone: Tone(noteLetter: .a, octave: .octave1)))
        do {
            try measure.startTie(at: 5)
            let tuplet = measure.notes[3] as! Tuplet
            let note1 = measure.notes[4] as! Note
            XCTAssert(tuplet.notes[2].tie == .begin)
            XCTAssert(note1.tie == .end)
        } catch {
            XCTFail(String(error))
        }

        // Succeeds if it starts on the end of a tuplet and ends on another tuplet
        do {
            let note = Note(noteDuration: .sixteenth,
                            tone: Tone(noteLetter: .c, octave: .octave1))
            let tuplet1 = try Tuplet(notes: [note, note, note])
            let tuplet2 = try Tuplet(notes: [note, note, note, note, note])
            measure.addTuplet(tuplet1)
            measure.addTuplet(tuplet2)
            try measure.startTie(at: 9)
            let note1 = noteFromMeasure(measure, noteIndex: 5, tupletIndex: 2)
            let note2 = noteFromMeasure(measure, noteIndex: 6, tupletIndex: 0)
            XCTAssert(note1.tie == .begin)
            XCTAssert(note2.tie == .end)
        } catch {
            XCTFail()
        }
    }

    func test_removeTieAt() {
        XCTAssertEqual(measure.notes.count, 0)
        measure.addNote(Note(noteDuration: .eighth,
            tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth,
            tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth,
            tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth,
            tone: Tone(noteLetter: .c, octave: .octave1)))

        // Fails if there is no note at the given index
        do {
            try measure.removeTie(at: 4)
            shouldFail()
        } catch MeasureError.noteIndexOutOfRange {
        } catch {
            expected(MeasureError.noteIndexOutOfRange, actual: error)
        }

        // Succeeds if there is no tie at the given index
        do {
            try measure.removeTie(at: 0)
            let firstNote = noteFromMeasure(measure, noteIndex: 0, tupletIndex: nil)
            let secondNote = noteFromMeasure(measure, noteIndex: 1, tupletIndex: nil)
            XCTAssertNil(firstNote.tie)
            XCTAssertNil(secondNote.tie)
        } catch MeasureError.noTieBeginsAtIndex {
        } catch {
            expected(MeasureError.noTieBeginsAtIndex, actual: error)
        }

        // Succeeds if index is beginning of a tie
        do {
            setTie(at: 0)
            try measure.removeTie(at: 0)
            let firstNote = noteFromMeasure(measure, noteIndex: 0, tupletIndex: nil)
            let secondNote = noteFromMeasure(measure, noteIndex: 1, tupletIndex: nil)
            XCTAssertNil(firstNote.tie)
            XCTAssertNil(secondNote.tie)
        } catch {
            XCTFail(String(error))
        }

        // Succeeds if index is end of a tie and beginning
        do {
            setTie(at: 0)
            setTie(at: 1)
            try measure.removeTie(at: 1)
            let firstNote = noteFromMeasure(measure, noteIndex: 1, tupletIndex: nil)
            let secondNote = noteFromMeasure(measure, noteIndex: 2, tupletIndex: nil)
            XCTAssert(firstNote.tie == .end)
            XCTAssertNil(secondNote.tie)
        } catch {
            XCTFail(String(error))
        }

        // Succeeds if tie starts in tuplet, and ends on a separate note
        let note = Note(noteDuration: .sixteenth,
                        tone: Tone(noteLetter: .c, octave: .octave1))
        do {
            let tuplet = try Tuplet(notes: [note, note, note])
            measure.addTuplet(tuplet)
            measure.addNote(note)
        } catch {
            XCTFail()
        }
        do {
            setTie(at: 6)
            try measure.removeTie(at: 6)
            let firstNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 2)
            let secondNote = noteFromMeasure(measure, noteIndex: 5, tupletIndex: nil)
            XCTAssertNil(firstNote.tie)
            XCTAssertNil(secondNote.tie)
        } catch {
            XCTFail()
        }

        // Succeeds if tie starts and ends in the same tuplet
        do {
            setTie(at: 5)
            try measure.removeTie(at: 5)
            let firstNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 1)
            let secondNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 2)
            XCTAssertNil(firstNote.tie)
            XCTAssertNil(secondNote.tie)
        } catch {
            XCTFail()
        }

        // Succeeds if tie starts in a separate note and ends in a tuplet
        do {
            setTie(at: 4)
            try measure.removeTie(at: 4)
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
            setTie(at: 11)
            try measure.removeTie(at: 11)
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
        measure.addNote(Note(noteDuration: .quarter))
        measure.addNote(Note(noteDuration: .quarter))
        measure.addNote(Note(noteDuration: .quarter))
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
        measure.addNote(Note(noteDuration: .quarter))
        do {
            let note1 = Note(noteDuration: .eighth,
                             tone: Tone(noteLetter: .a, octave: .octave1))
            let note2 = Note(noteDuration: .eighth,
                             tone: Tone(noteLetter: .b, octave: .octave1))
            let note3 = Note(noteDuration: .eighth,
                             tone: Tone(noteLetter: .c, octave: .octave1))
            try measure.addTuplet(Tuplet(notes: [note1, note2, note3]))
            let index = try measure.noteCollectionIndexFromNoteIndex(2)
            XCTAssertEqual(index.noteIndex, 1)
            XCTAssertNotNil(index.tupletIndex)
            XCTAssertEqual(index.tupletIndex!, 1)
            
            // Properly address regular note coming after a tuplet
            measure.addNote(Note(noteDuration: .eighth))
            let index2 = try measure.noteCollectionIndexFromNoteIndex(4)
            XCTAssertEqual(index2.noteIndex, 2)
            XCTAssertNil(index2.tupletIndex)
        } catch {
            XCTFail(String(error))
        }
    }
    
    private func setTie(at index: Int, functionName: String = #function, lineNum: Int = #line) {
        do {
            try measure.startTie(at: index)
            let (noteIndex1, tupletIndex1) = try measure.noteCollectionIndexFromNoteIndex(index)
            let (noteIndex2, tupletIndex2) = try measure.noteCollectionIndexFromNoteIndex(index + 1)
            let firstNote = noteFromMeasure(measure, noteIndex: noteIndex1,
                                            tupletIndex: tupletIndex1)
            let secondNote = noteFromMeasure(measure, noteIndex: noteIndex2,
                                             tupletIndex: tupletIndex2)
            XCTAssert(firstNote.tie == .begin || firstNote.tie == .beginAndEnd,
                      "\(functionName): \(lineNum)")
            XCTAssert(secondNote.tie == .end || secondNote.tie == .beginAndEnd,
                      "\(functionName): \(lineNum)")
        } catch {
            XCTFail("\(error) in \(functionName): \(lineNum)")
        }
    }
    
    private func noteFromMeasure(_ measure: Measure, noteIndex: Int, tupletIndex: Int?) -> Note {
        if let tupletIndex = tupletIndex {
            let tuplet = measure.notes[noteIndex] as! Tuplet
            return tuplet.notes[tupletIndex]
        } else {
            return measure.notes[noteIndex] as! Note
        }
    }
}
