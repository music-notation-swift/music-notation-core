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

    public func note(at index: Int, inSet setIndex: Int = 0) throws -> Note {
        let collectionIndex = try noteCollectionIndex(fromNoteIndex: index, inSet: setIndex)
        let noteIndex = collectionIndex.tupletIndex ?? 0
        return try notes[setIndex][collectionIndex.noteIndex].note(at: noteIndex)
    }

    public mutating func replaceNote(at index: Int, with note: Note, inSet setIndex: Int = 0) throws {
        let collectionIndex = try noteCollectionIndex(fromNoteIndex: index, inSet: setIndex)

        guard let tupletIndex = collectionIndex.tupletIndex else {
            notes[setIndex][collectionIndex.noteIndex] = note
            return
        }

        guard var tuplet = notes[setIndex][collectionIndex.noteIndex] as? Tuplet  else {
            assertionFailure("note collection should be tuplet, but cast failed")
            throw MeasureError.internalError
        }
        try tuplet.replaceNote(at: tupletIndex, with: note)
        notes[setIndex][collectionIndex.noteIndex] = tuplet
    }

    public mutating func addNote(_ note: Note, inSet setIndex: Int = 0) {
        notes[setIndex].append(note)
        noteCount[setIndex] += note.noteCount
    }

    public mutating func insertNote(_ note: Note, at index: Int, inSet setIndex: Int = 0) throws {
        let collectionIndex = try noteCollectionIndex(fromNoteIndex: index, inSet: setIndex)

        guard collectionIndex.tupletIndex == nil else {
            throw MeasureError.insertNoteIntoTupletNotAllowed
        }
        try prepTiesForInsertion(at: index, inSet: setIndex)
        notes[setIndex].insert(note, at: collectionIndex.noteIndex)
    }

    public mutating func removeNote(at index: Int, inSet setIndex: Int = 0) throws {
        let collectionIndex = try noteCollectionIndex(fromNoteIndex: index, inSet: setIndex)
        guard collectionIndex.tupletIndex == nil else {
            throw MeasureError.removeNoteFromTuplet
        }
        try prepTiesForRemoval(at: index, inSet: setIndex)
        notes[setIndex].remove(at: collectionIndex.noteIndex)
    }

    public mutating func removeNotesInRange(_ indexRange: Range<Int>, inSet setIndex: Int = 0) throws {
        let start = indexRange.lowerBound
        let end = indexRange.upperBound
        // TODO: Check for tie state at boundaries.
        for index in (start..<end).reversed() {
            let collectionIndex = try noteCollectionIndex(fromNoteIndex: index, inSet: setIndex)
            notes[setIndex].remove(at: collectionIndex.noteIndex)
        }
    }

    public mutating func addTuplet(_ tuplet: Tuplet, inSet setIndex: Int = 0) {
        notes[setIndex].append(tuplet)
        noteCount[setIndex] += tuplet.noteCount
    }

    // Create a `Tuplet` from a note range. 
    // The note count is inferred from `noteRange`, but `baseNoteDuration` needs to be specified.
    // `inSpaceOf` can be used to specify an non-standard Tuplet ratio. See `Tuplet.init` for
    // more details.
    public mutating func createTuplet(_ baseNoteDuration: NoteDuration, inSpaceOf baseCount: Int? = nil, fromNotesInRange noteRange: Range<Int>, inSet setIndex: Int = 0) throws {
        let tupletNotes = Array(notes[setIndex][noteRange.lowerBound..<noteRange.upperBound])
        let newTuplet = try Tuplet(noteRange.count, baseNoteDuration, inSpaceOf: baseCount, notes: tupletNotes)
        try removeNotesInRange(noteRange, inSet: setIndex)
        try insertTuplet(newTuplet, at: noteRange.lowerBound, inSet: setIndex)
    }

    public mutating func insertTuplet(_ tuplet: Tuplet, at index: Int, inSet setIndex: Int = 0) throws {
        if index == 0 && notes[setIndex].count == 0 {
            addTuplet(tuplet, inSet: setIndex)
            return
        }
        let collectionIndex = try noteCollectionIndex(fromNoteIndex: index, inSet: setIndex)

        guard collectionIndex.tupletIndex == nil else {
            throw MeasureError.insertTupletIntoTupletNotAllowed
        }
        try prepTiesForInsertion(at: index, inSet: setIndex)
        notes[setIndex].insert(tuplet, at: collectionIndex.noteIndex)
    }

    public mutating func removeTuplet(at index: Int, inSet setIndex: Int = 0) throws {
        let collectionIndex = try noteCollectionIndex(fromNoteIndex: index, inSet: setIndex)

        guard collectionIndex.tupletIndex != nil else {
            throw MeasureError.removeTupletFromNote
        }

        try prepTiesForRemoval(at: index, inSet: setIndex)

        // TODO(migue48): The tupletIndex may be used to call into a function that
        // will attempt to replace the tuplet into separate notes. This functionality
        // may be provided in Tuplet class.
        notes[setIndex].remove(at: collectionIndex.noteIndex)
    }

    // Check for tie state of note at index before insert. Since the new note is
    // inserted before the current note, we have to make sure that the tie
    // index is not .end or .beginend otherwise the tie state of adjacent
    // notes will end up in a bad state.
    internal mutating func prepTiesForInsertion(at index: Int, inSet setIndex: Int) throws {
        let currIndexTieState = try tieState(for: index, inSet: setIndex)
        if currIndexTieState == .end || currIndexTieState == .beginAndEnd {
            throw MeasureError.invalidTieState
        }
    }

    // Check for tie state of note at index before removal. The note must not have
    // any tie state associated with it, otherwise it will fail.
    internal mutating func prepTiesForRemoval(at index: Int, inSet setIndex: Int) throws {
        let currentIndexTieState = try tieState(for: index, inSet: setIndex)
        guard currentIndexTieState == nil else {
            throw MeasureError.invalidTieState
        }
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

        let requestedNoteCurrentTie = try tieState(for: index, inSet: setIndex)

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

        let requestedModificationMethod = requestedTieState == nil ? Note.removeTie : Note.modifyTie
        let secondaryModificationMethod = removal ? Note.removeTie : Note.modifyTie

        // Get first note here sho that we can compare the tone against second
        // note later. The tone comparison must be done before modifying the state of
        // the notes.
        var firstNote = try note(at: index, inSet: setIndex)

        if secondaryIndex < noteCount[setIndex] && secondaryIndex >= 0 {
            var secondNote = try note(at: secondaryIndex, inSet: setIndex)

            // Before we modify the tie state for the notes, we make sure that both have
            // the same tone. Ignore check if the removal flag is set.
            guard removal || firstNote.tones == secondNote.tones else {
                throw MeasureError.notesMustHaveSameTonesToTie
            }

            try secondaryModificationMethod(&secondNote)(secondaryRequestedTieState)
            try replaceNote(at: secondaryIndex, with: secondNote, inSet: setIndex)
        }


        try requestedModificationMethod(&firstNote)(primaryRequestedTieState)
        try replaceNote(at: index, with: firstNote, inSet: setIndex)
    }

    internal func noteCollectionIndex(fromNoteIndex index: Int, inSet setIndex: Int) throws -> NoteCollectionIndex {
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

    private func tieState(for index: Int, inSet setIndex: Int) throws -> Tie? {
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
    case invalidTieState
    case internalError
    case notesMustHaveSameTonesToTie
    case insertNoteIntoTupletNotAllowed
    case insertTupletIntoTupletNotAllowed
    case removeNoteFromTuplet
    case removeTupletFromNote
}
