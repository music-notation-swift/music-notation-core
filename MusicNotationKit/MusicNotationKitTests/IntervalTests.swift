//
//  IntervalTests.swift
//  MusicNotationKit
//
//  Created by Rob Hudson on 8/1/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

import XCTest
import MusicNotationKit

class IntervalTests: XCTestCase {
    
    func testUnison() {
        let interval = Interval(quality: .perfect, number: 1)!
        XCTAssertEqual(interval.debugDescription, "perfect unison")
        XCTAssertEqual(interval.abbreviation, "P1")
    }
    
    func testMinorSecond() {
        let interval = Interval(quality: .minor, number: 2)!
        XCTAssertEqual(interval.debugDescription, "minor 2nd")
        XCTAssertEqual(interval.abbreviation, "m2")
    }
    
    func testMajorThird() {
        let interval = Interval(quality: .major, number: 3)!
        XCTAssertEqual(interval.debugDescription, "major 3rd")
        XCTAssertEqual(interval.abbreviation, "M3")
    }
    
    func testAugmentedFourth() {
        let interval = Interval(quality: .augmented, number: 4)!
        XCTAssertEqual(interval.debugDescription, "augmented 4th")
        XCTAssertEqual(interval.abbreviation, "A4")
    }
    
    func testDiminishedFifth() {
        let interval = Interval(quality: .diminished, number: 5)!
        XCTAssertEqual(interval.debugDescription, "diminished 5th")
        XCTAssertEqual(interval.abbreviation, "d5")
    }
    
    func testDoublyAugmentedSixth() {
        let interval = Interval(quality: .doublyAugmented, number: 6)!
        XCTAssertEqual(interval.debugDescription, "doubly augmented 6th")
        XCTAssertEqual(interval.abbreviation, "AA6")
    }
    
    func testDoubleDiminishedSeventh() {
        let interval = Interval(quality: .doublyDiminished, number: 7)!
        XCTAssertEqual(interval.debugDescription, "doubly diminished 7th")
        XCTAssertEqual(interval.abbreviation, "dd7")
    }
    
    func testOctave() {
        let interval = Interval(quality: .perfect, number: 8)!
        XCTAssertEqual(interval.debugDescription, "perfect octave")
        XCTAssertEqual(interval.abbreviation, "P8")
    }
    
    func testLargeInterval() {
        let interval = Interval(quality: .perfect, number: 33)!
        XCTAssertEqual(interval.debugDescription, "perfect 33rd")
        XCTAssertEqual(interval.abbreviation, "P33")
    }
    
    func testMajorOctaveInvalid() {
        let interval = Interval(quality: .major, number: 8)
        XCTAssertNil(interval)
    }
    
    func testPerfectNinthInvalid() {
        let interval = Interval(quality: .perfect, number: 9)
        XCTAssertNil(interval)
    }
    
    func testZeroInvalid() {
        let interval = Interval(quality: .augmented, number: 0)
        XCTAssertNil(interval)
    }
    
    func testNegativeNumberInvalid() {
        let interval = Interval(quality: .minor, number: -3)
        XCTAssertNil(interval)
    }
}
