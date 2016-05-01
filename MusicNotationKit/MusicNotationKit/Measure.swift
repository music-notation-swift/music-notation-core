//
//  Measure.swift
//  MusicNotation
//
//  Created by Kyle Sherman on 6/12/15.
//  Copyright (c) 2015 Kyle Sherman. All rights reserved.
//

public struct Measure: ImmutableMeasure {
	
	public let timeSignature: TimeSignature
	public let key: Key
	public private(set) var notes: [NoteCollection]
    public private(set) var noteCount: Int
    public let measureCount: Int = 1
	
	public init(timeSignature: TimeSignature, key: Key) {
		self.init(timeSignature: timeSignature, key: key, notes: [])
	}
	
	public init(timeSignature: TimeSignature, key: Key, notes: [NoteCollection]) {
		self.timeSignature = timeSignature
		self.key = key
		self.notes = notes
        noteCount = notes.reduce(0) { prev, noteCollection in
            return prev + noteCollection.noteCount
        }
	}
	
	public mutating func addNote(note: Note) {
		notes.append(note)
        noteCount += note.noteCount
	}
	
	public mutating func insertNote(note: Note, atIndex index: Int) throws {
		// TODO: Implement
	}
	
	public mutating func removeNoteAtIndex(index: Int) throws {
		// TODO: Implement
	}
	
	public mutating func removeNotesInRange(indexRange: Range<Int>) throws {
		// TODO: Implement
	}
	
	public mutating func addTuplet(tuplet: Tuplet) {
		notes.append(tuplet)
	}
	
	public mutating func insertTuplet(tuplet: Tuplet, atIndex index: Int) throws {
		// TODO: Implement
	}
	
	public mutating func removeTuplet(tuplet: Tuplet, atIndex index: Int) throws {
		// TODO: Implement
	}
	
	public mutating func startTieAtIndex(index: Int) throws {
		try modifyTieAtIndex(index, requestedTieState: .Begin)
	}
	
	public mutating func removeTieAtIndex(index: Int) throws {
		try modifyTieAtIndex(index, requestedTieState: nil)
	}
	
	internal mutating func modifyTieAtIndex(index: Int, requestedTieState: Tie?) throws {
        guard requestedTieState != .BeginAndEnd else {
            throw MeasureError.InvalidRequestedTieState
        }
		let requestedIndex = try noteCollectionIndexFromNoteIndex(index)
        let secondaryIndex: (noteIndex: Int, tupletIndex: Int?)?
        let secondaryRequestedTieState: Tie

        let requestedNoteCurrentTie = try tieStateForNoteIndex(requestedIndex.noteIndex, tupletIndex: requestedIndex.tupletIndex)

        let removal = requestedTieState == nil
        let primaryRequestedTieState: Tie
        // In the case of no previous or next note to do the secondary operation, just do the primary, because
        // it could be that the note that is needed is in the preceding or following measure.
        // This is why secondaryIndex is sometimes nil.
        switch (requestedTieState, requestedNoteCurrentTie) {
        case (let request, let current) where request == current:
            return
        case (nil, .Begin?):
            secondaryIndex = try? noteCollectionIndexFromNoteIndex(index + 1)
            secondaryRequestedTieState = .End
            primaryRequestedTieState = .Begin
        case (nil, .End?):
            secondaryIndex = try? noteCollectionIndexFromNoteIndex(index - 1)
            secondaryRequestedTieState = .Begin
            primaryRequestedTieState = .End
        case (nil, .BeginAndEnd?):
            // Default to removing the tie as if the requested index is the beginning, because that
            // makes the most sense and we don't want to fail here.
            secondaryIndex = try? noteCollectionIndexFromNoteIndex(index + 1)
            secondaryRequestedTieState = .End
            primaryRequestedTieState = .Begin
        case (.Begin?, nil):
            secondaryIndex = try? noteCollectionIndexFromNoteIndex(index + 1)
            secondaryRequestedTieState = .End
            primaryRequestedTieState = requestedTieState!
        case (.Begin?, .End?):
            secondaryIndex = try? noteCollectionIndexFromNoteIndex(index + 1)
            secondaryRequestedTieState = .End
            primaryRequestedTieState = requestedTieState!
        case (.Begin?, .BeginAndEnd?):
            throw MeasureError.InvalidRequestedTieState
        case (.End?, nil):
            secondaryIndex = try? noteCollectionIndexFromNoteIndex(index - 1)
            secondaryRequestedTieState = .Begin
            primaryRequestedTieState = requestedTieState!
        case (.End?, .Begin?):
            secondaryIndex = try? noteCollectionIndexFromNoteIndex(index - 1)
            secondaryRequestedTieState = .Begin
            primaryRequestedTieState = requestedTieState!
        case (.End?, .BeginAndEnd?):
            throw MeasureError.InvalidRequestedTieState
        default:
            throw MeasureError.InvalidRequestedTieState
        }

        let requestedModificationMethod = requestedTieState == nil ? Note.removeTie : Note.modifyTie
        let secondaryModificationMethod = removal ? Note.removeTie : Note.modifyTie

		var firstNote: Note
		var secondNote: Note
		switch (requestedIndex.tupletIndex, secondaryIndex?.tupletIndex) {
		case (nil, nil):
			firstNote = notes[requestedIndex.noteIndex] as! Note
            try requestedModificationMethod(&firstNote)(primaryRequestedTieState)
            notes[requestedIndex.noteIndex] = firstNote
            guard let secondaryIndex = secondaryIndex else {
                break
            }
            secondNote = notes[secondaryIndex.noteIndex] as! Note
            try secondaryModificationMethod(&secondNote)(secondaryRequestedTieState)
            notes[secondaryIndex.noteIndex] = secondNote
		case let (nil, secondTupletIndex?):
			firstNote = notes[requestedIndex.noteIndex] as! Note
            try requestedModificationMethod(&firstNote)(primaryRequestedTieState)
            notes[requestedIndex.noteIndex] = firstNote
            guard let secondaryIndex = secondaryIndex else {
                break
            }
			var tuplet = notes[secondaryIndex.noteIndex] as! Tuplet
			secondNote = tuplet.notes[secondTupletIndex]
			try secondaryModificationMethod(&secondNote)(secondaryRequestedTieState)
			try tuplet.replaceNoteAtIndex(secondTupletIndex, withNote: secondNote)
			notes[secondaryIndex.noteIndex] = tuplet
		case let (firstTupletIndex?, nil):
			var tuplet = notes[requestedIndex.noteIndex] as! Tuplet
			firstNote = tuplet.notes[firstTupletIndex]
            try requestedModificationMethod(&firstNote)(primaryRequestedTieState)
            try tuplet.replaceNoteAtIndex(firstTupletIndex, withNote: firstNote)
            notes[requestedIndex.noteIndex] = tuplet
            guard let secondaryIndex = secondaryIndex else {
                break
            }
			secondNote = notes[secondaryIndex.noteIndex] as! Note
			try secondaryModificationMethod(&secondNote)(secondaryRequestedTieState)
			notes[secondaryIndex.noteIndex] = secondNote
		case let (firstTupletIndex?, secondTupletIndex?):
			if requestedIndex.noteIndex == secondaryIndex?.noteIndex {
				var tuplet = notes[requestedIndex.noteIndex] as! Tuplet
				firstNote = tuplet.notes[firstTupletIndex]
                try requestedModificationMethod(&firstNote)(primaryRequestedTieState)
                try tuplet.replaceNoteAtIndex(firstTupletIndex, withNote: firstNote)
				secondNote = tuplet.notes[secondTupletIndex]
				try secondaryModificationMethod(&secondNote)(secondaryRequestedTieState)
				try tuplet.replaceNoteAtIndex(secondTupletIndex, withNote: secondNote)
                notes[requestedIndex.noteIndex] = tuplet
			} else {
				var firstTuplet = notes[requestedIndex.noteIndex] as! Tuplet
				firstNote = firstTuplet.notes[firstTupletIndex]
                try requestedModificationMethod(&firstNote)(primaryRequestedTieState)
                try firstTuplet.replaceNoteAtIndex(firstTupletIndex, withNote: firstNote)
                notes[requestedIndex.noteIndex] = firstTuplet
                guard let secondaryIndex = secondaryIndex else {
                    break
                }
				var secondTuplet = notes[secondaryIndex.noteIndex] as! Tuplet
				secondNote = secondTuplet.notes[secondTupletIndex]
				try secondaryModificationMethod(&secondNote)(secondaryRequestedTieState)
				try secondTuplet.replaceNoteAtIndex(secondTupletIndex, withNote: secondNote)
				notes[secondaryIndex.noteIndex] = secondTuplet
			}
		}
	}
	
