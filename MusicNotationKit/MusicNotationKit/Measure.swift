//
//  Measure.swift
//  MusicNotation
//
//  Created by Kyle Sherman on 6/12/15.
//  Copyright (c) 2015 Kyle Sherman. All rights reserved.
//

public struct Measure: ImmutableMeasure, Equatable {

    public let timeSignature: TimeSignature
    public let key: Key
    public private(set) var notes: [[NoteCollection]] {
        didSet {
            // We call this expensive operation every time you modify the notes, because
            // setting notes should be done more infrequently than the others operations that rely on it.
            recomputeNoteCollectionIndexes()
        }
    }
    public private(set) var noteCount: [Int]
    public let measureCount: Int = 1

    internal typealias NoteCollectionIndex = (noteIndex: Int, tupletIndex: Int?)
    private var noteCollectionIndexes: [[NoteCollectionIndex]] = [[NoteCollectionIndex]]()

    public init(timeSignature: TimeSignature, key: Key) {
        self.init(timeSignature: timeSignature, key: key, notes: [[]])
    }

    public init(timeSignature: TimeSignature, key: Key, notes: [[NoteCollection]]) {
        self.timeSignature = timeSignature
        self.key = key
        self.notes = notes
        noteCount = notes.map {
            $0.reduce(0) { prev, noteCollection in
                return prev + noteCollection.noteCount
            }
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
	
	public func note(at index: Int, inSet setIndex: Int) throws -> Note {
		let noteCollectionIndex = try noteCollectionIndexFromNoteIndex(index, inSet: setIndex)
		var noteIndex = 0
		if noteCollectionIndex.tupletIndex != nil {
			noteIndex = noteCollectionIndex.tupletIndex!
		}
		return try notes[setIndex][noteCollectionIndex.noteIndex].note(at: noteIndex)
	}

	public mutating func replaceNote(at index: Int, inSet setIndex: Int, with note: Note) throws {
		let noteCollectionIndex = try noteCollectionIndexFromNoteIndex(index, inSet: setIndex)
		if noteCollectionIndex.tupletIndex == nil {
			notes[setIndex][noteCollectionIndex.noteIndex] = note
			return
		}
		
		guard var tuplet = notes[setIndex][noteCollectionIndex.noteIndex] as? Tuplet,
			let tupletIndex = noteCollectionIndex.tupletIndex else {
			throw MeasureError.internalError
		}
		try tuplet.replaceNote(at: tupletIndex, with: note)
		notes[setIndex][noteCollectionIndex.noteIndex] = tuplet
	}
	
    public mutating func addNote(_ note: Note, inSet setIndex: Int = 0) {
        notes[setIndex].append(note)
        noteCount[setIndex] += note.noteCount
    }
	
    public mutating func insertNote(_ note: Note, at index: Int, inSet setIndex: Int = 0) throws {
        // TODO: Implement
    }

    public mutating func removeNote(at index: Int, inSet setIndex: Int = 0) throws {
        // TODO: Implement
    }

    public mutating func removeNotesInRange(_ indexRange: Range<Int>, inSet setIndex: Int = 0) throws {
        // TODO: Implement
    }

    public mutating func addTuplet(_ tuplet: Tuplet, inSet setIndex: Int = 0) {
        notes[setIndex].append(tuplet)
		noteCount[setIndex] += tuplet.noteCount
    }

    public mutating func insertTuplet(_ tuplet: Tuplet, at index: Int, inSet setIndex: Int = 0) throws {
        // TODO: Implement
    }

    public mutating func removeTuplet(_ tuplet: Tuplet, at index: Int, inSet setIndex: Int = 0) throws {
        // TODO: Implement
    }

    internal mutating func startTie(at index: Int, inSet setIndex: Int) throws {
        try modifyTie(at: index, requestedTieState: .begin, inSet: setIndex)
    }

    internal mutating func removeTie(at index: Int, inSet setIndex: Int) throws {
        try modifyTie(at: index, requestedTieState: nil, inSet: setIndex)
    }

    internal mutating func modifyTie(at index: Int, requestedTieState: Tie?, inSet setIndex: Int) throws {
        guard requestedTieState != .beginAndEnd else {
            throw MeasureError.invalidRequestedTieState
        }
        let secondaryIndex: Int
        let secondaryRequestedTieState: Tie

        let requestedNoteCurrentTie = try tieStateForNoteIndex(index, inSet: setIndex)

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
            secondaryIndex = index + 1
            secondaryRequestedTieState = .end
            primaryRequestedTieState = .begin
        case (nil, .end?):
            secondaryIndex = index - 1
            secondaryRequestedTieState = .begin
            primaryRequestedTieState = .end
        case (nil, .beginAndEnd?):
            // Default to removing the tie as if the requested index is the beginning, because that
            // makes the most sense and we don't want to fail here.
            secondaryIndex = index + 1
            secondaryRequestedTieState = .end
            primaryRequestedTieState = .begin
        case (.begin?, nil):
            secondaryIndex = index + 1
            secondaryRequestedTieState = .end
            primaryRequestedTieState = requestedTieState!
        case (.begin?, .end?):
            secondaryIndex = index + 1
            secondaryRequestedTieState = .end
            primaryRequestedTieState = requestedTieState!
        case (.begin?, .beginAndEnd?):
            throw MeasureError.invalidRequestedTieState
        case (.end?, nil):
            secondaryIndex = index - 1
            secondaryRequestedTieState = .begin
            primaryRequestedTieState = requestedTieState!
        case (.end?, .begin?):
            secondaryIndex = index - 1
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

		var firstNote = try note(at: index, inSet: setIndex)
		try requestedModificationMethod(&firstNote)(primaryRequestedTieState)
		try replaceNote(at: index, inSet: setIndex, with: firstNote)
		
		if secondaryIndex < noteCount[setIndex] && secondaryIndex >= 0 {
			var secondNote = try note(at: secondaryIndex, inSet: setIndex)
			try secondaryModificationMethod(&secondNote)(secondaryRequestedTieState)
			try replaceNote(at: secondaryIndex, inSet: setIndex, with: secondNote)
		}
    }

    internal func noteCollectionIndexFromNoteIndex(_ index: Int, inSet setIndex: Int) throws -> NoteCollectionIndex {
        // Gets the index of the given element in the notes array by translating the index of the
        // single note within the NoteCollection array.
        guard index >= 0 && notes[setIndex].count > 0 else { throw MeasureError.noteIndexOutOfRange }
        // Expand notes and tuplets into indexes
        guard index < noteCollectionIndexes[setIndex].count else { throw MeasureError.noteIndexOutOfRange }
        return noteCollectionIndexes[setIndex][index]
    }

    private mutating func recomputeNoteCollectionIndexes() {
        noteCollectionIndexes = [[NoteCollectionIndex]]()
        for noteSet in notes {
            var noteSetIndexes: [NoteCollectionIndex] = []
            for (i, noteCollection) in noteSet.enumerated() {
                switch noteCollection.noteCount {
                case 1:
                    noteSetIndexes.append((noteIndex: i, tupletIndex: nil))
                case let count:
                    for j in 0..<count {
                        noteSetIndexes.append((noteIndex: i, tupletIndex: j))
                    }
                }
            }
            noteCollectionIndexes.append(noteSetIndexes)
        }
    }

    private func tieStateForNoteIndex(_ index: Int, inSet setIndex: Int) throws -> Tie? {
		return try note(at: index, inSet: setIndex).tie
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
}
