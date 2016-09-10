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

    func testAddNote() {
        XCTAssertEqual(measure.notes[0].count, 0)
        measure.addNote(Note(noteDuration: .whole, tone: Tone(noteLetter: .c, octave: .octave0)))
        measure.addNote(Note(noteDuration: .quarter, tone: Tone(accidental: .sharp, noteLetter: .d, octave: .octave0)))
        measure.addNote(Note(noteDuration: .whole))
        XCTAssertEqual(measure.notes[0].count, 3)
    }

    // MARK: - startTie(at:)
    // MARK: Successes

    func testStartTieNoNextNote() {
        measure.addNote(Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave1)))
        // Only change note to .begin
        do {
            try measure.startTie(at: 0, inSet: 0)
            let note = measure.notes[0][0] as! Note
            XCTAssertNotNil(note.tie)
            XCTAssert(note.tie == .begin)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testStartTieHasNextNote() {
        measure.addNote(Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        do {
            try measure.startTie(at: 0, inSet: 0)
            let note1 = measure.notes[0][0] as! Note
            let note2 = measure.notes[0][1] as! Note
            XCTAssertNotNil(note1.tie)
            XCTAssert(note1.tie == .begin)
            XCTAssertNotNil(note2.tie)
            XCTAssert(note2.tie == .end)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testStartTieNoteAlreadyBeginningOfTie() {
        measure.addNote(Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        do {
            try measure.startTie(at: 0, inSet: 0)
            try measure.startTie(at: 0, inSet: 0)
            let note1 = measure.notes[0][0] as! Note
            let note2 = measure.notes[0][1] as! Note
            XCTAssert(note1.tie == .begin)
            XCTAssert(note2.tie == .end)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testStartTieNextNoteInTuplet() {
        measure.addNote(Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        let notes = [
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1))
        ]
        do {
            // setup
            let tuplet = try Tuplet(3, .eighth, notes: notes)
            measure.addTuplet(tuplet)

            // test
            try measure.startTie(at: 2, inSet: 0)
            let note1 = measure.notes[0][2] as! Note
            let tuplet2 = measure.notes[0][3] as! Tuplet
            XCTAssert(note1.tie == .begin)
            XCTAssert(try tuplet2.note(at: 0).tie == .end)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testStartTieLastNoteOfTupletNoNextNote() {
        // Just change to .begin
        measure.addNote(Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        let notes = [
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1))
        ]
        do {
            // setup
            let tupletSetup = try Tuplet(3, .eighth, notes: notes)
            measure.addTuplet(tupletSetup)

            // test
            try measure.startTie(at: 2, inSet: 0)
            try measure.startTie(at: 5, inSet: 0)
            let tuplet = measure.notes[0][3] as! Tuplet
            XCTAssert(try tuplet.note(at: 2).tie == .begin)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testStartTieNoteIsEndOfAnotherTie() {
        measure.addNote(Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        let notes = [
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1))
        ]
        do {
            // setup
            let tupletSetup = try Tuplet(3, .eighth, notes: notes)
            measure.addTuplet(tupletSetup)
            try measure.startTie(at: 2, inSet: 0)

            // test
            try measure.startTie(at: 3, inSet: 0)
            let tuplet = measure.notes[0][3] as! Tuplet
            XCTAssert(try tuplet.note(at: 0).tie == .beginAndEnd)
            XCTAssert(try tuplet.note(at: 1).tie == .end)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testStartTieLastNoteOfTupletHasNextNote() {
        measure.addNote(Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        let notes = [
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1))
        ]
        do {
            // setup
            let tupletSetup = try Tuplet(3, .eighth, notes: notes)
            measure.addTuplet(tupletSetup)
            try measure.startTie(at: 2, inSet: 0)

            // test
            try measure.startTie(at: 5, inSet: 0)
            let tuplet = measure.notes[0][3] as! Tuplet
            XCTAssert(try tuplet.note(at: 2).tie == .begin)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testStartTieLastNoteOfTupletNextNoteTuplet() {
        do {
            let note = Note(noteDuration: .sixteenth,
                            tone: Tone(noteLetter: .c, octave: .octave1))
            let tuplet1 = try Tuplet(3, .sixteenth, notes: [note, note, note])
            let tuplet2 = try Tuplet(5, .sixteenth, notes: [note, note, note, note, note])
            measure.addTuplet(tuplet1)
            measure.addTuplet(tuplet2)
            try measure.startTie(at: 2, inSet: 0)
            let note1 = noteFromMeasure(measure, noteIndex: 0, tupletIndex: 2)
            let note2 = noteFromMeasure(measure, noteIndex: 1, tupletIndex: 0)
            XCTAssert(note1.tie == .begin)
            XCTAssert(note2.tie == .end)
        } catch {
            XCTFail()
        }
    }

    // MARK: - removeTie(at:)
    // MARK: Failures

    func testRemoveTieNoNoteAtIndex() {
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))

        do {
            try measure.removeTie(at: 4, inSet: 0)
            shouldFail()
        } catch MeasureError.noteIndexOutOfRange {
        } catch {
            expected(MeasureError.noteIndexOutOfRange, actual: error)
        }
    }

    // MARK: Successes

    func testRemoveTieNoTie() {
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))

        do {
            try measure.removeTie(at: 0, inSet: 0)
            let firstNote = noteFromMeasure(measure, noteIndex: 0, tupletIndex: nil)
            let secondNote = noteFromMeasure(measure, noteIndex: 1, tupletIndex: nil)
            XCTAssertNil(firstNote.tie)
            XCTAssertNil(secondNote.tie)
        } catch MeasureError.noTieBeginsAtIndex {
        } catch {
            expected(MeasureError.noTieBeginsAtIndex, actual: error)
        }
    }

    func testRemoveTieBeginOfTie() {
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))

        do {
            setTie(at: 0)
            try measure.removeTie(at: 0, inSet: 0)
            let firstNote = noteFromMeasure(measure, noteIndex: 0, tupletIndex: nil)
            let secondNote = noteFromMeasure(measure, noteIndex: 1, tupletIndex: nil)
            XCTAssertNil(firstNote.tie)
            XCTAssertNil(secondNote.tie)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testRemoveTieFromBeginAndEnd() {
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))

        do {
            setTie(at: 0)
            setTie(at: 1)
            try measure.removeTie(at: 1, inSet: 0)
            let firstNote = noteFromMeasure(measure, noteIndex: 1, tupletIndex: nil)
            let secondNote = noteFromMeasure(measure, noteIndex: 2, tupletIndex: nil)
            XCTAssert(firstNote.tie == .end)
            XCTAssertNil(secondNote.tie)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testRemoveTieBeginsInTuplet() {
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))

        let note = Note(noteDuration: .sixteenth,
                        tone: Tone(noteLetter: .c, octave: .octave1))
        do {
            let tuplet = try Tuplet(3, .sixteenth, notes: [note, note, note])
            measure.addTuplet(tuplet)
            measure.addNote(note)
        } catch {
            XCTFail()
        }

        do {
            setTie(at: 6)
            try measure.removeTie(at: 6, inSet: 0)
            let firstNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 2)
            let secondNote = noteFromMeasure(measure, noteIndex: 5, tupletIndex: nil)
            XCTAssertNil(firstNote.tie)
            XCTAssertNil(secondNote.tie)
        } catch {
            XCTFail()
        }
    }

    func testRemoveTieBeginAndEndInOneTuplet() {
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))

        let note = Note(noteDuration: .sixteenth, tone: Tone(noteLetter: .c, octave: .octave1))
        do {
            let tuplet = try Tuplet(3, .sixteenth, notes: [note, note, note])
            measure.addTuplet(tuplet)
            measure.addNote(note)
        } catch {
            XCTFail()
        }

        do {
            setTie(at: 5)
            try measure.removeTie(at: 5, inSet: 0)
            let firstNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 1)
            let secondNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 2)
            XCTAssertNil(firstNote.tie)
            XCTAssertNil(secondNote.tie)
        } catch {
            XCTFail()
        }
    }

    func testRemoveTieEndsInTuplet() {
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))

        let note = Note(noteDuration: .sixteenth, tone: Tone(noteLetter: .c, octave: .octave1))
        do {
            let tuplet = try Tuplet(3, .sixteenth, notes: [note, note, note])
            measure.addTuplet(tuplet)
            measure.addNote(note)
        } catch {
            XCTFail()
        }

        do {
            setTie(at: 4)
            try measure.removeTie(at: 4, inSet: 0)
            let firstNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 0)
            let secondNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 1)
            XCTAssertNil(firstNote.tie)
            XCTAssertNil(secondNote.tie)
        } catch {
            XCTFail()
        }
    }

    func testRemoveTieTupletToOtherTuplet() {
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))

        let note = Note(noteDuration: .sixteenth, tone: Tone(noteLetter: .c, octave: .octave1))
        do {
            let tuplet = try Tuplet(3, .sixteenth, notes: [note, note, note])
            measure.addTuplet(tuplet)
            measure.addNote(note)
        } catch {
            XCTFail()
        }

        do {
            let tuplet1 = try Tuplet(5, .sixteenth, notes: [note, note, note, note, note])
            let tuplet2 = try Tuplet(3, .sixteenth, notes: [note, note, note])
            measure.addTuplet(tuplet1)
            measure.addTuplet(tuplet2)
            setTie(at: 11)
            try measure.removeTie(at: 11, inSet: 0)
            let firstNote = noteFromMeasure(measure, noteIndex: 6, tupletIndex: 3)
            let secondNote = noteFromMeasure(measure, noteIndex: 7, tupletIndex: 0)
            XCTAssertNil(firstNote.tie)
            XCTAssertNil(secondNote.tie)
        } catch {
            XCTFail()
        }
    }

    // MARK: - noteCollectionIndexFromNoteIndex(_:)
    // MARK: Successes

    func testNoteCollectionIndexFromNoteIndexNoTuplets() {
        // NoteIndex should be the same if there are no tuplets
        measure.addNote(Note(noteDuration: .quarter))
        measure.addNote(Note(noteDuration: .quarter))
        measure.addNote(Note(noteDuration: .quarter))
        do {
            let index = try measure.noteCollectionIndexFromNoteIndex(2, inSet: 0)
            XCTAssertEqual(index.noteIndex, 2)
            XCTAssertNil(index.tupletIndex)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testNoteCollectionIndexFromNoteIndexWithinTuplet() {
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
            measure.addTuplet(try Tuplet(3, .eighth, notes: [note1, note2, note3]))
            let index = try measure.noteCollectionIndexFromNoteIndex(2, inSet: 0)
            XCTAssertEqual(index.noteIndex, 1)
            XCTAssertNotNil(index.tupletIndex)
            XCTAssertEqual(index.tupletIndex!, 1)

            // Properly address regular note coming after a tuplet
            measure.addNote(Note(noteDuration: .eighth))
            let index2 = try measure.noteCollectionIndexFromNoteIndex(4, inSet: 0)
            XCTAssertEqual(index2.noteIndex, 2)
            XCTAssertNil(index2.tupletIndex)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    private func setTie(at index: Int, functionName: String = #function, lineNum: Int = #line) {
        do {
            try measure.startTie(at: index, inSet: 0)
            let (noteIndex1, tupletIndex1) = try measure.noteCollectionIndexFromNoteIndex(index, inSet: 0)
            let (noteIndex2, tupletIndex2) = try measure.noteCollectionIndexFromNoteIndex(index + 1, inSet: 0)
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
            let tuplet = measure.notes[0][noteIndex] as! Tuplet
            return try! tuplet.note(at: tupletIndex)
        } else {
            return measure.notes[0][noteIndex] as! Note
        }
    }
}
