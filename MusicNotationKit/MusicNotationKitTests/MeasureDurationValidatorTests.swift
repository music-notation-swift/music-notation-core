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
    // MARK: .full

    func testCompletionStateFull() {
        XCTAssertEqual(
            MeasureDurationValidator.completionState(of: fullMeasure),
            MeasureDurationValidator.CompletionState.full
        )
        XCTAssertEqual(
            MeasureDurationValidator.completionState(of: fullMeasureOddTimeSignature),
            MeasureDurationValidator.CompletionState.full
        )
    }

    // MARK: .notFull

    func testCompletionStateNotFullForEmpty() {
        XCTAssertEqual(
            MeasureDurationValidator.completionState(of: emptyMeasure),
            MeasureDurationValidator.CompletionState.notFull(availableNotes: [.whole: 1])
        )
    }

    func testCompletionStateNotFullForStandard() {
        XCTAssertEqual(
            MeasureDurationValidator.completionState(of: notFullMeasure),
            MeasureDurationValidator.CompletionState.notFull(availableNotes: [.quarter: 1, .eighth: 1, .sixteenth: 1])
        )
    }

    func testCompletionStateNotFullForDotted() {
        XCTAssertEqual(
            MeasureDurationValidator.completionState(of: notFullMeasure),
            MeasureDurationValidator.CompletionState.notFull(availableNotes: [.quarter: 1, .thirtySecond: 1])
        )
    }

    func testCompletionStateNotFullForOddTimeSignature() {
        XCTAssertEqual(
            MeasureDurationValidator.completionState(of: notFullMeasureOddTimeSignature),
            MeasureDurationValidator.CompletionState.notFull(availableNotes: [.quarter: 1])
        )
    }

    // MARK: .overfilled

    func testCompletionStateOverfilledForOneExtra() {
        XCTAssertEqual(
            MeasureDurationValidator.completionState(of: overfilledWithTooLargeMeasure),
            MeasureDurationValidator.CompletionState.overfilled(overflowingNotes: Range(4...4))
        )
    }

    func testCompletionStateOverfilledForMultipleExtra() {
        XCTAssertEqual(
            MeasureDurationValidator.completionState(of: overfilledMeasure),
            MeasureDurationValidator.CompletionState.overfilled(overflowingNotes: Range(8...9))
        )
    }

    func testCompletionStateOverfilledForSingleExtraOddTimeSignature() {
        XCTAssertEqual(
            MeasureDurationValidator.completionState(of: overfilledMeasureOddTimeSignature),
            MeasureDurationValidator.CompletionState.overfilled(overflowingNotes: Range(6...6))
        )
    }

    func testCompletionStateOverfilledTooFullBecauseOfDot() {
        XCTAssertEqual(
            MeasureDurationValidator.completionState(of: overfilledWithDotMeasure),
            MeasureDurationValidator.CompletionState.overfilled(overflowingNotes: Range(8...8))
        )
    }

    // MARK: - number(of:fittingIn:)

    func testNumberOfFittingInForFull() {
        XCTAssertEqual(MeasureDurationValidator.number(of: .whole, fittingIn: fullMeasure), 0)
        XCTAssertEqual(MeasureDurationValidator.number(of: .half, fittingIn: fullMeasure), 0)
        XCTAssertEqual(MeasureDurationValidator.number(of: .quarter, fittingIn: fullMeasure), 0)
        XCTAssertEqual(MeasureDurationValidator.number(of: .eighth, fittingIn: fullMeasureOddTimeSignature), 0)
        XCTAssertEqual(MeasureDurationValidator.number(of: .sixteenth, fittingIn: fullMeasure), 0)
        XCTAssertEqual(MeasureDurationValidator.number(of: .thirtySecond, fittingIn: fullMeasure), 0)
        XCTAssertEqual(MeasureDurationValidator.number(of: .sixtyFourth, fittingIn: fullMeasure), 0)
    }

    func testNumberOfFittingInForEmptyStandardTimeSignature() {
        XCTAssertEqual(MeasureDurationValidator.number(of: .whole, fittingIn: fullMeasure), 1)
        XCTAssertEqual(MeasureDurationValidator.number(of: .half, fittingIn: emptyMeasure), 2)
        XCTAssertEqual(MeasureDurationValidator.number(of: .quarter, fittingIn: emptyMeasure), 4)
        XCTAssertEqual(MeasureDurationValidator.number(of: .eighth, fittingIn: fullMeasure), 8)
        XCTAssertEqual(MeasureDurationValidator.number(of: .sixteenth, fittingIn: fullMeasure), 16)
        XCTAssertEqual(MeasureDurationValidator.number(of: .thirtySecond, fittingIn: fullMeasure), 32)
        XCTAssertEqual(MeasureDurationValidator.number(of: .sixtyFourth, fittingIn: fullMeasure), 64)
    }

    func testNumberOfFittingInForStandardTimeSignature() {
        // 1 3/4 beats missing
        XCTAssertEqual(MeasureDurationValidator.number(of: .whole, fittingIn: notFullMeasure), 0)
        XCTAssertEqual(MeasureDurationValidator.number(of: .half, fittingIn: notFullMeasure), 0)
        XCTAssertEqual(MeasureDurationValidator.number(of: .quarter, fittingIn: notFullMeasure), 1)
        XCTAssertEqual(MeasureDurationValidator.number(of: .eighth, fittingIn: notFullMeasure), 3)
        XCTAssertEqual(MeasureDurationValidator.number(of: .sixteenth, fittingIn: notFullMeasure), 7)
        XCTAssertEqual(MeasureDurationValidator.number(of: .thirtySecond, fittingIn: notFullMeasure), 14)
        XCTAssertEqual(MeasureDurationValidator.number(of: .sixtyFourth, fittingIn: notFullMeasure), 28)

        // 1 1/8 beats missing
        XCTAssertEqual(MeasureDurationValidator.number(of: .whole, fittingIn: notFullMeasureDotted), 0)
        XCTAssertEqual(MeasureDurationValidator.number(of: .half, fittingIn: notFullMeasureDotted), 0)
        XCTAssertEqual(MeasureDurationValidator.number(of: .quarter, fittingIn: notFullMeasureDotted), 1)
        XCTAssertEqual(MeasureDurationValidator.number(of: .eighth, fittingIn: notFullMeasureDotted), 2)
        XCTAssertEqual(MeasureDurationValidator.number(of: .sixteenth, fittingIn: notFullMeasureDotted), 4)
        XCTAssertEqual(MeasureDurationValidator.number(of: .thirtySecond, fittingIn: notFullMeasureDotted), 9)
        XCTAssertEqual(MeasureDurationValidator.number(of: .sixtyFourth, fittingIn: notFullMeasureDotted), 18)
    }

    func testNumberOfFittingInForOddTimeSignature() {
        // 4 beats missing - 1 quarter note
        XCTAssertEqual(MeasureDurationValidator.number(of: .whole, fittingIn: notFullMeasureOddTimeSignature), 0)
        XCTAssertEqual(MeasureDurationValidator.number(of: .half, fittingIn: notFullMeasureOddTimeSignature), 0)
        XCTAssertEqual(MeasureDurationValidator.number(of: .quarter, fittingIn: notFullMeasureOddTimeSignature), 1)
        XCTAssertEqual(MeasureDurationValidator.number(of: .eighth, fittingIn: notFullMeasureOddTimeSignature), 2)
        XCTAssertEqual(MeasureDurationValidator.number(of: .sixteenth, fittingIn: notFullMeasureOddTimeSignature), 4)
        XCTAssertEqual(MeasureDurationValidator.number(of: .thirtySecond, fittingIn: notFullMeasureOddTimeSignature), 8)
        XCTAssertEqual(MeasureDurationValidator.number(of: .sixtyFourth, fittingIn: notFullMeasureOddTimeSignature), 16)
    }

    func testNumberOfFittingInForOverfilled() {
        XCTAssertEqual(MeasureDurationValidator.number(of: .whole, fittingIn: overfilledMeasure), 0)
        XCTAssertEqual(MeasureDurationValidator.number(of: .half, fittingIn: overfilledMeasure), 0)
        XCTAssertEqual(MeasureDurationValidator.number(of: .quarter, fittingIn: overfilledMeasure), 0)
        XCTAssertEqual(MeasureDurationValidator.number(of: .eighth, fittingIn: overfilledMeasure), 0)
        XCTAssertEqual(MeasureDurationValidator.number(of: .sixteenth, fittingIn: overfilledMeasure), 0)
        XCTAssertEqual(MeasureDurationValidator.number(of: .thirtySecond, fittingIn: overfilledMeasure), 0)
        XCTAssertEqual(MeasureDurationValidator.number(of: .sixtyFourth, fittingIn: overfilledMeasure), 0)
    }
}
