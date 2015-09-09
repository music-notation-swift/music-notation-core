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
}

extension MeasureRepeat: NotesHolder {
	
	
}

public enum MeasureRepeatError: ErrorType {
	case NoMeasures
	case InvalidRepeatCount
}
