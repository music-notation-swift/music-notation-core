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

    // MARK: - init(measures:repeateCount:)
    // MARK: Failures

    func testInitInvalidRepeatCount() {
        do {
            let _ = try MeasureRepeat(measures: [measure1], repeatCount: -2)
            shouldFail()
        } catch MeasureRepeatError.InvalidRepeatCount {
        } catch {
            expected(MeasureRepeatError.InvalidRepeatCount, actual: error)
        }
    }

    func testInitNoMeasures() {
        do {
            let _ = try MeasureRepeat(measures: [])
            shouldFail()
        } catch MeasureRepeatError.NoMeasures {
        } catch {
            expected(MeasureRepeatError.NoMeasures, actual: error)
        }
    }

    // MARK: Successes

    func testInitNotSpecifiedRepeatCount() {
        do {
            let _ = try MeasureRepeat(measures: [measure1])
        } catch {
            XCTFail(String(error))
        }
    }

    func testInitSingleMeasure() {
        do {
            let _ = try MeasureRepeat(measures: [measure2], repeatCount: 3)
        } catch {
            XCTFail(String(error))
        }
    }

    func testInitMultipleMeasures() {
        do {
            let _ = try MeasureRepeat(measures: [measure1, measure2], repeatCount: 4)
        } catch {
            XCTFail(String(error))
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
        }
        catch {
            XCTFail(String(error))
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
        }
        catch {
            XCTFail(String(error))
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
        }
        catch {
            XCTFail(String(error))
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
        }
        catch {
            XCTFail(String(error))
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
            XCTFail(String(error))
        }
    }

    func testEqualityDifferentMeasureCountSameMeasures() {
        do {
            let measureRepeat1 = try MeasureRepeat(measures: [measure1, measure2])
            let measureRepeat2 = try MeasureRepeat(measures: [measure1, measure2, measure1])
            XCTAssertFalse(measureRepeat1 == measureRepeat2)
        } catch {
            XCTFail(String(error))
        }
    }

    func testEqualityDifferentMeasureCountDifferentMeasures() {
        do {
            let measureRepeat1 = try MeasureRepeat(measures: [measure1, measure2])
            let measureRepeat2 = try MeasureRepeat(measures: [measure2, measure1, measure2])
            XCTAssertFalse(measureRepeat1 == measureRepeat2)
        } catch {
            XCTFail(String(error))
        }
    }

    func testEqualityDifferentRepeatCount() {
        do {
            let measureRepeat1 = try MeasureRepeat(measures: [measure1, measure2], repeatCount: 2)
            let measureRepeat2 = try MeasureRepeat(measures: [measure1, measure2], repeatCount: 3)
            XCTAssertFalse(measureRepeat1 == measureRepeat2)
        } catch {
            XCTFail(String(error))
        }
    }

    // MARK: Successes

    func testEqualitySucceeds() {
        do {
            let measureRepeat1 = try MeasureRepeat(measures: [measure1], repeatCount: 2)
            let measureRepeat2 = try MeasureRepeat(measures: [measure1], repeatCount: 2)
            XCTAssertTrue(measureRepeat1 == measureRepeat2)
        } catch {
            XCTFail(String(error))
        }
    }

    // MARK: - Helpers

    private func compareImmutableMeasureArrays(actual actual: [ImmutableMeasure], expected: [ImmutableMeasure]) -> Bool {
        for (index, item) in actual.enumerate() {
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
