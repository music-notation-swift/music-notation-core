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
	
    internal private(set) var notesHolders: [NotesHolder] = [] {
        didSet {
            recomputeMeasureIndexes()
        }
    }

    private var measureIndexes: [(notesHolderIndex: Int, repeatMeasureIndex: Int?)] = []
	
	public init(clef: Clef, instrument: Instrument) {
		self.clef = clef
		self.instrument = instrument
	}
	
	public mutating func appendMeasure(measure: Measure) {
		notesHolders.append(measure)
        measureCount += measure.measureCount
	}
	
	public mutating func appendRepeat(repeatedMeasures: MeasureRepeat) {
		notesHolders.append(repeatedMeasures)
        measureCount += repeatedMeasures.measureCount
	}
	
	public mutating func insertMeasure(measure: Measure, atIndex index: Int) {
        // TODO: Handle it properly with the index being the measure index
        // Have to somehow handle the case of trying to insert where repeats are
		notesHolders.insert(measure, atIndex: index)
        measureCount += measure.measureCount
	}
	
	public mutating func insertRepeat(repeatedMeasures: MeasureRepeat, atIndex index: Int) {
        // TODO: Handle it properly with the index being the measure index
        // Have to somehow handle the case of trying to insert where repeats already exist
		notesHolders.insert(repeatedMeasures, atIndex: index)
        measureCount += repeatedMeasures.measureCount
	}

    public mutating func replaceMeasureAtIndex(measureIndex: Int, withNewMeasure newMeasure: Measure) throws {
        let (notesHolderIndex, repeatMeasureIndex) = try notesHolderIndexFromMeasureIndex(measureIndex)
        let newNotesHolder: NotesHolder
        if let repeatMeasureIndex = repeatMeasureIndex {
            guard (try? mutableMeasureFromNotesHolderIndex(notesHolderIndex, repeatMeasureIndex: repeatMeasureIndex)) != nil else {
                throw StaffError.RepeatedMeasureCannotBeModified
            }
            guard var measureRepeat = notesHolders[notesHolderIndex] as? MeasureRepeat else {
                assertionFailure("Index translation showed should be a repeat, but it's not")
                throw StaffError.InternalError
            }
            measureRepeat.measures[repeatMeasureIndex] = newMeasure
            newNotesHolder = measureRepeat
        } else {
            newNotesHolder = newMeasure
        }
        notesHolders[notesHolderIndex] = newNotesHolder
    }
	
	public mutating func startTieFromNoteAtIndex(noteIndex: Int, inMeasureAtIndex measureIndex: Int) throws {
		try modifyTieForNoteAtIndex(noteIndex, inMeasureAtIndex: measureIndex, removeTie: false)
	}
	
	public mutating func removeTieFromNoteAtIndex(noteIndex: Int, inMeasureAtIndex measureIndex: Int) throws {
		try modifyTieForNoteAtIndex(noteIndex, inMeasureAtIndex: measureIndex, removeTie: true)
	}
	
	public func measureAtIndex(measureIndex: Int) throws -> ImmutableMeasure {
        let (notesHolderIndex, repeatMeasureIndex) = try notesHolderIndexFromMeasureIndex(measureIndex)
        if let measureRepeat = notesHolders[notesHolderIndex] as? MeasureRepeat,
            let repeatMeasureIndex = repeatMeasureIndex {
            return measureRepeat.expand()[repeatMeasureIndex]
        } else if let measure = notesHolders[notesHolderIndex] as? ImmutableMeasure {
            return measure
        }
        throw StaffError.InternalError
	}
	
	public func measureRepeatAtIndex(measureIndex: Int) throws -> MeasureRepeat? {
        let (notesHolderIndex, _) = try notesHolderIndexFromMeasureIndex(measureIndex)
        return notesHolders[notesHolderIndex] as? MeasureRepeat
	}
	
	internal func notesHolderAtMeasureIndex(measureIndex: Int) throws -> NotesHolder {
        let (notesHolderIndex, _) = try notesHolderIndexFromMeasureIndex(measureIndex)
        return notesHolders[notesHolderIndex]
	}
	
    private mutating func modifyTieForNoteAtIndex(noteIndex: Int, inMeasureAtIndex measureIndex: Int, removeTie: Bool) throws {
		let notesHolderIndex = try notesHolderIndexFromMeasureIndex(measureIndex)

        // Ensure first measure information provided is valid for tie
        var firstMeasure = try mutableMeasureFromNotesHolderIndex(notesHolderIndex.notesHolderIndex, repeatMeasureIndex: notesHolderIndex.repeatMeasureIndex)
        guard noteIndex < firstMeasure.noteCount else {
            throw StaffError.NoteIndexOutOfRange
        }

        // Get second measure if needed (tie starts on last note of measure)
        var secondMeasure: Measure?
        if noteIndex == firstMeasure.noteCount - 1 {
            let secondNotesHolderIndex: (notesHolderIndex: Int, repeatMeasureIndex: Int?)
            do {
                secondNotesHolderIndex = try notesHolderIndexFromMeasureIndex(measureIndex + 1)
            } catch {
                throw StaffError.NoNextNoteToTie
            }
            secondMeasure = try mutableMeasureFromNotesHolderIndex(secondNotesHolderIndex.notesHolderIndex, repeatMeasureIndex: secondNotesHolderIndex.repeatMeasureIndex)
            guard secondMeasure?.noteCount > 0 else {
                throw StaffError.NoNextNote
            }
        } else {
            secondMeasure = nil
        }

        // Modify tie
        if secondMeasure != nil {
            try firstMeasure.modifyTieAtIndex(noteIndex, requestedTieState: removeTie ? nil : .Begin )
            try secondMeasure?.modifyTieAtIndex(0, requestedTieState: removeTie ? nil : .End)
        } else {
            if removeTie {
                try firstMeasure.removeTieAtIndex(noteIndex)
            } else {
                try firstMeasure.startTieAtIndex(noteIndex)
            }
        }

        // Set new measures in the staff
        try replaceMeasureAtIndex(measureIndex, withNewMeasure: firstMeasure)
        if let secondMeasure = secondMeasure {
            try replaceMeasureAtIndex(measureIndex + 1, withNewMeasure: secondMeasure)
        }
	}
	
	internal func notesHolderIndexFromMeasureIndex(index: Int) throws -> (notesHolderIndex: Int, repeatMeasureIndex: Int?) {
        guard index >= 0 && index < measureCount else { throw StaffError.MeasureIndexOutOfRange }
        return measureIndexes[index]
	}

    private mutating func recomputeMeasureIndexes() {
        measureIndexes = []
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
    }

    private func mutableMeasureFromNotesHolderIndex(notesHolderIndex: Int, repeatMeasureIndex: Int?) throws -> Measure {
        let notesHolder = notesHolders[notesHolderIndex]
        // Ensure first measure information provided is valid for tie
        if let repeatMeasureIndex = repeatMeasureIndex {
            // If repeatMeasureIndex is not nil, check if measure is not a repeated one
            // If it's not, check if noteIndex is less than count of measure
            guard let measureRepeat = notesHolder as? MeasureRepeat else {
                assertionFailure("Index translation showed should be a repeat, but it's not")
                throw StaffError.InternalError
            }
            guard let mutableMeasure = measureRepeat.expand()[repeatMeasureIndex] as? Measure else {
                throw StaffError.RepeatedMeasureCannotHaveTie
            }
            return mutableMeasure
        } else {
            // If repeatMeasureIndex is nil, check if the noteIndex is less than note count of measure
            assert(notesHolder.measureCount == 1, "Index translation showed should be a single measure, but it's not")
            guard let immutableMeasure = notesHolder as? ImmutableMeasure else {
                throw StaffError.InternalError
            }
            if let mutableMeasure = immutableMeasure as? Measure {
                return mutableMeasure
            } else {
                assertionFailure("If not a repeated measure, should be a mutable measure")
                throw StaffError.InternalError
            }
        }
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
    case RepeatedMeasureCannotBeModified
    case InternalError
}

extension Staff: CustomDebugStringConvertible {
	public var debugDescription: String {
		return "staff(\(clef) \(instrument))"
	}
}
