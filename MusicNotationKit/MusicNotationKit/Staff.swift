//
//  Staff.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 6/15/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

public struct Staff {
	
	public let clef: Clef
	public let instrument: Instrument
	
	private(set) var notesHolders: [NotesHolder] = []
	
	init(clef: Clef, instrument: Instrument) {
		self.clef = clef
		self.instrument = instrument
	}
	
	public mutating func appendMeasure(measure: Measure) {
		self.notesHolders.append(measure)
	}
	
	public mutating func appendRepeat(repeatedMeasures: MeasureRepeat) {
		self.notesHolders.append(repeatedMeasures)
	}
	
	public mutating func insertMeasure(measure: Measure, atIndex index: Int) {
		self.notesHolders.insert(measure, atIndex: index)
	}
	
	public mutating func insertRepeat(repeatedMeasures: MeasureRepeat, atIndex index: Int) {
		self.notesHolders.insert(repeatedMeasures, atIndex: index)
	}
}

extension Staff: CustomDebugStringConvertible {
	public var debugDescription: String {
		return "staff(\(clef) \(instrument))"
	}
}
