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

    public var noteCount: [Int] {
        return notes.map {
            $0.reduce(0) { prev, noteCollection in
                return prev + noteCollection.noteCount
            }
        }
    }

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
        recomputeNoteCollectionIndexes()
    }

    public init(_ immutableMeasure: ImmutableMeasure) {
        timeSignature = immutableMeasure.timeSignature
        key = immutableMeasure.key
        notes = immutableMeasure.notes
        recomputeNoteCollectionIndexes()
    }

    public func note(at index: Int, inSet setIndex: Int = 0) throws -> Note {
        let collectionIndex = try noteCollectionIndex(fromNoteIndex: index, inSet: setIndex)
        let noteIndex = collectionIndex.tupletIndex ?? 0
        return try notes[setIndex][collectionIndex.noteIndex].note(at: noteIndex)
    }

    public mutating func replaceNote<T: NoteCollection>(at index: Int, with noteCollection: T, inSet setIndex: Int = 0) throws {
        let noteCollections = try prepTiesForReplacement(in: index...index, with: [noteCollection], inSet: setIndex)
        let collectionIndex = try noteCollectionIndex(fromNoteIndex: index, inSet: setIndex)
        try replaceNote(at: collectionIndex, with: noteCollections, inSet: setIndex)
    }

    public mutating func replaceNote<T: NoteCollection>(at index: Int, with noteCollections: [T], inSet setIndex: Int = 0) throws {
        let noteCollections = try prepTiesForReplacement(in: index...index, with: noteCollections, inSet: setIndex)
        try removeNote(at: index)
        try insert(noteCollections, at: index, inSet: setIndex)
    }

    public mutating func replaceNotes<T: NoteCollection>(in range: CountableClosedRange<Int>, with noteCollection: T, inSet setIndex: Int = 0) throws {
        let noteCollections = try prepTiesForReplacement(in: range, with: [noteCollection], inSet: setIndex)
        try removeNotesInRange(range)
        try insert(noteCollections, at: range.lowerBound, inSet: setIndex)
    }

    public mutating func replaceNotes<T: NoteCollection>(in range: CountableClosedRange<Int>, with noteCollections: [T], inSet setIndex: Int = 0) throws {
        let noteCollections = try prepTiesForReplacement(in: range, with: noteCollections, inSet: setIndex)
        try removeNotesInRange(range)
        try insert(noteCollections, at: range.lowerBound, inSet: setIndex)
    }

    public mutating func append(_ noteCollection: NoteCollection, inSet setIndex: Int = 0) {
        notes[setIndex].append(noteCollection)
    }

    public mutating func insert(_ noteCollection: NoteCollection, at index: Int, inSet setIndex: Int = 0) throws {
        if index == 0 && notes[setIndex].count == 0 {
            append(noteCollection, inSet: setIndex)
            return
        }

        let collectionIndex = try noteCollectionIndex(fromNoteIndex: index, inSet: setIndex)

        guard collectionIndex.tupletIndex == nil else {
            throw MeasureError.invalidTupletIndex
        }
        try prepTiesForInsertion(at: index, inSet: setIndex)
        notes[setIndex].insert(noteCollection, at: collectionIndex.noteIndex)
    }

    public mutating func insert(_ noteCollections: [NoteCollection], at index: Int, inSet setIndex: Int = 0) throws {
        for noteCollection in noteCollections.reversed() {
            try insert(noteCollection, at: index, inSet: setIndex)
        }
    }

    public mutating func removeNote(at index: Int, inSet setIndex: Int = 0) throws {
        let collectionIndex = try noteCollectionIndex(fromNoteIndex: index, inSet: setIndex)
        guard collectionIndex.tupletIndex == nil else {
            throw MeasureError.removeNoteFromTuplet
        }
        try prepTiesForRemoval(at: index, inSet: setIndex)
        notes[setIndex].remove(at: collectionIndex.noteIndex)
    }

    public mutating func removeNotesInRange(_ indexRange: CountableClosedRange<Int>, inSet setIndex: Int = 0) throws {
        let startTie = try tieState(for: indexRange.lowerBound, inSet: setIndex)
        guard startTie == nil || startTie == .begin else {
            throw MeasureError.invalidTieState
        }

        var newNotes = notes[setIndex]

        let endTie = try tieState(for: indexRange.upperBound - 1, inSet: setIndex)
        guard endTie == nil || endTie == .end else {
            throw MeasureError.invalidTieState
        }

        for index in indexRange.reversed() {
            let collectionIndex = try noteCollectionIndex(fromNoteIndex: index, inSet: setIndex)
            if collectionIndex.tupletIndex != nil {
                guard let tupletIndex = collectionIndex.tupletIndex,
                    let tuplet = notes[setIndex][collectionIndex.noteIndex]  as? Tuplet else {
                        assertionFailure("note collection should be tuplet, but cast failed")
                        throw MeasureError.internalError
                }
                // Range starts with  an incomplete lower bound
                if index == indexRange.lowerBound {
                    guard tupletIndex == 0 else {
                        throw MeasureError.incompleteTuplet
                    }
                }
                // Error if provided indexRange does not cover the tuple.
                guard tuplet.noteCount - tupletIndex <= indexRange.upperBound - index else {
                    throw MeasureError.incompleteTuplet
                }
                if tupletIndex > 0 {
                    continue
                }
            }
            newNotes.remove(at: collectionIndex.noteIndex)
        }
        notes[setIndex] = newNotes
    }

    /// Create a `Tuplet` from a note range. See `Tuplet.init` for more details.
    /// This function also makes sure that the `noteRange` does not start or end
    /// across a `Tuplet` boundary.
    public mutating func createTuplet(_ count: Int, _ baseNoteDuration: NoteDuration, inSpaceOf baseCount: Int? = nil, fromNotesInRange noteRange: CountableClosedRange<Int>, inSet setIndex: Int = 0) throws {
        let startCollectionIndex = try noteCollectionIndex(fromNoteIndex: noteRange.lowerBound, inSet: setIndex)
        if startCollectionIndex.tupletIndex != nil {
            guard let tupletIndex = startCollectionIndex.tupletIndex, tupletIndex == 0 else {
                throw MeasureError.invalidTupletIndex
            }
        }

        let endCollectionIndex = try noteCollectionIndex(fromNoteIndex: noteRange.upperBound, inSet: setIndex)
        if endCollectionIndex.tupletIndex != nil {
            guard let tupletIndex = endCollectionIndex.tupletIndex,
                let tuplet = notes[setIndex][endCollectionIndex.noteIndex] as? Tuplet else {
                    assertionFailure("note collection should be tuplet, but cast failed")
                    throw MeasureError.internalError
            }
            guard tuplet.noteCount == tupletIndex + 1 else {
                throw MeasureError.invalidTupletIndex
            }
        }

        var expectedCount = noteRange.upperBound - noteRange.lowerBound + 1

        guard noteCount[setIndex] >= expectedCount else {
            throw MeasureError.noteIndexOutOfRange
        }

        var tupletNotes = [NoteCollection]()
        var index = startCollectionIndex.noteIndex

        while expectedCount > 0 && notes[setIndex].count > index{
            tupletNotes.append(notes[setIndex][index])
            expectedCount -= notes[setIndex][index].noteCount
            index += 1
        }

        let newTuplet = try Tuplet(count, baseNoteDuration, inSpaceOf: baseCount, notes: tupletNotes)
        try removeNotesInRange(noteRange, inSet: setIndex)
        try insert(newTuplet, at: noteRange.lowerBound, inSet: setIndex)
    }

    public mutating func breakdownTuplet(at index: Int, inSet setIndex: Int = 0) throws {
        let collectionIndex = try noteCollectionIndex(fromNoteIndex: index, inSet: setIndex)
        guard let tupletIndex = collectionIndex.tupletIndex, tupletIndex == 0 else {
            throw MeasureError.invalidTupletIndex
        }
        guard let tuplet = notes[setIndex][collectionIndex.noteIndex] as? Tuplet else {
            assertionFailure("note collection should be tuplet, but cast failed")
            throw MeasureError.internalError
        }
        notes[setIndex].remove(at: collectionIndex.noteIndex)

        for note in tuplet.notes.reversed() {
            notes[setIndex].insert(note, at: collectionIndex.noteIndex)
        }
    }

    internal mutating func replaceNote(at collectionIndex: NoteCollectionIndex, with noteCollection: NoteCollection, inSet setIndex: Int) throws {
        guard let tupletIndex = collectionIndex.tupletIndex else {
            notes[setIndex][collectionIndex.noteIndex] = noteCollection
            return
        }

        guard var tuplet = notes[setIndex][collectionIndex.noteIndex] as? Tuplet else {
            assertionFailure("note collection should be tuplet, but cast failed")
            throw MeasureError.internalError
        }
        try tuplet.replaceNote(at: tuplet.flatIndexes[tupletIndex], with: noteCollection)
        notes[setIndex][collectionIndex.noteIndex] = tuplet
    }

    internal mutating func replaceNote(at collectionIndex: NoteCollectionIndex, with noteCollections: [NoteCollection], inSet setIndex: Int) throws {
        guard noteCollections.count > 0 else {
            throw MeasureError.invalidNoteCollection
        }

        guard collectionIndex.tupletIndex == nil || collectionIndex.tupletIndex == 0 else {
            throw MeasureError.invalidTupletIndex
        }

        // If the measure is empty and the start index is 0, then we append
        // the last note first to make sure that the first replaceNote below
        // doesn't get and out of index error. This cover the use case where
        // the caller wants to replace all the notes inside the measure with
        // a new set of notes.
        if noteCount[setIndex] == 0 && collectionIndex.noteIndex == 0 {
            guard let noteCollection = noteCollections.last else {
                assertionFailure("Failed to get last noteCollection from noteCollections.")
                throw MeasureError.internalError
            }
            notes[setIndex].append(noteCollection)
        }
        for note in noteCollections.reversed() {
            try replaceNote(at: collectionIndex, with: note, inSet: setIndex)
        }
    }

    internal func prepTiesForReplacement(in range: CountableClosedRange<Int>, with newCollections: [NoteCollection], inSet setIndex: Int) throws -> [NoteCollection] {

        guard newCollections.count > 0 else {
            throw MeasureError.invalidNoteCollection
        }

        return newCollections
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

    // Check for tie state of note at index before removal. Throws `MeasureError.invalidTieState` 
    // if the index points to the first or last note of the measure containing a `Tie` 
    // state other than `nil`.
    internal mutating func prepTiesForRemoval(at index: Int, inSet setIndex: Int) throws {
        let currentIndexTieState = try tieState(for: index, inSet: setIndex)
        guard currentIndexTieState != nil else {
            return
        }

        guard index > 0 && index < noteCount[setIndex] - 1 else {
            throw MeasureError.invalidTieState
        }
        try removeTie(at: index, inSet: setIndex)
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

        // Get first note here so that we can compare the tone against second
        // note later. The tone comparison must be done before modifying the state of
        // the notes.
        var firstNote = try note(at: index, inSet: setIndex)

        // TODO: this check is no longer required in latest main. Check test cases.
        if secondaryIndex < noteCount[setIndex] && secondaryIndex >= 0 {
            var secondNote = try note(at: secondaryIndex, inSet: setIndex)

            // Before we modify the tie state for the notes, we make sure that both have
            // the same tone. Ignore check if the removal flag is set.
            guard removal || firstNote.tones == secondNote.tones else {
                throw MeasureError.notesMustHaveSameTonesToTie
            }

            try secondaryModificationMethod(&secondNote)(secondaryRequestedTieState)
            let collectionIndex = try noteCollectionIndex(fromNoteIndex: secondaryIndex, inSet: setIndex)
            try replaceNote(at: collectionIndex, with: secondNote, inSet: setIndex)
        }


        try requestedModificationMethod(&firstNote)(primaryRequestedTieState)
        let collectionIndex = try noteCollectionIndex(fromNoteIndex: index, inSet: setIndex)
        try replaceNote(at: collectionIndex, with: firstNote, inSet: setIndex)
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
    case invalidTupletIndex
    case invalidNoteCollection
    case internalError
    case notesMustHaveSameTonesToTie
    case removeNoteFromTuplet
    case removeTupletFromNote
    case incompleteTuplet
}
