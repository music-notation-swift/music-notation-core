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

    let tone1 = Tone(accidental: .none, noteLetter: .a, octave: .octave1)
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

    func testInitFailsIfHasRest() {
        assertThrowsError(TupletError.restsNotValid) {
            _ = try Tuplet(notes: [quarterNote1, quarterRest])
        }
    }

    func testInitFailsIfTooManyNotes() {
        assertThrowsError(TupletError.invalidNumberOfNotes) {
            _ = try Tuplet(notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2])
        }
    }

    func testInitFailsIfTooFewNotes1() {
        assertThrowsError(TupletError.invalidNumberOfNotes) {
            _ = try Tuplet(notes: [quarterNote1])
        }
    }

    func testInitFailsIfTooFewNotes0() {
        assertThrowsError(TupletError.invalidNumberOfNotes) {
            _ = try Tuplet(notes: [])
        }
    }

    func testInitFailsIfNonUniformDuration() {
        assertThrowsError(TupletError.notSameDuration) {
            _ = try Tuplet(notes: [quarterNote1, quarterNote2, quarterNote3, eighthNote])
        }
    }

    // MARK: Successes

    func testInitSuccessForAllCombinations() {
        assertNoErrorThrown {
            // Test 2 - 7
            let _ = try Tuplet(notes: [quarterNote1, quarterNote2])
            let _ = try Tuplet(notes: [quarterNote1, quarterNote2, quarterNote3])
            let _ = try Tuplet(notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1])
            let _ = try Tuplet(notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2])
            let _ = try Tuplet(notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3])
            let _ = try Tuplet(notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3, quarterNote1])
            // Test with a chord
            let _ = try Tuplet(notes: [quarterNote1, quarterChord])
        }
    }

    // MARK: - appendNote(_:)
    // MARK: Failures

    func testAppendNoteFailsIfTupletFull() {
        assertThrowsError(TupletError.groupingFull) {
            var noteGroup = try Tuplet(notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3, quarterNote1])
            try noteGroup.appendNote(quarterNote3)
        }
    }

    func testAppendNoteFailsIfRest() {
        assertThrowsError(TupletError.restsNotValid) {
            var noteGroup = try Tuplet(notes: [quarterNote1, quarterNote2])
            try noteGroup.appendNote(quarterRest)
        }
    }

    func testAppendNoteFailsIfInvalidDuration() {
        assertThrowsError(TupletError.notSameDuration) {
            var noteGroup = try Tuplet(notes: [quarterNote1, quarterNote2])
            try noteGroup.appendNote(eighthNote)
        }
    }

    // MARK: Successes

    func testAppendNoteSuccess() {
        assertNoErrorThrown {
            // Test 2 - 7
            var group2 = try Tuplet(notes: [quarterNote1, quarterNote2])
            try group2.appendNote(quarterNote1)
            var group3 = try Tuplet(notes: [quarterNote1, quarterNote2, quarterNote3])
            try group3.appendNote(quarterNote1)
            var group4 = try Tuplet(notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1])
            try group4.appendNote(quarterNote1)
            var group5 = try Tuplet(notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2])
            try group5.appendNote(quarterNote1)
            var group6 = try Tuplet(notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3])
            try group6.appendNote(quarterNote1)
            // Test with a chord
            var group7 = try Tuplet(notes: [quarterNote1, quarterChord])
            try group7.appendNote(quarterNote1)
            // Test appending chord
            try group2.appendNote(quarterChord)
        }
    }
}
