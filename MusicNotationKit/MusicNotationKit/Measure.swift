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

    public mutating func insertNote(_ note: Note, at index: Int) throws {
        // TODO: Implement
    }

    public mutating func removeNote(at index: Int) throws {
        // TODO: Implement
    }

    public mutating func removeNotesInRange(_ indexRange: Range<Int>) throws {
        // TODO: Implement
    }

    public mutating func addTuplet(_ tuplet: Tuplet) {
        notes.append(tuplet)
    }

    public mutating func insertTuplet(_ tuplet: Tuplet, at index: Int) throws {
        // TODO: Implement
    }

    public mutating func removeTuplet(_ tuplet: Tuplet, at index: Int) throws {
        // TODO: Implement
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

        let requestedNoteCurrentTie = try tieStateForNoteIndex(requestedIndex.noteIndex, tupletIndex: requestedIndex.tupletIndex)

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

    private func tieStateForNoteIndex(_ noteIndex: Int, tupletIndex: Int?) throws -> Tie? {
        if let tupletIndex = tupletIndex {
            guard let tuplet = notes[noteIndex] as? Tuplet else {
                assertionFailure("NoteCollection was not a Tuplet as expected")
                throw MeasureError.internalError
            }
            return tuplet.notes[tupletIndex].tie
        } else {
            guard let note = notes[noteIndex] as? Note else {
                assertionFailure("NoteCollection was not a Note as expected")
                throw MeasureError.internalError
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
        let notesString = notes.map { "\($0)" }.joined(separator: ",")
        return "|\(timeSignature): \(notesString)|"
    }
}

public enum MeasureError: ErrorProtocol {
    case noTieBeginsAtIndex
    case noteIndexOutOfRange
    case noNextNote
    case invalidRequestedTieState
    case internalError
}
