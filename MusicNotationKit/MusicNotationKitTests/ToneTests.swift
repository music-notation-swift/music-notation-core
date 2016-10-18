//
//  ToneTests.swift
//  MusicNotationKit
//
//  Created by Rob Hudson on 7/29/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

import XCTest
import MusicNotationKit

class ToneTests: XCTestCase {

    func testTone1() {
        let tone = Tone(noteLetter: .c, octave: .octave3)
        XCTAssertTrue(tone.debugDescription == "c3")
    }
    
    func testTone2() {
        let tone = Tone(noteLetter: .g, accidental: .sharp, octave: .octave6)
        XCTAssertTrue(tone.debugDescription == "g♯6")
    }

    func testTone3() {
        let tone = Tone(noteLetter: .e, accidental: .flat, octave: .octave2)
        XCTAssertTrue(tone.debugDescription == "e♭2")
    }
    
    func testTone4() {
        let tone = Tone(noteLetter: .a, accidental: .natural, octave: .octave4)
        XCTAssertTrue(tone.debugDescription == "a4")
    }
    
    func testTone5() {
        let tone = Tone(noteLetter: .b, accidental: .doubleSharp, octave: .octave5)
        XCTAssertTrue(tone.debugDescription == "b𝄪5")
    }
    
    func testTone6() {
        let tone = Tone(noteLetter: .f, accidental: .doubleFlat, octave: .octave7)
        XCTAssertTrue(tone.debugDescription == "f𝄫7")
    }
    
    // MARK: - ==
    // MARK: Failures
    
    func testNotEqual() {
        let tone1 = Tone(noteLetter: .b, accidental: .flat, octave: .octave5)
        let tone2 = Tone(noteLetter: .b, accidental: .flat, octave: .octave4)
        
        XCTAssertNotEqual(tone1, tone2)
    }

    // MARK: Successes
    
    func testEqual() {
        let tone1 = Tone(noteLetter: .d, accidental: .sharp, octave: .octave1)
        let tone2 = Tone(noteLetter: .d, accidental: .sharp, octave: .octave1)
        
        XCTAssertEqual(tone1, tone2)
    }
    
    // MARK: - MIDI numbers
    // MARK: Successes
    
    func testRidiculouslyLowNote() {
        let tone = Tone(noteLetter: .c, accidental: .natural, octave: .octaveNegative1)
        
        XCTAssertEqual(tone.midiNoteNumber, 0)
    }
    
    func testLowNote() {
        let tone = Tone(noteLetter: .f, accidental: .sharp, octave: .octave1)
        
        XCTAssertEqual(tone.midiNoteNumber, 30)
    }
    
    func testMidRangeNote() {
        let tone = Tone(noteLetter: .d, octave: .octave4)
        
        XCTAssertEqual(tone.midiNoteNumber, 62)
    }
    
    func testHighNote() {
        let tone = Tone(noteLetter: .c, accidental: .flat, octave: .octave8)
        
        XCTAssertEqual(tone.midiNoteNumber, 107)
    }
    
    // MARK: - isEnharmonic(with:)
    // MARK: Failures
    
    func testDifferentAccidentals() {
        let tone1 = Tone(noteLetter: .d, accidental: .flat, octave: .octave1)
        let tone2 = Tone(noteLetter: .d, accidental: .sharp, octave: .octave1)
        
        XCTAssertNotEqual(tone1, tone2)
        XCTAssertFalse(tone1.isEnharmonic(with: tone2))
    }
    
    func testSamePitchDifferentOctaves() {
        let tone1 = Tone(noteLetter: .e, accidental: .natural, octave: .octave5)
        let tone2 = Tone(noteLetter: .e, accidental: .natural, octave: .octave6)
        
        XCTAssertNotEqual(tone1, tone2)
        XCTAssertFalse(tone1.isEnharmonic(with: tone2))
    }
    
    func testEnharmonicPitchDifferentOctaves() {
        let tone1 = Tone(noteLetter: .f, accidental: .doubleSharp, octave: .octave2)
        let tone2 = Tone(noteLetter: .g, accidental: .natural, octave: .octave5)
        
        XCTAssertNotEqual(tone1, tone2)
        XCTAssertFalse(tone1.isEnharmonic(with: tone2))
    }

    // MARK: Successes
    
    func testSameToneIsEnharmonic() {
        let tone1 = Tone(noteLetter: .g, accidental: .natural, octave: .octave6)
        let tone2 = Tone(noteLetter: .g, accidental: .natural, octave: .octave6)
        
        XCTAssertEqual(tone1, tone2)
        XCTAssertTrue(tone1.isEnharmonic(with: tone2))
        // Transitive property
        XCTAssertTrue(tone2.isEnharmonic(with: tone1))
    }
    
    func testEnharmonicNotEquatable() {
        let tone1 = Tone(noteLetter: .a, accidental: .flat, octave: .octave3)
        let tone2 = Tone(noteLetter: .g, accidental: .sharp, octave: .octave3)
        
        XCTAssertNotEqual(tone1, tone2)
        XCTAssertTrue(tone1.isEnharmonic(with: tone2))
    }
    
    func testNaturalAndFlat() {
        let tone1 = Tone(noteLetter: .e, accidental: .natural, octave: .octave4)
        let tone2 = Tone(noteLetter: .f, accidental: .flat, octave: .octave4)
        
        XCTAssertNotEqual(tone1, tone2)
        XCTAssertTrue(tone1.isEnharmonic(with: tone2))
    }
    
    func testDoubleFlat() {
        let tone1 = Tone(noteLetter: .b, accidental: .doubleFlat, octave: .octave2)
        let tone2 = Tone(noteLetter: .a, octave: .octave2)
        
        XCTAssertNotEqual(tone1, tone2)
        XCTAssertTrue(tone1.isEnharmonic(with: tone2))
    }
    
    func testDifferentOctaveNumbers() {
        let tone1 = Tone(noteLetter: .b, accidental: .sharp, octave: .octave6)
        let tone2 = Tone(noteLetter: .c, accidental: .natural, octave: .octave7)
        
        XCTAssertNotEqual(tone1, tone2)
        XCTAssertTrue(tone1.isEnharmonic(with: tone2))
    }
    
}