	internal func noteCollectionIndexFromNoteIndex(index: Int) throws -> (noteIndex: Int, tupletIndex: Int?) {
		// Gets the index of the given element in the notes array by translating the index of the
		// single note within the NoteCollection array.
		guard index >= 0 && notes.count > 0 else { throw MeasureError.NoteIndexOutOfRange }
		// Expand notes and tuplets into indexes
		// TODO: Move this into a method that is called on didSet of notes??
		var noteIndexes: [(Int, Int?)] = []
		for (i, noteCollection) in notes.enumerate() {
			switch noteCollection.noteCount {
			case 1:
				noteIndexes.append((noteIndex: i, tupletIndex: nil))
			case let count:
				for j in 0..<count {
					noteIndexes.append((noteIndex: i, tupletIndex: j))
				}
			}
		}
		guard index < noteIndexes.count else { throw MeasureError.NoteIndexOutOfRange }
		return noteIndexes[index]
	}

    private func tieStateForNoteIndex(noteIndex: Int, tupletIndex: Int?) throws -> Tie? {
        if let tupletIndex = tupletIndex {
            guard let tuplet = notes[noteIndex] as? Tuplet else {
                assertionFailure("NoteCollection was not a Tuplet as expected")
                throw MeasureError.InternalError
            }
            return tuplet.notes[tupletIndex].tie
        } else {
            guard let note = notes[noteIndex] as? Note else {
                assertionFailure("NoteCollection was not a Note as expected")
                throw MeasureError.InternalError
            }
            return note.tie
        }
    }
}

extension Measure: Equatable {}

public func ==(lhs: Measure, rhs: Measure) -> Bool {
	guard lhs.timeSignature == rhs.timeSignature &&
		lhs.key == rhs.key &&
		lhs.notes.count == rhs.notes.count else {
			return false
	}
	for i in 0..<lhs.notes.count {
		if lhs.notes[i] == rhs.notes[i] {
			continue
		} else {
			return false
		}
	}
	return true
}

// Debug extensions
extension Measure: CustomDebugStringConvertible {
	public var debugDescription: String {
		let notesString = notes.map { "\($0)" }.joinWithSeparator(",")
		return "|\(timeSignature): \(notesString)|"
	}
}

public enum MeasureError: ErrorType {
	case NoTieBeginsAtIndex
	case NoteIndexOutOfRange
	case NoNextNote
    case InvalidRequestedTieState
    case InternalError
}
