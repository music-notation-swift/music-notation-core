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
    public private(set) var notes: [NoteCollection] {
        didSet {
            // We call this expensive operation every time you modify the notes, because
            // setting notes should be done more infrequently than the others operations that rely on it.
            recomputeNoteCollectionIndexes()
        }
    }
    public private(set) var noteCount: Int
    public let measureCount: Int = 1

    internal typealias NoteCollectionIndex = (noteIndex: Int, tupletIndex: Int?)
    private var noteCollectionIndexes: [NoteCollectionIndex] = []

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
        recomputeNoteCollectionIndexes()
    }

    public init(_ immutableMeasure: ImmutableMeasure) {
        timeSignature = immutableMeasure.timeSignature
        key = immutableMeasure.key
        notes = immutableMeasure.notes
        noteCount = immutableMeasure.noteCount
        recomputeNoteCollectionIndexes()
    }

    public mutating func addNote(_ note: Note) {
        notes.append(note)
        noteCount += note.noteCount
    }

	public mutating func insertNote(_ note: Note, at index: Int, beforeTuplet: Bool = true) throws {
		let noteCollectionIndex = try noteCollectionIndexFromNoteIndex(index)
		
		// Not a repeat, just insert
		if noteCollectionIndex.tupletIndex == nil {
			notes.insert(note, at: noteCollectionIndex.noteIndex)
			noteCount += note.noteCount
		} else {
			if beforeTuplet && noteCollectionIndex.tupletIndex == 0 {
				notes.insert(note, at: noteCollectionIndex.noteIndex)
				noteCount += note.noteCount
				return
			}
			
			guard var tuplet = notes[noteCollectionIndex.noteIndex] as? Tuplet,
				let tupletIndex = noteCollectionIndex.tupletIndex else {
					assertionFailure("Index translation showed should be a tuplet, but it's not")
					throw MeasureError.internalError
			}
			try tuplet.insertNote(note, at: tupletIndex)
			notes[noteCollectionIndex.noteIndex] = tuplet
		}
    }

	// TODO: Pending Tuplet implementation details. If tuplets become inmutable, then the 
	// implementation will have to change.
	//
	// TODO: What should be the behavior when Tuplet notes count <= 2. If trying to remove a
	// note from a tuplet of two notes, convert the remaining note into a Note?
	public mutating func removeNote(at index: Int, removeTuplet: Bool = true) throws {
        let noteCollectionIndex = try noteCollectionIndexFromNoteIndex(index)
		
		let requestedNoteCurrentTie = try tieStateForNoteIndex(noteCollectionIndex)
		if requestedNoteCurrentTie != nil {
			throw MeasureError.invalidRequestedTieState
		}
		
		if noteCollectionIndex.tupletIndex == nil {
			guard let note = notes[noteCollectionIndex.noteIndex] as? Note else {
				assertionFailure("NoteCollection was not a Note as expected")
				throw MeasureError.internalError
			}
			notes.remove(at: noteCollectionIndex.noteIndex)
			noteCount -= note.noteCount
		} else {
			if removeTuplet && noteCollectionIndex.tupletIndex == 0 {
				notes.remove(at: noteCollectionIndex.noteIndex)
				return
			}
			
			guard var tuplet = notes[noteCollectionIndex.noteIndex] as? Tuplet,
				let tupletIndex = noteCollectionIndex.tupletIndex else {
				assertionFailure("Index translation showed should be a tuplet, but it's not")
				throw MeasureError.internalError
			}
			try tuplet.removeNote(at: tupletIndex)
			if tuplet.noteCount == 0 {
				notes.remove(at: noteCollectionIndex.noteIndex)
				return
			}
			
			notes[noteCollectionIndex.noteIndex] = tuplet
		}
    }

	// Remove notes from range. Tuplet instances within the range are
	// removed as well. Removes entire Tuplet if the end portion of the 
	// range falls within the note range of a Tuplet.
	// TODO: Need to talk about how the indexRange works. This needs to be
	// documented. Revisit staff insert measure.
	// TODO: Don't care about removing tuplets and notes within the range?
    public mutating func removeNotesInRange(_ indexRange: Range<Int>) throws {
        // TODO: Check for invalid tie issues. Only allow a closed tie (start-end)
		// between the range, or no tie at all. This includes checking ties
		// inside Tuplets.
		let start = try noteCollectionIndexFromNoteIndex(indexRange.lowerBound)
		let end = try noteCollectionIndexFromNoteIndex(indexRange.upperBound)
		notes.removeSubrange(start.noteIndex...end.noteIndex)
    }

    public mutating func addTuplet(_ tuplet: Tuplet) {
        notes.append(tuplet)
    }
	
	// TODO: Is it  okay to insert things between ties?
    public mutating func insertTuplet(_ tuplet: Tuplet, at index: Int) throws {
		let noteCollectionIndex = try noteCollectionIndexFromNoteIndex(index)
		// TODO: make sure that index does not belong to a tuplet note.
		notes.insert(tuplet, at: noteCollectionIndex.noteIndex)
    }

	// TODO: Take into account ties.
    public mutating func removeTuplet(_ tuplet: Tuplet, at index: Int) throws {
		let noteCollectionIndex = try noteCollectionIndexFromNoteIndex(index)
		if noteCollectionIndex.tupletIndex == nil {
			throw MeasureError.noTieAtIndex
		}
		notes.remove(at: noteCollectionIndex.noteIndex)
    }

    internal mutating func startTie(at index: Int) throws {
        try modifyTie(at: index, requestedTieState: .begin)
    }

    internal mutating func removeTie(at index: Int) throws {
        try modifyTie(at: index, requestedTieState: nil)
    }

    internal mutating func modifyTie(at index: Int, requestedTieState: Tie?) throws {
        guard requestedTieState != .beginAndEnd else {
            throw MeasureError.invalidRequestedTieState
        }
        let requestedIndex = try noteCollectionIndexFromNoteIndex(index)
        let secondaryIndex: (noteIndex: Int, tupletIndex: Int?)?
        let secondaryRequestedTieState: Tie

		let requestedNoteCurrentTie = try tieStateForNoteIndex(requestedIndex)

        // Calculate secondary Index and tie states //
        let removal = requestedTieState == nil
        let primaryRequestedTieState: Tie

        // In the case of no previous or next note to do the secondary operation, just do the primary, because
        // it could be that the note that is needed is in the preceding or following measure.
        // This is why secondaryIndex is sometimes nil.
        switch (requestedTieState, requestedNoteCurrentTie) {
        case (let request, let current) where request == current:
            return
        case (nil, .begin?):
            secondaryIndex = try? noteCollectionIndexFromNoteIndex(index + 1)
            secondaryRequestedTieState = .end
            primaryRequestedTieState = .begin
        case (nil, .end?):
            secondaryIndex = try? noteCollectionIndexFromNoteIndex(index - 1)
            secondaryRequestedTieState = .begin
            primaryRequestedTieState = .end
        case (nil, .beginAndEnd?):
            // Default to removing the tie as if the requested index is the beginning, because that
            // makes the most sense and we don't want to fail here.
            secondaryIndex = try? noteCollectionIndexFromNoteIndex(index + 1)
            secondaryRequestedTieState = .end
            primaryRequestedTieState = .begin
        case (.begin?, nil):
            secondaryIndex = try? noteCollectionIndexFromNoteIndex(index + 1)
            secondaryRequestedTieState = .end
            primaryRequestedTieState = requestedTieState!
        case (.begin?, .end?):
            secondaryIndex = try? noteCollectionIndexFromNoteIndex(index + 1)
            secondaryRequestedTieState = .end
            primaryRequestedTieState = requestedTieState!
        case (.begin?, .beginAndEnd?):
            throw MeasureError.invalidRequestedTieState
        case (.end?, nil):
            secondaryIndex = try? noteCollectionIndexFromNoteIndex(index - 1)
            secondaryRequestedTieState = .begin
            primaryRequestedTieState = requestedTieState!
        case (.end?, .begin?):
            secondaryIndex = try? noteCollectionIndexFromNoteIndex(index - 1)
            secondaryRequestedTieState = .begin
            primaryRequestedTieState = requestedTieState!
        case (.end?, .beginAndEnd?):
            throw MeasureError.invalidRequestedTieState
        default:
            throw MeasureError.invalidRequestedTieState
        }

        // Modify the ties of the notes involved //
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
            try tuplet.replaceNote(at: secondTupletIndex, with: secondNote)
            notes[secondaryIndex.noteIndex] = tuplet
        case let (firstTupletIndex?, nil):
            var tuplet = notes[requestedIndex.noteIndex] as! Tuplet
            firstNote = tuplet.notes[firstTupletIndex]
            try requestedModificationMethod(&firstNote)(primaryRequestedTieState)
            try tuplet.replaceNote(at: firstTupletIndex, with: firstNote)
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
                try tuplet.replaceNote(at: firstTupletIndex, with: firstNote)
                secondNote = tuplet.notes[secondTupletIndex]
                try secondaryModificationMethod(&secondNote)(secondaryRequestedTieState)
                try tuplet.replaceNote(at: secondTupletIndex, with: secondNote)
                notes[requestedIndex.noteIndex] = tuplet
            } else {
                var firstTuplet = notes[requestedIndex.noteIndex] as! Tuplet
                firstNote = firstTuplet.notes[firstTupletIndex]
                try requestedModificationMethod(&firstNote)(primaryRequestedTieState)
                try firstTuplet.replaceNote(at: firstTupletIndex, with: firstNote)
                notes[requestedIndex.noteIndex] = firstTuplet
                guard let secondaryIndex = secondaryIndex else {
                    break
                }
                var secondTuplet = notes[secondaryIndex.noteIndex] as! Tuplet
                secondNote = secondTuplet.notes[secondTupletIndex]
                try secondaryModificationMethod(&secondNote)(secondaryRequestedTieState)
                try secondTuplet.replaceNote(at: secondTupletIndex, with: secondNote)
                notes[secondaryIndex.noteIndex] = secondTuplet
            }
        }
    }

    internal func noteCollectionIndexFromNoteIndex(_ index: Int) throws -> NoteCollectionIndex {
        // Gets the index of the given element in the notes array by translating the index of the
        // single note within the NoteCollection array.
        guard index >= 0 && notes.count > 0 else { throw MeasureError.noteIndexOutOfRange }
        // Expand notes and tuplets into indexes
        guard index < noteCollectionIndexes.count else { throw MeasureError.noteIndexOutOfRange }
        return noteCollectionIndexes[index]
    }

    private mutating func recomputeNoteCollectionIndexes() {
        noteCollectionIndexes = []
        for (i, noteCollection) in notes.enumerated() {
            switch noteCollection.noteCount {
            case 1:
                noteCollectionIndexes.append((noteIndex: i, tupletIndex: nil))
            case let count:
                for j in 0..<count {
                    noteCollectionIndexes.append((noteIndex: i, tupletIndex: j))
                }
            }
        }
    }

	private func tieStateForNoteIndex(_ index: NoteCollectionIndex) throws -> Tie? {
        if let tupletIndex = index.tupletIndex {
            guard let tuplet = notes[index.noteIndex] as? Tuplet else {
                assertionFailure("NoteCollection was not a Tuplet as expected")
                throw MeasureError.internalError
            }
            return tuplet.notes[tupletIndex].tie
        } else {
            guard let note = notes[index.noteIndex] as? Note else {
                assertionFailure("NoteCollection was not a Note as expected")
                throw MeasureError.internalError
            }
            return note.tie
        }
    }
}

extension Measure: Equatable {
    public static func ==(lhs: Measure, rhs: Measure) -> Bool {
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
}

// Debug extensions
extension Measure: CustomDebugStringConvertible {
    public var debugDescription: String {
        let notesString = notes.map { "\($0)" }.joined(separator: ",")
        return "|\(timeSignature): \(notesString)|"
    }
}

public enum MeasureError: Error {
    case noTieBeginsAtIndex
    case noteIndexOutOfRange
    case noNextNote
    case invalidRequestedTieState
    case internalError
	case noTieAtIndex
}
