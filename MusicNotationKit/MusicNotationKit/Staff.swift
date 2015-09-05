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
	
	public init(clef: Clef, instrument: Instrument) {
		self.clef = clef
		self.instrument = instrument
	}
	
	public mutating func appendMeasure(measure: Measure) {
		self.notesHolders.append(measure)
	}
	
	public mutating func appendRepeat(repeatedMeasures: Repeat) {
		self.notesHolders.append(repeatedMeasures)
	}
	
	public mutating func insertMeasure(measure: Measure, atIndex index: Int) {
		self.notesHolders.insert(measure, atIndex: index)
	}
	
	public mutating func insertRepeat(repeatedMeasures: Repeat, atIndex index: Int) {
		self.notesHolders.insert(repeatedMeasures, atIndex: index)
	}
	
	public mutating func startTieFromNote(noteIndex: Int, inMeasureAtIndex: Int) throws {
		
	}
	
	public mutating func removeTieFromNote(noteIndex: Int, inMeasureAtIndex: Int) throws {
		
	}
}

public enum StaffErrors: ErrorType {
	case NoteIndexOutOfRange
	case MeasureIndexOutOfRange
	case NoNextNoteToTie
	case NoNextNote
}
