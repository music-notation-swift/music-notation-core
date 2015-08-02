//
//  RepeatTests.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 7/11/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

import XCTest
@testable import MusicNotationKit

class RepeatTests: XCTestCase {

	let measure1: Measure = Measure(
		timeSignature: TimeSignature(topNumber: 4, bottomNumber: 4, tempo: 120),
		key: Key(noteLetter: .C),
		notes: [Note(noteDuration: .Whole)])
	let measure2: Measure = Measure(
		timeSignature: TimeSignature(topNumber: 4, bottomNumber: 4, tempo: 120),
		key: Key(noteLetter: .C),
		notes: [Note(noteDuration: .Half), Note(noteDuration: .Half)])
	
	func testInitSuccess() {
		// 1 Measure given
		do {
			let _ = try Repeat(measures: [measure1])
		} catch {
			XCTFail("\(error)")
		}
		
		// > 1 Measure given
		do {
			let _ = try Repeat(measures: [measure1, measure2])
		} catch {
			XCTFail("\(error)")
		}
		
		// Repeat count is 1
		do {
			let _ = try Repeat(measures: [measure1], repeatCount: 1)
		} catch {
			XCTFail("\(error)")
		}
		
		// Repeat count unspecified; should be 1
		do {
			let repeat1 = try Repeat(measures: [measure1])
			XCTAssertEqual(1, repeat1.count)
		} catch {
			XCTFail("\(error)")
		}
		
		// Repeat count is > 1
		do {
			let _ = try Repeat(measures: [measure1, measure2], repeatCount: 2)
		} catch {
			XCTFail("\(error)")
		}
	}
	
	func testInitFailure() {
		// 0 Measures given
		do {
			let _ = try Repeat(measures: [])
		} catch RepeatError.NoMeasures {
		} catch {
			expected(RepeatError.NoMeasures, actual: error)
		}
		
		do {
			let _ = try Repeat(measures: [], repeatCount: 1)
		} catch RepeatError.NoMeasures {
		} catch {
			expected(RepeatError.NoMeasures, actual: error)
		}
		
		// Repeat count is negative
		do {
			let _ = try Repeat(measures: [measure1], repeatCount: -1)
		} catch RepeatError.InvalidRepeatCount {
		} catch {
			expected(RepeatError.InvalidRepeatCount, actual: error)
		}
		
		// Repeat count is 0
		do {
			let _ = try Repeat(measures: [measure1, measure2], repeatCount: 0)
		} catch RepeatError.InvalidRepeatCount {
		} catch {
			expected(RepeatError.InvalidRepeatCount, actual: error)
		}
		
		// 0 measures and invalid repeat count
		do {
			let _ = try Repeat(measures: [], repeatCount: 0)
		} catch RepeatError.NoMeasures {
		} catch {
			expected(RepeatError.NoMeasures, actual: error)
		}
	}
}
