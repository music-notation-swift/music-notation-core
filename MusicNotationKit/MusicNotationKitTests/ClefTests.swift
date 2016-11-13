//
//  ClefTests.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 10/16/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

import XCTest
@testable import MusicNotationKit

class ClefTests: XCTestCase {

    // MARK: - init(tone:lineNumber)
    // MARK: Successes

    func testInitForCustomOnLine() {
        let clef = Clef(
            tone: Tone(noteLetter: .c, octave: .octave4),
            location: StaffLocation(type: .line, number: 0))
        XCTAssertEqual(clef.staffLocation.halfSteps, 0)
    }

    func testInitForCustomOnSpace() {
        let clef = Clef(
            tone: Tone(noteLetter: .g, octave: .octave4),
            location: StaffLocation(type: .space, number: 1))
        XCTAssertEqual(clef.staffLocation.halfSteps, 3)
    }

    func testInitForCustomNegativeLedger() {
        let clef = Clef(
            tone: Tone(noteLetter: .g, octave: .octave3),
            location: StaffLocation(type: .line, number: -2))
        XCTAssertEqual(clef.staffLocation.halfSteps, -4)
    }

    func testInitForCustomPositiveLedger() {
        let clef = Clef(
            tone: Tone(noteLetter: .a, octave: .octave4),
            location: StaffLocation(type: .line, number: 7))
        XCTAssertEqual(clef.staffLocation.halfSteps, 14)
    }

    // MARK: - tone(at:)
    // MARK: Failures

    func testToneAtOctaveOutOfRange() {
        assertThrowsError(ClefError.octaveOutOfRange) {
            _ = try Clef.treble.tone(at: StaffLocation(type: .space, number: 300))
        }

        assertThrowsError(ClefError.octaveOutOfRange) {
            _ = try Clef.treble.tone(at: StaffLocation(type: .line, number: 300))
        }

        assertThrowsError(ClefError.octaveOutOfRange) {
            _ = try Clef.treble.tone(at: StaffLocation(type: .space, number: -300))
        }

        assertThrowsError(ClefError.octaveOutOfRange) {
            _ = try Clef.treble.tone(at: StaffLocation(type: .line, number: -300))
        }
    }

    // MARK: Successes

    func testToneAtUnpitched() {
        assertNoErrorThrown {
            XCTAssertNil(try Clef.neutral.tone(at: StaffLocation(type: .space, number: 1)))
            XCTAssertNil(try Clef.tab.tone(at: StaffLocation(type: .space, number: 1)))
        }
    }

    func testToneAtLocationWithinStaffIncrease() {
        assertNoErrorThrown {
            XCTAssertEqual(try Clef.treble.tone(at: StaffLocation(type: .space, number: 2)),
                           Tone(noteLetter: .c, octave: .octave5))
            XCTAssertEqual(try Clef.treble.tone(at: StaffLocation(type: .line, number: 2)),
                           Tone(noteLetter: .b, octave: .octave4))
            XCTAssertEqual(try Clef.bass.tone(at: StaffLocation(type: .space, number: 3)),
                           Tone(noteLetter: .g, octave: .octave3))
        }
    }

    func testToneAtLocationDecrease() {
        assertNoErrorThrown {
            XCTAssertEqual(try Clef.treble.tone(at: StaffLocation(type: .line, number: 0)),
                           Tone(noteLetter: .e, octave: .octave4))
            XCTAssertEqual(try Clef.treble.tone(at: StaffLocation(type: .space, number: -1)),
                           Tone(noteLetter: .d, octave: .octave4))
            XCTAssertEqual(try Clef.alto.tone(at: StaffLocation(type: .line, number: -3)),
                           Tone(noteLetter: .g, octave: .octave2))
            XCTAssertEqual(try Clef.alto.tone(at: StaffLocation(type: .line, number: -2)),
                           Tone(noteLetter: .b, octave: .octave2))
        }
    }

    func testToneAtSameToneAsClef() {

    }

    // MARK: - ==
    // MARK: Failures

    func testEqualityFailStandard() {
        XCTAssertFalse(Clef.treble == Clef.bass)
    }

    func testEqualityFailDifferentTone() {
        let custom1 = Clef(
            tone: Tone(noteLetter: .a, octave: .octave3),
            location: StaffLocation(type: .line, number: 1))
        let custom2 = Clef(
            tone: Tone(noteLetter: .a, octave: .octave2),
            location: StaffLocation(type: .line, number: 1))
        XCTAssertFalse(custom1 == custom2)
    }

    func testEqualityFailDifferentLineNumber() {
        let custom1 = Clef(
            tone: Tone(noteLetter: .a, octave: .octave2),
            location: StaffLocation(type: .space, number: 1))
        let custom2 = Clef(
            tone: Tone(noteLetter: .a, octave: .octave2),
            location: StaffLocation(type: .space, number: 2))
        XCTAssertFalse(custom1 == custom2)
    }

    // MARK: Successes

    func testEqualityStandard() {
        XCTAssertTrue(Clef.treble == Clef.treble)
    }

    func testEqualityCustom() {
        let custom1 = Clef(
            tone: Tone(noteLetter: .a, octave: .octave2),
            location: StaffLocation(type: .line, number: 1))
        let custom2 = Clef(
            tone: Tone(noteLetter: .a, octave: .octave2),
            location: StaffLocation(type: .line, number: 1))
        XCTAssertTrue(custom1 == custom2)
    }

    func testEqualityCustomWithStandard() {
        let treble = Clef(
            tone: Tone(noteLetter: .g, octave: .octave4),
            location: StaffLocation(type: .line, number: 1))
        XCTAssertTrue(treble == Clef.treble)
    }

    // MARK: - debugDescription
    // MARK: Successes

    func testDescriptionStandard() {
        XCTAssertEqual(Clef.treble.debugDescription, "treble")
        XCTAssertEqual(Clef.bass.debugDescription, "bass")
        XCTAssertEqual(Clef.tenor.debugDescription, "tenor")
        XCTAssertEqual(Clef.alto.debugDescription, "alto")
        XCTAssertEqual(Clef.neutral.debugDescription, "neutral")
        XCTAssertEqual(Clef.tab.debugDescription, "neutral")
        XCTAssertEqual(Clef.frenchViolin.debugDescription, "frenchViolin")
        XCTAssertEqual(Clef.soprano.debugDescription, "soprano")
        XCTAssertEqual(Clef.mezzoSoprano.debugDescription, "mezzoSoprano")
        XCTAssertEqual(Clef.baritone.debugDescription, "baritone")
        XCTAssertEqual(Clef.suboctaveTreble.debugDescription, "suboctaveTreble")
    }

    func testDescriptionCustom() {
        let custom = Clef(
            tone: Tone(noteLetter: .a, octave: .octave3),
            location: StaffLocation(type: .line, number: 1))
        XCTAssertEqual(custom.debugDescription, "a3@line1")
    }
}
