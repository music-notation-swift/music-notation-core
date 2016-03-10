//
//  MeasureRepeatTests.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 3/9/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

import XCTest
@testable import MusicNotationKit

class MeasureRepeatTests: XCTestCase {
	
	static let timeSignature = TimeSignature(topNumber: 4, bottomNumber: 4, tempo: 120)
	static let key = Key(noteLetter: .C)
	static let note1 = Note(noteDuration: .Eighth, tone: Tone(noteLetter: .C, octave: .Octave1))
	static let note2 = Note(noteDuration: .Quarter, tone: Tone(noteLetter: .D, octave: .Octave1))
	let measure1 = Measure(timeSignature: timeSignature, key: key, notes: [note1, note1])
	let measure2 = Measure(timeSignature: timeSignature, key: key, notes: [note2, note2])
	
	// MARK: - expand()
	
	func testExpandSingleMeasureRepeatedOnce() {
		do {
			let measureRepeat = try MeasureRepeat(measures: [measure1], repeatCount: 1)
			let expected = [measure1, measure1] as [NotesHolder]
			let actual = measureRepeat.expand()
			XCTAssertEqual(actual.count, expected.count)
			for (index, item) in actual.enumerate() {
				if let item = item as? RepeatedMeasure {
					if let expectedItem = expected[index] as? RepeatedMeasure {
						XCTAssertEqual(item, expectedItem)
					} else {
						XCTFail()
					}
				} else if let item = item as? Measure {
					if let expectedItem = expected[index] as? Measure {
						XCTAssertEqual(item, expectedItem)
					} else {
						XCTFail()
					}
				} else {
					XCTFail("Item was not a Measure nor RepeatedMeasure")
				}
			}
		}
		catch {
			XCTFail(String(error))
		}
	}
	
	func testExpandSingleMeasureRepeatedMany() {
		
	}
	
	func testExpandManyMeasuresRepeatedOnce() {
		
	}
	
	func testExpandManyMeasuresRepeatedMany() {
		
	}
}
