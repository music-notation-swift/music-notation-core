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
    // MARK: Failures

    func testInitFailInvalidLineNumber() {
        assertThrowsError(ClefError.invalidLineNumber) {
            _ = try Clef(tone: Tone(noteLetter: .c, octave: .octave3), lineNumber: 1.25)
        }
    }

    // MARK: Successes

    func testInitForCustomOnLine() {
        assertNoErrorThrown {
            _ = try Clef(tone: Tone(noteLetter: .c, octave: .octave4), lineNumber: 2.0)
        }
    }

    func testInitForCustomOnSpace() {
        assertNoErrorThrown {
            _ = try Clef(tone: Tone(noteLetter: .g, octave: .octave4), lineNumber: 3.5)
        }
    }

    func testInitForCustomNegativeLedger() {
        assertNoErrorThrown {
            _ = try Clef(tone: Tone(noteLetter: .g, octave: .octave3), lineNumber: -1)
        }
    }

    func testInitForCustomPositiveLedger() {
        assertNoErrorThrown {
            _ = try Clef(tone: Tone(noteLetter: .a, octave: .octave4), lineNumber: 7)
        }
    }

    // MARK: - ==
    // MARK: Failures

    func testEqualityFailStandard() {
        XCTAssertFalse(Clef.treble == Clef.bass)
    }

    func testEqualityFailDifferentTone() {
        assertNoErrorThrown {
            let custom1 = try Clef(tone: Tone(noteLetter: .a, octave: .octave3), lineNumber: 1.0)
            let custom2 = try Clef(tone: Tone(noteLetter: .a, octave: .octave2), lineNumber: 1.0)
            XCTAssertFalse(custom1 == custom2)
        }
    }

    func testEqualityFailDifferentLineNumber() {
        assertNoErrorThrown {
            let custom1 = try Clef(tone: Tone(noteLetter: .a, octave: .octave2), lineNumber: 1.0)
            let custom2 = try Clef(tone: Tone(noteLetter: .a, octave: .octave2), lineNumber: 2.0)
            XCTAssertFalse(custom1 == custom2)
        }
    }

    // MARK: Successes

    func testEqualityStandard() {
        XCTAssertTrue(Clef.treble == Clef.treble)
    }

    func testEqualityCustom() {
        assertNoErrorThrown {
            let custom1 = try Clef(tone: Tone(noteLetter: .a, octave: .octave2), lineNumber: 1.0)
            let custom2 = try Clef(tone: Tone(noteLetter: .a, octave: .octave2), lineNumber: 1.0)
            XCTAssertTrue(custom1 == custom2)
        }
    }

    func testEqualityCustomWithStandard() {
        assertNoErrorThrown {
            let treble = try Clef(tone: Tone(noteLetter: .g, octave: .octave4), lineNumber: 3)
            XCTAssertTrue(treble == Clef.treble)
        }
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
        assertNoErrorThrown {
            let custom = try Clef(tone: Tone(noteLetter: .a, octave: .octave3), lineNumber: 2.0)
            XCTAssertEqual(custom.debugDescription, "a3@2.0")
        }
    }
}
