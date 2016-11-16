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
        measure.append(Note(noteDuration: .whole, tone: Tone(noteLetter: .c, octave: .octave0)))
        measure.append(Note(noteDuration: .quarter, tone: Tone(noteLetter: .d, accidental: .sharp, octave: .octave0)))
        measure.append(Note(noteDuration: .whole))
        XCTAssertEqual(measure.notes[0].count, 3)
    }

    // MARK: - replaceNotereplaceNote<T: NoteCollection>(at:with:T)
    // MARK: Failures

    func testReplaceNotesInvalidIndex() {
        let note = Note(noteDuration: .quarter, tone: Tone(noteLetter: .a, octave: .octave1))
        let notes = [
            Note(noteDuration: .sixteenth, tone: Tone(noteLetter: .c, octave: .octave1)),
            Note(noteDuration: .sixteenth, tone: Tone(noteLetter: .c, octave: .octave1)),
            Note(noteDuration: .sixteenth, tone: Tone(noteLetter: .a, octave: .octave1))
        ]
        assertThrowsError(MeasureError.invalidTupletIndex) {
            let tuplet = try Tuplet(3, .sixteenth, notes: notes)
            measure.append(tuplet)
            measure.append(note)
            XCTAssertEqual(measure.noteCount[0], 4)
            try measure.replaceNote(at: 1, with: note)
        }
    }

    // MARK: Successes

    func testReplaceNote() {
        XCTAssertEqual(measure.notes[0].count, 0)
        let note1 = Note(noteDuration: .whole)
        let note2 = Note(noteDuration: .eighth)
        measure.append(note1)
        measure.append(note2)
        assertNoErrorThrown {
            XCTAssertEqual(measure.noteCount[0], 2)
            try measure.replaceNote(at: 1, with: note1)
            let resultNote1 = try measure.note(at: 0, inSet: 0)
            let resultNote2 = try measure.note(at: 1, inSet: 0)
            XCTAssertEqual(resultNote1, note1)
            XCTAssertEqual(resultNote2, note1)
        }
    }

    // MARK: - replaceNote<T: NoteCollection>(at:with:[T])
    // MARK: Failures

    func testRepalceNoteWithInvalidNoteCollection() {
        measure.append(Note(noteDuration: .whole))
        assertThrowsError(MeasureError.invalidNoteCollection) {
            try measure.replaceNote(at: 0, with: [Note]())
        }
    }

    // MARK: Successes

    func testReplaceNoteWithNotes() {
        XCTAssertEqual(measure.notes[0].count, 0)
        let note1 = Note(noteDuration: .whole)
        let note2 = Note(noteDuration: .eighth)
        measure.append(note1)
        measure.append(note2)
        assertNoErrorThrown {
            XCTAssertEqual(measure.noteCount[0], 2)
            try measure.startTie(at: 0, inSet: 0)
            try measure.replaceNote(at: 0, with: [note2, note1])
            let resultNote1 = try measure.note(at: 0, inSet: 0)
            var resultNote2 = try measure.note(at: 1, inSet: 0)
            XCTAssertEqual(measure.noteCount[0], 3)
            XCTAssertEqual(resultNote1, note2)
            XCTAssertEqual(resultNote2.tie, .begin)

            // Clear tie result before compare
            resultNote2.tie = nil
            XCTAssertEqual(resultNote2, note1)
        }
    }

    // MARK: - replaceNotes<T: NoteCollection>(in:with:T)
    // MARK: Failures

    func testReplaceNotesInRangeInvalidIndex() {
        let note = Note(noteDuration: .quarter, tone: Tone(noteLetter: .a, octave: .octave1))
        let notes = [
            Note(noteDuration: .sixteenth, tone: Tone(noteLetter: .c, octave: .octave1)),
            Note(noteDuration: .sixteenth, tone: Tone(noteLetter: .c, octave: .octave1)),
            Note(noteDuration: .sixteenth, tone: Tone(noteLetter: .a, octave: .octave1))
        ]
        assertThrowsError(MeasureError.incompleteTuplet) {
            let tuplet = try Tuplet(3, .sixteenth, notes: notes)
            measure.append(tuplet)
            measure.append(note)
            XCTAssertEqual(measure.noteCount[0], 4)
            try measure.replaceNotes(in: 2...3, with: note)
        }
    }

    // MARK: Successes

    func testReplaceNotes() {
        XCTAssertEqual(measure.notes[0].count, 0)
        let note1 = Note(noteDuration: .whole)
        let note2 = Note(noteDuration: .eighth)
        measure.append(note1)
        measure.append(note2)
        assertNoErrorThrown {
            XCTAssertEqual(measure.noteCount[0], 2)
            try measure.replaceNotes(in: 0...1, with: note2)
            XCTAssertEqual(measure.noteCount[0], 1)
        }
    }

    // MARK: - replaceNotes<T: NoteCollection>(in:with:[T])
    // MARK: Failures

    func testReplaceNotesInRangeInvalidTie() {
        XCTAssertEqual(measure.notes[0].count, 0)
        var note1 = Note(noteDuration: .whole)
        note1.tie = .beginAndEnd
        let note2 = Note(noteDuration: .eighth)
        measure.append(note1)
        measure.append(note2)
        assertThrowsError(MeasureError.invalidTieState) {
            XCTAssertEqual(measure.noteCount[0], 2)
            try measure.replaceNotes(in: 0...1, with: [note1, note2])
        }
    }

    func testReplaceNotesInRangeWithInvalidIndexRange() {
        let note = Note(noteDuration: .quarter, tone: Tone(noteLetter: .a, octave: .octave1))
        let notes = [
            Note(noteDuration: .sixteenth, tone: Tone(noteLetter: .c, octave: .octave1)),
            Note(noteDuration: .sixteenth, tone: Tone(noteLetter: .c, octave: .octave1)),
            Note(noteDuration: .sixteenth, tone: Tone(noteLetter: .a, octave: .octave1))
        ]
        assertThrowsError(MeasureError.incompleteTuplet) {
            let tuplet = try Tuplet(3, .sixteenth, notes: notes)
            measure.append(tuplet)
            measure.append(note)
            XCTAssertEqual(measure.noteCount[0], 4)
            try measure.replaceNotes(in: 2...3, with: [note, note])
        }
    }

    // MARK: Successes

    func testReplaceNotesInRangeWithOtherNotes() {
        XCTAssertEqual(measure.notes[0].count, 0)
        let note1 = Note(noteDuration: .whole)
        let note2 = Note(noteDuration: .eighth)
        measure.append(note1)
        measure.append(note2)
        assertNoErrorThrown {
            XCTAssertEqual(measure.noteCount[0], 2)
            try measure.replaceNotes(in: 0...1, with: [note2, note1])
            let resultNote1 = try measure.note(at: 0, inSet: 0)
            let resultNote2 = try measure.note(at: 1, inSet: 0)
            XCTAssertEqual(measure.noteCount[0], 2)
            XCTAssertEqual(resultNote1, note2)
            XCTAssertEqual(resultNote2, note1)
        }
    }

    func testReplaceTupletInRangeWithNotes() {
        XCTAssertEqual(measure.notes[0].count, 0)
        let note1 = Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1))
        let note2 = Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1))
        let note3 = Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1))
        assertNoErrorThrown {
            let tuplet = try Tuplet(3, .eighth, notes: [note1, note2, note3])
            measure.append(note3)
            measure.append(tuplet)
            try measure.startTie(at: 0, inSet: 0)
            XCTAssertEqual(measure.noteCount[0], 4)
            try measure.replaceNotes(in: 1...3, with: [note2, note1])
            var resultNote1 = try measure.note(at: 1, inSet: 0)
            let resultNote2 = try measure.note(at: 2, inSet: 0)
            XCTAssertEqual(measure.noteCount[0], 3)
            XCTAssertEqual(resultNote1.tie, .end)
            resultNote1.tie = nil
            XCTAssertEqual(resultNote1, note2)
            XCTAssertEqual(resultNote2, note1)
        }
    }

    // MARK: - insert(_:NoteCollection:at)
    // MARK: Failures

    func testInsertNoteIndexOutOfRange() {
        XCTAssertEqual(measure.notes[0].count, 0)
        assertThrowsError(MeasureError.noteIndexOutOfRange) {
            try measure.insert(Note(noteDuration: .whole), at: 1)
        }
    }

    func testInsertInvalidTupletIndex() {
        let note1 = Note(noteDuration: .quarter, tone: Tone(noteLetter: .a, octave: .octave1))
        let note2 = Note(noteDuration: .quarter, tone: Tone(noteLetter: .b, octave: .octave1))
        measure.append(note1)
        measure.append(note2)
        let notes = [
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1))
        ]
        assertThrowsError(MeasureError.invalidTupletIndex) {
            let tuplet = try Tuplet(3, .eighth, notes: notes)
            try measure.insert(tuplet, at: 1)
            try measure.insert(tuplet, at: 2)
        }
    }

    // MARK: Successes

    func testInsertNote() {
        XCTAssertEqual(measure.notes[0].count, 0)
        let note1 = Note(noteDuration: .whole)
        let note2 = Note(noteDuration: .eighth)
        let note3 = Note(noteDuration: .quarter)
        measure.append(note1)
        measure.append(note2)
        assertNoErrorThrown {
            try measure.insert(note3, at: 1)
            XCTAssertEqual(measure.notes[0].count, 3)
            print(measure)

            let resultNote1 = try measure.note(at: 0, inSet: 0)
            let resultNote2 = try measure.note(at: 1, inSet: 0)
            let resultNote3 = try measure.note(at: 2, inSet: 0)
            XCTAssertEqual(resultNote1, note1)
            XCTAssertEqual(resultNote2, note3)
            XCTAssertEqual(resultNote3, note2)
        }
    }

    func testInsertTuplet() {
        let note1 = Note(noteDuration: .quarter, tone: Tone(noteLetter: .a, octave: .octave1))
        let note2 = Note(noteDuration: .quarter, tone: Tone(noteLetter: .b, octave: .octave1))
        measure.append(note1)
        measure.append(note2)
        let notes = [
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1))
        ]
        assertNoErrorThrown {
            let tuplet = try Tuplet(3, .eighth, notes: notes)
            try measure.insert(tuplet, at: 1)
            let resultNote1 = try measure.note(at: 0)
            let resultTuplet = measure.notes[0][1]  as! Tuplet
            let resultNote2 = try measure.note(at: 4)
            XCTAssertEqual(measure.noteCount[0], 5)
            XCTAssertEqual(note1, resultNote1)
            XCTAssertEqual(tuplet, resultTuplet)
            XCTAssertEqual(note2, resultNote2)
        }
    }

    // MARK: - removeNote(at)
    // MARK: Failures

    func testRemoveNoteFromTuplet() {
        XCTAssertEqual(measure.notes[0].count, 0)
        let note1 = Note(noteDuration: .eighth)
        measure.append(note1)
        assertThrowsError(MeasureError.removeNoteFromTuplet)  {
            let tuplet = try Tuplet(3, .eighth, notes: [note1, note1, note1])
            measure.append(tuplet)
            try measure.removeNote(at: 1)
        }
    }

    func testRemoveNoteInvalidTieStateStart() {
        var note = Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave1))
        note.tie = .end
        measure.append(note)
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        assertThrowsError(MeasureError.invalidTieState) {
            try measure.removeNote(at: 0)
        }
    }

    func testRemoveNoteInvalidTieStateEnd() {
        var note = Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave1))
        note.tie = .begin
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(note)
        assertThrowsError(MeasureError.invalidTieState) {
            XCTAssertEqual(measure.noteCount[0], 2)
            try measure.removeNote(at: 1)
        }
    }

    // MARK: Successes

    func testRemoveNote() {
        XCTAssertEqual(measure.notes[0].count, 0)
        let note1 = Note(noteDuration: .whole)
        let note2 = Note(noteDuration: .eighth)
        let note3 = Note(noteDuration: .quarter)
        measure.append(note1)
        measure.append(note2)
        measure.append(note3)
        assertNoErrorThrown {
            try measure.removeNote(at: 1)
            XCTAssertEqual(measure.notes[0].count, 2)

            let resultNote1 = try measure.note(at: 0, inSet: 0)
            let resultNote2 = try measure.note(at: 1, inSet: 0)

            XCTAssertEqual(resultNote1, note1)
            XCTAssertEqual(resultNote2, note3)
        }
    }

    func testRemoveNoteWithEndTie() {
        measure.append(Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        assertNoErrorThrown {
            try measure.startTie(at: 0, inSet: 0)
            try measure.removeNote(at: 1)
        }
    }


    // MARK:  - removeNotesInRange()
    // MARK: Failures

    func testRemoveNotesInRangeInvalidTieState() {
        XCTAssertEqual(measure.notes[0].count, 0)
        var note1 = Note(noteDuration: .whole)
        note1.tie = .end
        let note2 = Note(noteDuration: .eighth)
        measure.append(note1)
        measure.append(note2)
        assertThrowsError(MeasureError.invalidTieState) {
            XCTAssertEqual(measure.noteCount[0], 2)
            try measure.removeNotesInRange(0...1)
        }
    }

    func testRemoveNotesInRangeInvalidTieEnd() {
        XCTAssertEqual(measure.notes[0].count, 0)
        let note1 = Note(noteDuration: .whole)
        var note2 = Note(noteDuration: .eighth)
        note2.tie = .begin
        measure.append(note1)
        measure.append(note2)
        assertThrowsError(MeasureError.invalidTieState) {
            XCTAssertEqual(measure.noteCount[0], 2)
            try measure.removeNotesInRange(0...2)
        }
    }

    func testRemoveNotesWithInvalidRangeStart() {
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        let notes = [
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1))
        ]
        assertThrowsError(MeasureError.incompleteTuplet) {
            let tuplet = try Tuplet(3, .eighth, notes: notes)
            measure.append(tuplet)
            XCTAssertEqual(measure.noteCount[0], 4)
            try measure.removeNotesInRange(0...1)
        }
    }

    func testRemoveNotesWithInvalidRangeEnd() {
        let notes = [
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1))
        ]
        assertThrowsError(MeasureError.incompleteTuplet) {
            let tuplet = try Tuplet(3, .eighth, notes: notes)
            measure.append(tuplet)
            measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
            XCTAssertEqual(measure.noteCount[0], 4)
            try measure.removeNotesInRange(2...3)
        }
    }

    // MARK: Successes

    func testRemoveNotesInRange() {
        XCTAssertEqual(measure.notes[0].count, 0)
        let note1 = Note(noteDuration: .whole)
        let note2 = Note(noteDuration: .eighth)
        let note3 = Note(noteDuration: .quarter)
        measure.append(note1)
        measure.append(Note(noteDuration: .quarter))
        measure.append(Note(noteDuration: .quarter))
        measure.append(Note(noteDuration: .quarter))
        measure.append(Note(noteDuration: .quarter))
        measure.append(note2)
        measure.append(note3)
        assertNoErrorThrown {
            XCTAssertEqual(measure.notes[0].count, 7)
            try measure.removeNotesInRange(1...4)
            XCTAssertEqual(measure.notes[0].count, 3)

            let resultNote1 = try measure.note(at: 0, inSet: 0)
            let resultNote2 = try measure.note(at: 1, inSet: 0)
            let resultNote3 = try measure.note(at: 2, inSet: 0)

            XCTAssertEqual(resultNote1, note1)
            XCTAssertEqual(resultNote2, note2)
            XCTAssertEqual(resultNote3, note3)
        }
    }

    func testRemoveNotesWithTupletsInRange() {
        XCTAssertEqual(measure.notes[0].count, 0)
        let note1 = Note(noteDuration: .whole)
        let note2 = Note(noteDuration: .eighth)
        let note3 = Note(noteDuration: .quarter)
        measure.append(note1)
        measure.append(Note(noteDuration: .quarter))
        measure.append(Note(noteDuration: .quarter))
        measure.append(Note(noteDuration: .quarter))
        measure.append(Note(noteDuration: .quarter))
        measure.append(note2)
        measure.append(note3)
        let notes = [
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1))
        ]
        assertNoErrorThrown {
            let tuplet = try Tuplet(3, .eighth, notes: notes)
            try measure.insert(tuplet, at: 4)

            XCTAssertEqual(measure.notes[0].count, 8)
            try measure.removeNotesInRange(1...7)
            XCTAssertEqual(measure.notes[0].count, 3)

            let resultNote1 = try measure.note(at: 0, inSet: 0)
            let resultNote2 = try measure.note(at: 1, inSet: 0)
            let resultNote3 = try measure.note(at: 2, inSet: 0)

            XCTAssertEqual(resultNote1, note1)
            XCTAssertEqual(resultNote2, note2)
            XCTAssertEqual(resultNote3, note3)
        }
    }

    // MARK: - createTuplet()
    // MARK: Failures

    func testCreateTupletInvalidTupletIndexStart() {
        let note1 = Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1))
        let note2 = Note(noteDuration: .eighth, tone: Tone(noteLetter: .b, octave: .octave1))
        let note3 = Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1))
        assertThrowsError(MeasureError.invalidTupletIndex)  {
            let tuplet = try Tuplet(3, .eighth, notes: [note1, note2, note3])
            measure.append(tuplet)
            measure.append(Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave1)))
            try measure.createTuplet(3, .quarter, fromNotesInRange: 1...3)
        }
    }

    func testCreateTupletInvalidTupletIndexEnd() {
        let note1 = Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1))
        let note2 = Note(noteDuration: .eighth, tone: Tone(noteLetter: .b, octave: .octave1))
        let note3 = Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1))
        measure.append(note1)
        assertThrowsError(MeasureError.invalidTupletIndex)  {
            let tuplet = try Tuplet(3, .eighth, notes: [note1, note2, note3])
            measure.append(tuplet)
            try measure.createTuplet(3, .quarter, fromNotesInRange: 0...2)
        }
    }

    func testCreateTupletNoteIndexOutOfRange() {
        measure.append(Note(noteDuration: .quarter, tone: Tone(noteLetter: .a, octave: .octave1)))
        measure.append(Note(noteDuration: .quarter, tone: Tone(noteLetter: .b, octave: .octave1)))
        measure.append(Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave1)))
        assertThrowsError(MeasureError.noteIndexOutOfRange)  {
            try measure.createTuplet(3, .quarter, fromNotesInRange: 0...3)
        }
    }

    // MARK: Successes

    func testCreateTuplet() {
        measure.append(Note(noteDuration: .quarter, tone: Tone(noteLetter: .a, octave: .octave1)))
        measure.append(Note(noteDuration: .quarter, tone: Tone(noteLetter: .b, octave: .octave1)))
        measure.append(Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave1)))
        assertNoErrorThrown {
            try measure.createTuplet(3, .quarter, fromNotesInRange: 0...2)
            XCTAssert(measure.notes[0].count == 1)
        }
    }

    // MARK: - breakdownTuplet(at)
    // MARK: Failures

    func testBreakDownTupletInvalidIndex() {
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1)))
        assertThrowsError(MeasureError.invalidTupletIndex) {
            XCTAssert(measure.noteCount[0] == 1)
            try measure.breakdownTuplet(at: 0)
        }
    }

    // MARK: Successes

    func testBreakDownTuplet() {
        let note1 = Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1))
        let note2 = Note(noteDuration: .eighth, tone: Tone(noteLetter: .b, octave: .octave1))
        let note3 = Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1))
        assertNoErrorThrown {
            let tuplet = try Tuplet(3, .eighth, notes: [note1, note2, note3])
            measure.append(tuplet)

            try measure.breakdownTuplet(at: 0)
            XCTAssert(measure.noteCount[0] == 3)

            let resultNote1 = try measure.note(at: 0)
            let resultNote2 = try measure.note(at: 1)
            let resultNote3 = try measure.note(at: 2)

            XCTAssertEqual(resultNote1, note1)
            XCTAssertEqual(resultNote2, note2)
            XCTAssertEqual(resultNote3, note3)
        }
    }

    // MARK: - prepTieForInsertion
    // MARK: Failures

    func testPrepTieForInsertNoteRemoveTie() {
        measure.append(Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        assertThrowsError(MeasureError.invalidTieState) {
            try measure.startTie(at: 0, inSet: 0)
            let note = Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave1))
            try measure.insert(note, at: 1, inSet: 0)
        }
    }

    // MARK: Successes

    func testPrepTieForInsertNote() {
        measure.append(Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave1)))
        assertNoErrorThrown {
            try measure.startTie(at: 1, inSet: 0)
            let note = Note(noteDuration: .quarter, tone: Tone(noteLetter: .a, octave: .octave1))
            try measure.insert(note, at: 1, inSet: 0)

            let note1 = try measure.note(at: 1, inSet: 0)
            let note2 = try measure.note(at: 2, inSet: 0)
            let note3 = try measure.note(at: 3, inSet: 0)

            XCTAssertNil(note1.tie)
            XCTAssertNotNil(note2.tie)
            XCTAssert(note2.tie == .begin)
            XCTAssertNotNil(note3.tie)
            XCTAssert(note3.tie == .end)
        }
    }

    // MARK: - startTie(at:)
    // MARK: Successes

    func testStartTieNoNextNote() {
        measure.append(Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave1)))
        // Only change note to .begin
        assertNoErrorThrown {
            try measure.startTie(at: 0, inSet: 0)
            let note = measure.notes[0][0] as! Note
            XCTAssertNotNil(note.tie)
            XCTAssert(note.tie == .begin)
        }
    }

    func testStartTieHasNextNote() {
        measure.append(Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        assertNoErrorThrown {
            try measure.startTie(at: 0, inSet: 0)
            let note1 = measure.notes[0][0] as! Note
            let note2 = measure.notes[0][1] as! Note
            XCTAssertNotNil(note1.tie)
            XCTAssert(note1.tie == .begin)
            XCTAssertNotNil(note2.tie)
            XCTAssert(note2.tie == .end)
        }
    }

    func testStartTieNoteAlreadyBeginningOfTie() {
        measure.append(Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        assertNoErrorThrown {
            try measure.startTie(at: 0, inSet: 0)
            try measure.startTie(at: 0, inSet: 0)
            let note1 = measure.notes[0][0] as! Note
            let note2 = measure.notes[0][1] as! Note
            XCTAssert(note1.tie == .begin)
            XCTAssert(note2.tie == .end)
        }
    }

    func testStartTieNextNoteInTuplet() {
        measure.append(Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        let notes = [
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1))
        ]
        assertNoErrorThrown {
            // setup
            let tuplet = try Tuplet(3, .eighth, notes: notes)
            measure.append(tuplet)

            // test
            try measure.startTie(at: 2, inSet: 0)
            let note1 = measure.notes[0][2] as! Note
            let tuplet2 = measure.notes[0][3] as! Tuplet
            XCTAssert(note1.tie == .begin)
            XCTAssert(try tuplet2.note(at: 0).tie == .end)
        }
    }

    func testStartTieLastNoteOfTupletNoNextNote() {
        // Just change to .begin
        measure.append(Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        let notes = [
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1))
        ]
        assertNoErrorThrown {
            // setup
            let tupletSetup = try Tuplet(3, .eighth, notes: notes)
            measure.append(tupletSetup)

            // test
            try measure.startTie(at: 2, inSet: 0)
            try measure.startTie(at: 5, inSet: 0)
            let tuplet = measure.notes[0][3] as! Tuplet
            XCTAssert(try tuplet.note(at: 2).tie == .begin)
        }
    }

    func testStartTieNoteIsEndOfAnotherTie() {
        measure.append(Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        let notes = [
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1))
        ]
        assertNoErrorThrown {
            // setup
            let tupletSetup = try Tuplet(3, .eighth, notes: notes)
            measure.append(tupletSetup)
            try measure.startTie(at: 2, inSet: 0)

            // test
            try measure.startTie(at: 3, inSet: 0)
            let tuplet = measure.notes[0][3] as! Tuplet
            XCTAssert(try tuplet.note(at: 0).tie == .beginAndEnd)
            XCTAssert(try tuplet.note(at: 1).tie == .end)
        }
    }

    func testStartTieLastNoteOfTupletHasNextNote() {
        measure.append(Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        let notes = [
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1))
        ]
        assertNoErrorThrown {
            // setup
            let tupletSetup = try Tuplet(3, .eighth, notes: notes)
            measure.append(tupletSetup)
            try measure.startTie(at: 2, inSet: 0)

            // test
            try measure.startTie(at: 5, inSet: 0)
            let tuplet = measure.notes[0][3] as! Tuplet
            XCTAssert(try tuplet.note(at: 2).tie == .begin)
        }
    }

    func testStartTieLastNoteOfTupletNextNoteTuplet() {
        assertNoErrorThrown {
            let note = Note(noteDuration: .sixteenth,
                            tone: Tone(noteLetter: .c, octave: .octave1))
            let tuplet1 = try Tuplet(3, .sixteenth, notes: [note, note, note])
            let tuplet2 = try Tuplet(5, .sixteenth, notes: [note, note, note, note, note])
            measure.append(tuplet1)
            measure.append(tuplet2)
            try measure.startTie(at: 2, inSet: 0)
            let note1 = noteFromMeasure(measure, noteIndex: 0, tupletIndex: 2)
            let note2 = noteFromMeasure(measure, noteIndex: 1, tupletIndex: 0)
            XCTAssert(note1.tie == .begin)
            XCTAssert(note2.tie == .end)
        }
    }

    func testStartTieInNestedTuplet() {
        assertNoErrorThrown {
            let note = Note(noteDuration: .eighth,
                            tone: Tone(noteLetter: .c, octave: .octave1))
            let triplet = try Tuplet(3, .eighth, notes: [note, note, note])
            let tuplet = try Tuplet(3, .eighth, notes: [triplet, note])
            measure.append(tuplet)
            measure.append(note)
            try measure.startTie(at: 3, inSet: 0)
            let note1 = try measure.note(at: 3)
            let note2 = try measure.note(at: 4)
            XCTAssert(note1.tie == .begin)
            XCTAssert(note2.tie == .end)
        }
    }

    // MARK: - startTie(at:)
    // MARK: Failures

    func testStartTieNoteHasDiffTone() {
        measure.append(Note(noteDuration: .quarter, tone: Tone(noteLetter: .a, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        assertThrowsError(MeasureError.notesMustHaveSameTonesToTie) {
            try measure.startTie(at: 0, inSet: 0)
        }
    }

    func testStartTieNextNoteInTupletDiffTone() {
        measure.append(Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        let notes = [
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1)),
            Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave1))
        ]
        assertThrowsError(MeasureError.notesMustHaveSameTonesToTie) {
            let tuplet = try Tuplet(3, .eighth, notes: notes)
            measure.append(tuplet)
            try measure.startTie(at: 2, inSet: 0)
        }
    }

    // MARK: - removeTie(at:)
    // MARK: Failures

    func testRemoveTieNoNoteAtIndex() {
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))

        assertThrowsError(MeasureError.noteIndexOutOfRange) {
            try measure.removeTie(at: 4, inSet: 0)
        }
    }

    // MARK: Successes

    func testRemoveTieNoTie() {
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))

        assertNoErrorThrown {
            try measure.removeTie(at: 0, inSet: 0)
            let firstNote = noteFromMeasure(measure, noteIndex: 0, tupletIndex: nil)
            let secondNote = noteFromMeasure(measure, noteIndex: 1, tupletIndex: nil)
            XCTAssertNil(firstNote.tie)
            XCTAssertNil(secondNote.tie)
        }
    }

    func testRemoveTieBeginOfTie() {
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))

        assertNoErrorThrown {
            setTie(at: 0)
            try measure.removeTie(at: 0, inSet: 0)
            let firstNote = noteFromMeasure(measure, noteIndex: 0, tupletIndex: nil)
            let secondNote = noteFromMeasure(measure, noteIndex: 1, tupletIndex: nil)
            XCTAssertNil(firstNote.tie)
            XCTAssertNil(secondNote.tie)
        }
    }

    func testRemoveTieFromBeginAndEnd() {
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))

        assertNoErrorThrown {
            setTie(at: 0)
            setTie(at: 1)
            try measure.removeTie(at: 1, inSet: 0)
            let firstNote = noteFromMeasure(measure, noteIndex: 1, tupletIndex: nil)
            let secondNote = noteFromMeasure(measure, noteIndex: 2, tupletIndex: nil)
            XCTAssert(firstNote.tie == .end)
            XCTAssertNil(secondNote.tie)
        }
    }

    func testRemoveTieBeginsInTuplet() {
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))

        let note = Note(noteDuration: .sixteenth,
                        tone: Tone(noteLetter: .c, octave: .octave1))
        assertNoErrorThrown {
            let tuplet = try Tuplet(3, .sixteenth, notes: [note, note, note])
            measure.append(tuplet)
            measure.append(note)
        }

        assertNoErrorThrown {
            setTie(at: 6)
            try measure.removeTie(at: 6, inSet: 0)
            let firstNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 2)
            let secondNote = noteFromMeasure(measure, noteIndex: 5, tupletIndex: nil)
            XCTAssertNil(firstNote.tie)
            XCTAssertNil(secondNote.tie)
        }
    }

    func testRemoveTieBeginAndEndInOneTuplet() {
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))

        let note = Note(noteDuration: .sixteenth, tone: Tone(noteLetter: .c, octave: .octave1))
        assertNoErrorThrown {
            let tuplet = try Tuplet(3, .sixteenth, notes: [note, note, note])
            measure.append(tuplet)
            measure.append(note)
        }

        assertNoErrorThrown {
            setTie(at: 5)
            try measure.removeTie(at: 5, inSet: 0)
            let firstNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 1)
            let secondNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 2)
            XCTAssertNil(firstNote.tie)
            XCTAssertNil(secondNote.tie)
        }
    }

    func testRemoveTieEndsInTuplet() {
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))

        let note = Note(noteDuration: .sixteenth, tone: Tone(noteLetter: .c, octave: .octave1))
        assertNoErrorThrown {
            let tuplet = try Tuplet(3, .sixteenth, notes: [note, note, note])
            measure.append(tuplet)
            measure.append(note)
        }

        assertNoErrorThrown {
            setTie(at: 4)
            try measure.removeTie(at: 4, inSet: 0)
            let firstNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 0)
            let secondNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 1)
            XCTAssertNil(firstNote.tie)
            XCTAssertNil(secondNote.tie)
        }
    }

    func testRemoveTieTupletToOtherTuplet() {
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))
        measure.append(Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1)))

        let note = Note(noteDuration: .sixteenth, tone: Tone(noteLetter: .c, octave: .octave1))
        assertNoErrorThrown {
            let tuplet = try Tuplet(3, .sixteenth, notes: [note, note, note])
            measure.append(tuplet)
            measure.append(note)
        }

        assertNoErrorThrown {
            let tuplet1 = try Tuplet(5, .sixteenth, notes: [note, note, note, note, note])
            let tuplet2 = try Tuplet(3, .sixteenth, notes: [note, note, note])
            measure.append(tuplet1)
            measure.append(tuplet2)
            setTie(at: 11)
            try measure.removeTie(at: 11, inSet: 0)
            let firstNote = noteFromMeasure(measure, noteIndex: 6, tupletIndex: 3)
            let secondNote = noteFromMeasure(measure, noteIndex: 7, tupletIndex: 0)
            XCTAssertNil(firstNote.tie)
            XCTAssertNil(secondNote.tie)
        }
    }

    // MARK: - noteCollectionIndexFromNoteIndex(_:)
    // MARK: Successes

    func testNoteCollectionIndexFromNoteIndexNoTuplets() {
        // NoteIndex should be the same if there are no tuplets
        measure.append(Note(noteDuration: .quarter))
        measure.append(Note(noteDuration: .quarter))
        measure.append(Note(noteDuration: .quarter))

        assertNoErrorThrown {
            let index = try measure.noteCollectionIndex(fromNoteIndex: 2, inSet: 0)
            XCTAssertEqual(index.noteIndex, 2)
            XCTAssertNil(index.tupletIndex)
        }
    }

    func testNoteCollectionIndexFromNoteIndexWithinTuplet() {
        // NoteIndex should be the beginning of the tuplet if the index specified
        // is within the tuplet, and tupletIndex should be the index of the note
        // within the tuplet
        measure.append(Note(noteDuration: .quarter))
        assertNoErrorThrown {
            let note1 = Note(noteDuration: .eighth,
                             tone: Tone(noteLetter: .a, octave: .octave1))
            let note2 = Note(noteDuration: .eighth,
                             tone: Tone(noteLetter: .b, octave: .octave1))
            let note3 = Note(noteDuration: .eighth,
                             tone: Tone(noteLetter: .c, octave: .octave1))
            measure.append(try Tuplet(3, .eighth, notes: [note1, note2, note3]))
            let index = try measure.noteCollectionIndex(fromNoteIndex: 2, inSet: 0)
            XCTAssertEqual(index.noteIndex, 1)
            XCTAssertNotNil(index.tupletIndex)
            XCTAssertEqual(index.tupletIndex!, 1)

            // Properly address regular note coming after a tuplet
            measure.append(Note(noteDuration: .eighth))
            let index2 = try measure.noteCollectionIndex(fromNoteIndex: 4, inSet: 0)
            XCTAssertEqual(index2.noteIndex, 2)
            XCTAssertNil(index2.tupletIndex)
        }
    }

    private func setTie(at index: Int, functionName: String = #function, lineNum: Int = #line) {
        assertNoErrorThrown {
            try measure.startTie(at: index, inSet: 0)
            let (noteIndex1, tupletIndex1) = try measure.noteCollectionIndex(fromNoteIndex: index, inSet: 0)
            let (noteIndex2, tupletIndex2) = try measure.noteCollectionIndex(fromNoteIndex: index + 1, inSet: 0)
            let firstNote = noteFromMeasure(measure, noteIndex: noteIndex1,
                                            tupletIndex: tupletIndex1)
            let secondNote = noteFromMeasure(measure, noteIndex: noteIndex2,
                                             tupletIndex: tupletIndex2)
            XCTAssert(firstNote.tie == .begin || firstNote.tie == .beginAndEnd,
                      "\(functionName): \(lineNum)")
            XCTAssert(secondNote.tie == .end || secondNote.tie == .beginAndEnd,
                      "\(functionName): \(lineNum)")
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
