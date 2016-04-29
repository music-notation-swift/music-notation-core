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
    public private(set) var measureCount: Int = 0
	
	internal private(set) var notesHolders: [NotesHolder] = []
	
	public init(clef: Clef, instrument: Instrument) {
		self.clef = clef
		self.instrument = instrument
	}
	
	public mutating func appendMeasure(measure: Measure) {
		notesHolders.append(measure)
        measureCount += 1
	}
	
	public mutating func appendRepeat(repeatedMeasures: MeasureRepeat) {
		notesHolders.append(repeatedMeasures)
        measureCount += repeatedMeasures.measureCount
	}
	
	public mutating func insertMeasure(measure: Measure, atIndex index: Int) {
		notesHolders.insert(measure, atIndex: index)
        measureCount += 1
	}
	
	public mutating func insertRepeat(repeatedMeasures: MeasureRepeat, atIndex index: Int) {
		notesHolders.insert(repeatedMeasures, atIndex: index)
        measureCount += repeatedMeasures.measureCount
	}
	
	public mutating func startTieFromNoteAtIndex(noteIndex: Int, inMeasureAtIndex measureIndex: Int) throws {
		
	}
	
	public mutating func removeTieFromNoteAtIndex(noteIndex: Int, inMeasureAtIndex measureIndex: Int) throws {
		
	}
	
	public func measureAtIndex(measureIndex: Int) throws -> ImmutableMeasure {
		// FIXME: REMOVE
		throw StaffError.MeasureIndexOutOfRange
	}
	
	public func measureRepeatAtIndex(index: Int) throws -> MeasureRepeat {
		// FIXME: REMOVE
		throw StaffError.MeasureIndexOutOfRange
	}
	
	internal func notesHolderAtIndex(index: Int) throws -> NotesHolder {
		// FIXME: REMOVE
		throw StaffError.MeasureIndexOutOfRange
	}
	
	private mutating func modifyTieForNoteAtIndex(noteIndex: Int, inMeasureAtIndex measureIndex: Int) throws {
		
	}
	
	internal func notesHolderIndexFromMeasureIndex(index: Int) throws -> (notesHolderIndex: Int, repeatMeasureIndex: Int?) {
        guard index >= 0 && index < measureCount else { throw StaffError.MeasureIndexOutOfRange }
        var measureIndexes: [(Int, Int?)] = []
        for (i, notesHolder) in notesHolders.enumerate() {
            switch notesHolder {
            case is Measure:
                measureIndexes.append((notesHolderIndex: i, repeatMeasureIndex: nil))
            case let measureRepeat as MeasureRepeat:
                for j in 0..<measureRepeat.measureCount {
                    measureIndexes.append((notesHolderIndex: i, repeatMeasureIndex: j))
                }
            default:
                assertionFailure("NotesHolders should only be Measure or MeasureRepeat")
                continue
            }
        }
        return measureIndexes[index]
	}
}

public enum StaffError: ErrorType {
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
