//
//  Repeat.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 6/15/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

public struct Repeat {
	
	public var count: Int
	public var measures: [Measure]
	
	public init(measures: [Measure], repeatCount: Int = 1) throws {
		guard measures.count > 0 else { throw RepeatError.NoMeasures }
		guard repeatCount > 0 else { throw RepeatError.InvalidRepeatCount }
		self.measures = measures
		count = repeatCount
	}
}

extension Repeat: NotesHolder {
	
	
}

public enum RepeatError: ErrorType {
	case NoMeasures
	case InvalidRepeatCount
}
