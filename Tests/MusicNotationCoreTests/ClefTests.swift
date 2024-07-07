//
//  ClefTests.swift
//  MusicNotationCore
//
//  Created by Kyle Sherman on 10/16/2016.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

@testable import MusicNotationCore
import Testing

@Suite final class ClefTests {
    @Test func initForCustomOnLine() async throws {
        let clef = Clef(pitch: SpelledPitch(.c, .octave4),
                        location: StaffLocation(.line, 0))
        #expect(clef.staffLocation.halfSteps == 0)
    }

    @Test func initForCustomOnSpace() async throws {
        let clef = Clef(pitch: SpelledPitch(.g, .octave4),
                        location: StaffLocation(.space, 1))
        #expect(clef.staffLocation.halfSteps == 3)
    }

    @Test func initForCustomNegativeLedger() async throws {
        let clef = Clef(pitch: SpelledPitch(.g, .octave3),
                        location: StaffLocation(.line, -2))
        #expect(clef.staffLocation.halfSteps == -4)
    }

    @Test func initForCustomPositiveLedger() async throws {
        let clef = Clef(pitch: SpelledPitch(.a, .octave4),
                        location: StaffLocation(.line, 7))
        #expect(clef.staffLocation.halfSteps == 14)
    }

    @Test func pitchAtOctaveOutOfRange() async throws {
        #expect(throws: ClefError.octaveOutOfRange) {
            try Clef.treble.pitch(at: StaffLocation(.space, 300))
        }

        #expect(throws: ClefError.octaveOutOfRange) {
            try Clef.treble.pitch(at: StaffLocation(.line, 300))
        }

        #expect(throws: ClefError.octaveOutOfRange) {
            try Clef.treble.pitch(at: StaffLocation(.space, -300))
        }

        #expect(throws: ClefError.octaveOutOfRange) {
            try Clef.treble.pitch(at: StaffLocation(.line, -300))
        }
    }

    @Test func pitchAtUnpitched() async throws {
        var neutral: SpelledPitch?
        #expect(throws: Never.self) { neutral = try Clef.neutral.pitch(at: StaffLocation(.space, 1)) }
        #expect(neutral == nil)

        var tab: SpelledPitch?
        #expect(throws: Never.self) {
            tab = try Clef.tab.pitch(at: StaffLocation(.space, 1))
        }
        #expect(tab == nil)


    }

    @Test func pitchAtLocationWithinStaffIncrease() async throws {
        #expect(try Clef.treble.pitch(at: StaffLocation(.space, 2)) == SpelledPitch(.c, .octave5))
        #expect(try Clef.treble.pitch(at: StaffLocation(.line, 2)) == SpelledPitch(.b, .octave4))
        #expect(try Clef.bass.pitch(at: StaffLocation(.space, 3)) == SpelledPitch(.g, .octave3))
        #expect(try Clef.alto.pitch(at: StaffLocation(.line, 4)) == SpelledPitch(.g, .octave4))
        #expect(try Clef.soprano.pitch(at: StaffLocation(.space, 3)) == SpelledPitch(.c, .octave5))

        let customBClef = Clef(
            pitch: SpelledPitch(.b, .octave3),
            location: StaffLocation(.line, 2)
        )
        #expect(try customBClef.pitch(at: StaffLocation(.space, 2)) == SpelledPitch(.c, .octave4))
    }

    @Test func pitchAtLocationDecrease() async throws {
        #expect(try Clef.treble.pitch(at: StaffLocation(.line, 0)) == SpelledPitch(.e, .octave4))
        #expect(try Clef.treble.pitch(at: StaffLocation(.space, -1)) == SpelledPitch(.d, .octave4))
        #expect(try Clef.alto.pitch(at: StaffLocation(.line, -3)) == SpelledPitch(.g, .octave2))
        #expect(try Clef.alto.pitch(at: StaffLocation(.line, -2)) == SpelledPitch(.b, .octave2))
        #expect(try Clef.alto.pitch(at: StaffLocation(.space, 1)) == SpelledPitch(.b, .octave3))
        #expect(try Clef.bass.pitch(at: StaffLocation(.line, 1)) == SpelledPitch(.b, .octave2))
    }

    @Test func pitchAtSamePitchAsClef() async throws {
        #expect(try Clef.treble.pitch(at: StaffLocation(.line, 1)) ==
                SpelledPitch(.g, .octave4))
        #expect(try Clef.soprano.pitch(at: StaffLocation(.line, 0)) ==
                SpelledPitch(.c, .octave4))
    }

    @Test func pitchAtNegativeClefDecrease() async throws {
        let negativeClef = Clef(pitch: SpelledPitch(.d, .octave3), location: StaffLocation(.line, -1))
        #expect(try negativeClef.pitch(at: StaffLocation(.line, -2)) == SpelledPitch(.b, .octave2))
    }
}

/*
class ClefTests: XCTestCase {
	func testPitchAtNegativeClefDecrease() {
		assertNoErrorThrown {
			let negativeClef = Clef(pitch: SpelledPitch(noteLetter: .d, octave: .octave3),
									location: StaffLocation(type: .line, number: -1))
			XCTAssertEqual(try negativeClef.pitch(at: StaffLocation(type: .line, number: -2)),
						   SpelledPitch(noteLetter: .b, octave: .octave2))
		}
	}

	// MARK: - ==

	// MARK: Failures

	func testEqualityFailStandard() {
		XCTAssertFalse(Clef.treble == Clef.bass)
	}

	func testEqualityFailDifferentPitch() {
		let custom1 = Clef(
			pitch: SpelledPitch(noteLetter: .a, octave: .octave3),
			location: StaffLocation(type: .line, number: 1)
		)
		let custom2 = Clef(
			pitch: SpelledPitch(noteLetter: .a, octave: .octave2),
			location: StaffLocation(type: .line, number: 1)
		)
		XCTAssertFalse(custom1 == custom2)
	}

	func testEqualityFailDifferentLineNumber() {
		let custom1 = Clef(
			pitch: SpelledPitch(noteLetter: .a, octave: .octave2),
			location: StaffLocation(type: .space, number: 1)
		)
		let custom2 = Clef(
			pitch: SpelledPitch(noteLetter: .a, octave: .octave2),
			location: StaffLocation(type: .space, number: 2)
		)
		XCTAssertFalse(custom1 == custom2)
	}

	// MARK: Successes

	func testEqualityStandard() {
		XCTAssertTrue(Clef.treble == Clef.treble)
	}

	func testEqualityCustom() {
		let custom1 = Clef(
			pitch: SpelledPitch(noteLetter: .a, octave: .octave2),
			location: StaffLocation(type: .line, number: 1)
		)
		let custom2 = Clef(
			pitch: SpelledPitch(noteLetter: .a, octave: .octave2),
			location: StaffLocation(type: .line, number: 1)
		)
		XCTAssertTrue(custom1 == custom2)
	}

	func testEqualityCustomWithStandard() {
		let treble = Clef(
			pitch: SpelledPitch(noteLetter: .g, octave: .octave4),
			location: StaffLocation(type: .line, number: 1)
		)
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
			pitch: SpelledPitch(noteLetter: .a, octave: .octave3),
			location: StaffLocation(type: .line, number: 1)
		)
		XCTAssertEqual(custom.debugDescription, "a3@line1")
		let customNeutral = Clef(
			pitch: nil,
			location: StaffLocation(type: .space, number: 3)
		)
		XCTAssertEqual(customNeutral.debugDescription, "neutral")
	}
}
*/
