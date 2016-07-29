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
        let tone = Tone(accidental: nil, noteLetter: .c, octave: .octave3)
        XCTAssertTrue(tone.debugDescription == "c3")
    }
    
    func testTone2() {
        let tone = Tone(accidental: .sharp, noteLetter: .g, octave: .octave6)
        XCTAssertTrue(tone.debugDescription == "g♯6")
    }

    func testTone3() {
        let tone = Tone(accidental: .flat, noteLetter: .e, octave: .octave2)
        XCTAssertTrue(tone.debugDescription == "e♭2")
    }
    
    func testTone4() {
        let tone = Tone(accidental: .natural, noteLetter: .a, octave: .octave4)
        XCTAssertTrue(tone.debugDescription == "a♮4")
    }
    
    func testTone5() {
        let tone = Tone(accidental: .doubleSharp, noteLetter: .b, octave: .octave5)
        XCTAssertTrue(tone.debugDescription == "b𝄪5")
    }
    
    func testTone6() {
        let tone = Tone(accidental: .doubleFlat, noteLetter: .f, octave: .octave7)
        XCTAssertTrue(tone.debugDescription == "f𝄫7")
    }
    
    func testEqual() {
        let tone1 = Tone(accidental: .sharp, noteLetter: .d, octave: .octave1)
        let tone2 = Tone(accidental: .sharp, noteLetter: .d, octave: .octave1)
        
        XCTAssertEqual(tone1, tone2)
    }
    
    func testNotEqual() {
        let tone1 = Tone(accidental: .flat, noteLetter: .b, octave: .octave5)
        let tone2 = Tone(accidental: .flat, noteLetter: .b, octave: .octave4)
        
        XCTAssertNotEqual(tone1, tone2)
    }
}
