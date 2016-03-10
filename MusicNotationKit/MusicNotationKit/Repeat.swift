//
//  Repeat.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 6/15/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

public struct MeasureRepeat {
	
	public var count: Int
	public var measures: [Measure]
	
	public init(measures: [Measure], repeatCount: Int = 1) throws {
		guard measures.count > 0 else { throw MeasureRepeatError.NoMeasures }
		guard repeatCount > 0 else { throw MeasureRepeatError.InvalidRepeatCount }
		self.measures = measures
		count = repeatCount
	}
	
	internal func expand() -> [NotesHolder] {
		let repeatedMeasuresHolders = measures.map {
			return RepeatedMeasure(timeSignature: $0.timeSignature, key: $0.key, notes: $0.notes) as NotesHolder
		}
		let measuresHolders = measures.map { $0 as NotesHolder }
		var allMeasures: [NotesHolder] = measuresHolders
		for _ in 0..<count {
			allMeasures += repeatedMeasuresHolders
		}
		return allMeasures
	}
}

extension MeasureRepeat: NotesHolder {
	
}

public enum MeasureRepeatError: ErrorType {
	case NoMeasures
	case InvalidRepeatCount
}
