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
	
	internal private(set) var notesHolders: [NotesHolder] = []
	
	public init(clef: Clef, instrument: Instrument) {
		self.clef = clef
		self.instrument = instrument
	}
	
	public mutating func appendMeasure(measure: Measure) {
		notesHolders.append(measure)
	}
	
	public mutating func appendRepeat(repeatedMeasures: MeasureRepeat) {
		notesHolders.append(repeatedMeasures)
	}
	
	public mutating func insertMeasure(measure: Measure, atIndex index: Int) {
		notesHolders.insert(measure, atIndex: index)
	}
	
	public mutating func insertRepeat(repeatedMeasures: MeasureRepeat, atIndex index: Int) {
		notesHolders.insert(repeatedMeasures, atIndex: index)
	}
	
	public mutating func startTieFromNoteAtIndex(noteIndex: Int, inMeasureAtIndex measureIndex: Int) throws {
		
	}
	
	public mutating func removeTieFromNoteAtIndex(noteIndex: Int, inMeasureAtIndex measureIndex: Int) throws {
		
	}
	
	public func measureAtIndex(measureIndex: Int) throws -> ImmutableMeasure {
		// FIXME: REMOVE
		throw StaffErrors.MeasureIndexOutOfRange
	}
	
	public func measureRepeatAtIndex(index: Int) throws -> MeasureRepeat {
		// FIXME: REMOVE
		throw StaffErrors.MeasureIndexOutOfRange
	}
	
	internal func notesHolderAtIndex(index: Int) throws -> NotesHolder {
		// FIXME: REMOVE
		throw StaffErrors.MeasureIndexOutOfRange
	}
	
	private mutating func modifyTieForNoteAtIndex(noteIndex: Int, inMesureAtIndex measureIndex: Int) throws {
		
	}
	
	internal func notesHolderIndexFromMeasureIndex(index: Int) throws -> (notesHolderIndex: Int, repeatMeasureIndex: Int?) {
		// FIXME: REMOVE
		throw StaffErrors.MeasureIndexOutOfRange
	}
}

public enum StaffErrors: ErrorType {
	case NoteIndexOutOfRange
	case MeasureIndexOutOfRange
	case NoNextNoteToTie
	case NoNextNote
	case NotBeginningOfTie
	case RepeatedMeasureCannotHaveTie
	case MeasureNotPartOfRepeat
}

extension Staff: CustomDebugStringConvertible {
	public var debugDescription: String {
		return "staff(\(clef) \(instrument))"
	}
}
