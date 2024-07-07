//
//  PitchTests.swift
//  MusicNotationCore
//
//  Created by Rob Hudson on 07/29/016.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

@testable import MusicNotationCore
import XCTest

class PitchTests: XCTestCase {
	func testPitch1() {
        let pitch = SpelledPitch(.c, .octave3)
		XCTAssertTrue(pitch.debugDescription == "c3")
	}

	func testPitch2() {
        let pitch = SpelledPitch(.g, accidental: .sharp, .octave6)
		XCTAssertTrue(pitch.debugDescription == "g♯6")
	}

	func testPitch3() {
        let pitch = SpelledPitch(.e, accidental: .flat, .octave2)
		XCTAssertTrue(pitch.debugDescription == "e♭2")
	}

	func testPitch4() {
        let pitch = SpelledPitch(.a, accidental: .natural, .octave4)
		XCTAssertTrue(pitch.debugDescription == "a4")
	}

	func testPitch5() {
        let pitch = SpelledPitch(.b, accidental: .doubleSharp, .octave5)
		XCTAssertTrue(pitch.debugDescription == "b𝄪5")
	}

	func testPitch6() {
        let pitch = SpelledPitch(.f, accidental: .doubleFlat, .octave7)
		XCTAssertTrue(pitch.debugDescription == "f𝄫7")
	}

	// MARK: - ==

	// MARK: Failures

	func testNotEqual() {
        let pitch1 = SpelledPitch(.b, accidental: .flat, .octave5)
        let pitch2 = SpelledPitch(.b, accidental: .flat, .octave4)

		XCTAssertNotEqual(pitch1, pitch2)
	}

	// MARK: Successes

	func testEqual() {
        let pitch1 = SpelledPitch(.d, accidental: .sharp, .octave1)
        let pitch2 = SpelledPitch(.d, accidental: .sharp, .octave1)

		XCTAssertEqual(pitch1, pitch2)
	}

	// MARK: - MIDI numbers

	// MARK: Successes

	func testRidiculouslyLowNote() {
        let pitch = SpelledPitch(.c, accidental: .natural, .octaveNegative1)

		XCTAssertEqual(pitch.midiNoteNumber, 0)
	}

	func testLowNote() {
        let pitch = SpelledPitch(.f, accidental: .sharp, .octave1)

		XCTAssertEqual(pitch.midiNoteNumber, 30)
	}

	func testMidRangeNote() {
        let pitch = SpelledPitch(.d, .octave4)

		XCTAssertEqual(pitch.midiNoteNumber, 62)
	}

	func testHighNote() {
        let pitch = SpelledPitch(.c, accidental: .flat, .octave8)

		XCTAssertEqual(pitch.midiNoteNumber, 107)
	}

	// MARK: - isEnharmonic(with:)

	// MARK: Failures

	func testDifferentAccidentals() {
        let pitch1 = SpelledPitch(.d, accidental: .flat, .octave1)
        let pitch2 = SpelledPitch(.d, accidental: .sharp, .octave1)

		XCTAssertNotEqual(pitch1, pitch2)
		XCTAssertFalse(pitch1.isEnharmonic(with: pitch2))
	}

	func testSamePitchDifferentOctaves() {
        let pitch1 = SpelledPitch(.e, accidental: .natural, .octave5)
        let pitch2 = SpelledPitch(.e, accidental: .natural, .octave6)

		XCTAssertNotEqual(pitch1, pitch2)
		XCTAssertFalse(pitch1.isEnharmonic(with: pitch2))
	}

	func testEnharmonicPitchDifferentOctaves() {
        let pitch1 = SpelledPitch(.f, accidental: .doubleSharp, .octave2)
        let pitch2 = SpelledPitch(.g, accidental: .natural, .octave5)

		XCTAssertNotEqual(pitch1, pitch2)
		XCTAssertFalse(pitch1.isEnharmonic(with: pitch2))
	}

	// MARK: Successes

	func testSamePitchIsEnharmonic() {
        let pitch1 = SpelledPitch(.g, accidental: .natural, .octave6)
        let pitch2 = SpelledPitch(.g, accidental: .natural, .octave6)

		XCTAssertEqual(pitch1, pitch2)
		XCTAssertTrue(pitch1.isEnharmonic(with: pitch2))
		// Transitive property
		XCTAssertTrue(pitch2.isEnharmonic(with: pitch1))
	}

	func testEnharmonicNotEquatable() {
        let pitch1 = SpelledPitch(.a, accidental: .flat, .octave3)
        let pitch2 = SpelledPitch(.g, accidental: .sharp, .octave3)

		XCTAssertNotEqual(pitch1, pitch2)
		XCTAssertTrue(pitch1.isEnharmonic(with: pitch2))
	}

	func testNaturalAndFlat() {
        let pitch1 = SpelledPitch(.e, accidental: .natural, .octave4)
        let pitch2 = SpelledPitch(.f, accidental: .flat, .octave4)

		XCTAssertNotEqual(pitch1, pitch2)
		XCTAssertTrue(pitch1.isEnharmonic(with: pitch2))
	}

	func testDoubleFlat() {
        let pitch1 = SpelledPitch(.b, accidental: .doubleFlat, .octave2)
        let pitch2 = SpelledPitch(.a, .octave2)

		XCTAssertNotEqual(pitch1, pitch2)
		XCTAssertTrue(pitch1.isEnharmonic(with: pitch2))
	}

	func testDifferentOctaveNumbers() {
        let pitch1 = SpelledPitch(.b, accidental: .sharp, .octave6)
        let pitch2 = SpelledPitch(.c, accidental: .natural, .octave7)

		XCTAssertNotEqual(pitch1, pitch2)
		XCTAssertTrue(pitch1.isEnharmonic(with: pitch2))
	}
}
