//
//  MeasureDurationValidatorTests.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 8/6/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

import XCTest
@testable import MusicNotationKit

class MeasureDurationValidatorTests: XCTestCase {

    static let standardTimeSignature = TimeSignature(topNumber: 4, bottomNumber: 4, tempo: 120)
    static let oddTimeSignature = TimeSignature(topNumber: 11, bottomNumber: 16, tempo: 86)

    var fullMeasure: Measure!
    var notFullMeasure: Measure!
    var notFullMeasureDotted: Measure!
    var overfilledMeasure: Measure!
    // A measure where the overfill contains a dot, so really the dot part is the part that is overfilling it
    var overfilledWithDotMeasure: Measure!
    // A measure where if you remove the overfilled note, it is not full anymore
    var overfilledWithTooLargeMeasure: Measure!
    let emptyMeasure = Measure(timeSignature: standardTimeSignature, key: Key(noteLetter: .c))

    var fullMeasureOddTimeSignature: Measure!
    var notFullMeasureOddTimeSignature: Measure!
    var overfilledMeasureOddTimeSignature: Measure!

    override func setUp() {
        super.setUp()
        // Create measures in valid in each state
        let key = Key(noteLetter: .c)
        var staff = Staff(clef: .treble, instrument: .guitar6)
        let dotted16: Note = {
            var note = Note(noteDuration: .sixteenth, tone: Tone(noteLetter: .c, octave: .octave0))
            note.dot = .single
            return note
        }()
        let doubleDottedEighth: Note = {
            var note = Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave0))
            note.dot = .double
            return note
        }()
        let quarter = Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave0))
        let thirtySecond = Note(noteDuration: .thirtySecond, tone: Tone(noteLetter: .c, octave: .octave0))
        let halfRest = Note(noteDuration: .half)

        fullMeasure = Measure(
            timeSignature: MeasureDurationValidatorTests.standardTimeSignature,
            key: key,
            notes: [quarter, quarter, thirtySecond, thirtySecond, thirtySecond, thirtySecond, quarter, dotted16,
                    thirtySecond]
        )
        // Missing 1 3/4 beats
        notFullMeasure = Measure(
            timeSignature: MeasureDurationValidatorTests.standardTimeSignature,
            key: key,
            notes: [quarter, quarter, thirtySecond, thirtySecond]
        )
        // Missing 1 1/8 beats
        notFullMeasureDotted = Measure(
            timeSignature: MeasureDurationValidatorTests.standardTimeSignature,
            key: key,
            notes: [halfRest, doubleDottedEighth]
        )
        // Overfilled by the last 2 quarter notes. Full if they aren't there
        overfilledMeasure = Measure(
            timeSignature: MeasureDurationValidatorTests.standardTimeSignature,
            key: key,
            notes: [halfRest, quarter, dotted16, thirtySecond, thirtySecond, thirtySecond, thirtySecond, thirtySecond,
                    quarter, quarter]
        )
        // The last sixteenth fills the measure, but the dot puts it over the edge
        overfilledWithDotMeasure = Measure(
            timeSignature: MeasureDurationValidatorTests.standardTimeSignature,
            key: key,
            notes: [halfRest, quarter, thirtySecond, thirtySecond, thirtySecond, thirtySecond, thirtySecond,
                    thirtySecond, dotted16]
        )
        // Quarter is too much, but when removed, the measure is not full
        overfilledWithTooLargeMeasure = Measure(
            timeSignature: MeasureDurationValidatorTests.standardTimeSignature,
            key: key,
            notes: [quarter, quarter, quarter, doubleDottedEighth, quarter]
        )
        fullMeasureOddTimeSignature = Measure(
            timeSignature: MeasureDurationValidatorTests.oddTimeSignature,
            key: key,
            notes: [dotted16, thirtySecond, quarter, quarter, thirtySecond, thirtySecond]
        )
        // Missing a quarter note (4 beats)
        notFullMeasureOddTimeSignature = Measure(
            timeSignature: MeasureDurationValidatorTests.oddTimeSignature,
            key: key,
            notes: [dotted16, thirtySecond, quarter, thirtySecond, thirtySecond]
        )
        // Overfilled by the half rest. Full if removed
        overfilledMeasureOddTimeSignature = Measure(
            timeSignature: MeasureDurationValidatorTests.oddTimeSignature,
            key: key,
            notes: [dotted16, thirtySecond, quarter, thirtySecond, thirtySecond, quarter, halfRest]
        )
        // Add all to staff
        staff.appendMeasure(fullMeasure)
        staff.appendMeasure(notFullMeasure)
        staff.appendMeasure(notFullMeasureDotted)
        staff.appendMeasure(overfilledMeasure)
        staff.appendMeasure(overfilledWithDotMeasure)
        staff.appendMeasure(overfilledWithTooLargeMeasure)
        staff.appendMeasure(emptyMeasure)
        staff.appendMeasure(fullMeasureOddTimeSignature)
        staff.appendMeasure(notFullMeasureOddTimeSignature)
        staff.appendMeasure(overfilledMeasureOddTimeSignature)
    }

    // MARK: - completionState(of:)

    func testCompletionStateForEmpty() {

    }

    func testCompletionStateForNotFull() {

    }

    func testCompletionStateForFull() {

    }

    func testCompletionStateForOverfilled() {

    }

    // MARK: - number(of:fittingIn:)

    func testNumberOfFittingInForFull() {

    }

    func testNumberOfFittingInForEmpty() {

    }

    func testNumberOfFittingInForOddTimeSignature() {

    }

    func testNumberOfFittingInForOverfilled() {

    }

    // MARK: - overflowingNotes(for:)

    func testOverflowingNotesForEmpty() {

    }

    func testOverflowingNotesForJustFull() {

    }

    func testOverflowingNotesForOneExtra() {

    }

    func testOverFlowingNotesForMultipleExtra() {

    }

    func testOverFlowingNotesForMultipleExtraOddTimeSignature() {

    }

    // MARK: - availableNotes(for:)

    func testAvailableNotesForFull() {

    }

    func testAvailableNotesForEmpty() {

    }

    func testAvailableNotesForOverfilled() {

    }

    func testAvailableNotesForOddTimeSignature() {

    }
}
