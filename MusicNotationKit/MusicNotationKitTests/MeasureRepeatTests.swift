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
    static let key = Key(noteLetter: .c)
    static let note1 = Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, octave: .octave1))
    static let note2 = Note(noteDuration: .quarter, tone: Tone(noteLetter: .d, octave: .octave1))
    let measure1 = Measure(timeSignature: timeSignature, key: key, notes: [note1, note1])
    let measure2 = Measure(timeSignature: timeSignature, key: key, notes: [note2, note2])

    // MARK: - init(measures:repeateCount:)
    // MARK: Failures

    func testInitInvalidRepeatCount() {
        do {
            let _ = try MeasureRepeat(measures: [measure1], repeatCount: -2)
            shouldFail()
        } catch MeasureRepeatError.invalidRepeatCount {
        } catch {
            expected(MeasureRepeatError.invalidRepeatCount, actual: error)
        }
    }

    func testInitNoMeasures() {
        do {
            let _ = try MeasureRepeat(measures: [])
            shouldFail()
        } catch MeasureRepeatError.noMeasures {
        } catch {
            expected(MeasureRepeatError.noMeasures, actual: error)
        }
    }

    // MARK: Successes

    func testInitNotSpecifiedRepeatCount() {
        do {
            let measureRepeat = try MeasureRepeat(measures: [measure1])
            XCTAssertEqual(measureRepeat.repeatCount, 1)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testInitSingleMeasure() {
        do {
            let _ = try MeasureRepeat(measures: [measure2], repeatCount: 3)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testInitMultipleMeasures() {
        do {
            let _ = try MeasureRepeat(measures: [measure1, measure2], repeatCount: 4)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    // MARK: - expand()

    func testExpandSingleMeasureRepeatedOnce() {
        do {
            let measureRepeat = try MeasureRepeat(measures: [measure1], repeatCount: 1)
            let expected = [measure1, RepeatedMeasure(immutableMeasure: measure1)] as [ImmutableMeasure]
            let actual = measureRepeat.expand()
            guard actual.count == expected.count else {
                XCTFail()
                return
            }
            XCTAssertTrue(compareImmutableMeasureArrays(actual: actual, expected: expected))
            XCTAssertEqual(String(describing: measureRepeat), "[ |4/4: 1/8c1,1/8c1| ] × 2")
        }
        catch {
            XCTFail(String(describing: error))
        }
    }

    func testExpandSingleMeasureRepeatedMany() {
        do {
            let measureRepeat = try MeasureRepeat(measures: [measure1], repeatCount: 3)
            let repeatedMeasure = RepeatedMeasure(immutableMeasure: measure1)
            let expected = [measure1, repeatedMeasure, repeatedMeasure, repeatedMeasure] as [ImmutableMeasure]
            let actual = measureRepeat.expand()
            guard actual.count == expected.count else {
                XCTFail()
                return
            }
            XCTAssertTrue(compareImmutableMeasureArrays(actual: actual, expected: expected))
            XCTAssertEqual(String(describing: measureRepeat), "[ |4/4: 1/8c1,1/8c1| ] × 4")
        }
        catch {
            XCTFail(String(describing: error))
        }
    }

    func testExpandManyMeasuresRepeatedOnce() {
        do {
            let measureRepeat = try MeasureRepeat(measures: [measure1, measure2], repeatCount: 1)
            let repeatedMeasure1 = RepeatedMeasure(immutableMeasure: measure1)
            let repeatedMeasure2 = RepeatedMeasure(immutableMeasure: measure2)
            let expected = [measure1, measure2, repeatedMeasure1, repeatedMeasure2] as [ImmutableMeasure]
            let actual = measureRepeat.expand()
            guard actual.count == expected.count else {
                XCTFail()
                return
            }
            XCTAssertTrue(compareImmutableMeasureArrays(actual: actual, expected: expected))
            XCTAssertEqual(String(describing: measureRepeat), "[ |4/4: 1/8c1,1/8c1|, |4/4: 1/4d1,1/4d1| ] × 2")
        }
        catch {
            XCTFail(String(describing: error))
        }
    }

    func testExpandManyMeasuresRepeatedMany() {
        do {
            let measureRepeat = try MeasureRepeat(measures: [measure1, measure2], repeatCount: 3)
            let repeatedMeasure1 = RepeatedMeasure(immutableMeasure: measure1)
            let repeatedMeasure2 = RepeatedMeasure(immutableMeasure: measure2)
            let expected = [
                measure1, measure2,
                repeatedMeasure1, repeatedMeasure2,
                repeatedMeasure1, repeatedMeasure2,
                repeatedMeasure1, repeatedMeasure2
                ] as [ImmutableMeasure]
            let actual = measureRepeat.expand()
            guard actual.count == expected.count else {
                XCTFail()
                return
            }
            XCTAssertTrue(compareImmutableMeasureArrays(actual: actual, expected: expected))
            XCTAssertEqual(String(describing: measureRepeat), "[ |4/4: 1/8c1,1/8c1|, |4/4: 1/4d1,1/4d1| ] × 4")
        }
        catch {
            XCTFail(String(describing: error))
        }
    }

    // MARK: - ==
    // MARK: Failures

    func testEqualitySameMeasureCountDifferentMeasures() {
        do {
            let measureRepeat1 = try MeasureRepeat(measures: [measure1, measure2, measure1])
            let measureRepeat2 = try MeasureRepeat(measures: [measure2, measure1, measure2])
            XCTAssertFalse(measureRepeat1 == measureRepeat2)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testEqualityDifferentMeasureCountSameMeasures() {
        do {
            let measureRepeat1 = try MeasureRepeat(measures: [measure1, measure2])
            let measureRepeat2 = try MeasureRepeat(measures: [measure1, measure2, measure1])
            XCTAssertFalse(measureRepeat1 == measureRepeat2)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testEqualityDifferentMeasureCountDifferentMeasures() {
        do {
            let measureRepeat1 = try MeasureRepeat(measures: [measure1, measure2])
            let measureRepeat2 = try MeasureRepeat(measures: [measure2, measure1, measure2])
            XCTAssertFalse(measureRepeat1 == measureRepeat2)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testEqualityDifferentRepeatCount() {
        do {
            let measureRepeat1 = try MeasureRepeat(measures: [measure1, measure2], repeatCount: 2)
            let measureRepeat2 = try MeasureRepeat(measures: [measure1, measure2], repeatCount: 3)
            XCTAssertFalse(measureRepeat1 == measureRepeat2)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    // MARK: Successes

    func testEqualitySucceeds() {
        do {
            let measureRepeat1 = try MeasureRepeat(measures: [measure1], repeatCount: 2)
            let measureRepeat2 = try MeasureRepeat(measures: [measure1], repeatCount: 2)
            XCTAssertTrue(measureRepeat1 == measureRepeat2)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    // MARK: - Helpers

    private func compareImmutableMeasureArrays(actual: [ImmutableMeasure], expected: [ImmutableMeasure]) -> Bool {
        for (index, item) in actual.enumerated() {
            if let item = item as? RepeatedMeasure {
                if let expectedItem = expected[index] as? RepeatedMeasure {
                    if item == expectedItem {
                        continue
                    } else {
                        return false
                    }
                } else {
                    return false
                }
            } else if let item = item as? Measure {
                if let expectedItem = expected[index] as? Measure {
                    if item == expectedItem {
                        continue
                    } else {
                        return false
                    }
                } else {
                    return false
                }
            } else {
                XCTFail("Item was not a Measure nor RepeatedMeasure")
                return false
            }
        }
        return true
    }
}
