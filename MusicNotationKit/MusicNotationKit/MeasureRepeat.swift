//
//  MeasureRepeat.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 6/15/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

/**
 This represents a set of one or more measures that is repeated `repeatCount` times.
 */
public struct MeasureRepeat {

    public var repeatCount: Int
    public var measures: [Measure]
	/// The number of measures, including repeated measures
    public let measureCount: Int

    public init(measures: [Measure], repeatCount: Int = 1) throws {
        guard measures.count > 0 else { throw MeasureRepeatError.noMeasures }
        guard repeatCount > 0 else { throw MeasureRepeatError.invalidRepeatCount }
        self.measures = measures
        self.repeatCount = repeatCount
        measureCount = measures.count + (repeatCount * measures.count)
    }

    internal func expand() -> [ImmutableMeasure] {
        let repeatedMeasuresHolders = measures.map {
            return RepeatedMeasure(immutableMeasure: $0) as ImmutableMeasure
        }
        let measuresHolders = measures.map { $0 as ImmutableMeasure }
        var allMeasures: [ImmutableMeasure] = measuresHolders
        for _ in 0..<repeatCount {
            allMeasures += repeatedMeasuresHolders
        }
        return allMeasures
    }
}

extension MeasureRepeat: NotesHolder {

}

extension MeasureRepeat: Equatable {}

public func ==(lhs: MeasureRepeat, rhs: MeasureRepeat) -> Bool {
    guard lhs.repeatCount == rhs.repeatCount else {
        return false
    }
    guard lhs.measures == rhs.measures else {
        return false
    }
    return true
}

public enum MeasureRepeatError: ErrorProtocol {
    case noMeasures
    case invalidRepeatCount
}
