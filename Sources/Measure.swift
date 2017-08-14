//
//  Measure.swift
//  MusicNotation
//
//  Created by Kyle Sherman on 6/12/15.
//  Copyright (c) 2015 Kyle Sherman. All rights reserved.
//

public struct Measure: ImmutableMeasure, Equatable, RandomAccessCollection {

    // MARK: - Collection Conformance

    public typealias Index = Int
    public subscript(position: Index) -> Iterator.Element {
        return Measure.measureSlices(at: position, in: notes)!
    }
    public typealias Iterator = MeasureIterator
    public func makeIterator() -> Iterator {
        return MeasureIterator(self)
    }

    // MARK: - Main Properties

    public let timeSignature: TimeSignature
    public let key: Key?
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
    public private(set) var clefs: [Int: Clef] = [:] {
        didSet {
            // Recompute lastClef
            let maxClef = clefs.max { (element1, element2) in
                return element1.key < element2.key
            }
            if let maxClef = maxClef {
                lastClef = maxClef.value
            }
        }
    }
    public internal(set) var lastClef: Clef?
    public internal(set) var originalClef: Clef?

    internal typealias NoteCollectionIndex = (noteIndex: Int, tupletIndex: Int?)
    private var noteCollectionIndexes: [[NoteCollectionIndex]] = [[NoteCollectionIndex]]()

    // MARK: - Initializers

    public init(timeSignature: TimeSignature, key: Key? = nil) {
        self.init(timeSignature: timeSignature, key: key, notes: [[]])
    }

    public init(timeSignature: TimeSignature, key: Key? = nil, notes: [[NoteCollection]]) {
        self.timeSignature = timeSignature
        self.key = key
        self.notes = notes
        recomputeNoteCollectionIndexes()
    }

    public init(_ immutableMeasure: ImmutableMeasure) {
        timeSignature = immutableMeasure.timeSignature
        key = immutableMeasure.key
        notes = immutableMeasure.notes
        lastClef = immutableMeasure.lastClef
        originalClef = immutableMeasure.originalClef
        clefs = immutableMeasure.clefs
        recomputeNoteCollectionIndexes()
    }

    // MARK: - Public Methods

    /**
     Gets note stored at `index`.
     
     - parameter index: The index of the note in the specified note set.
     - parameter setIndex: Note set index.
     - throws:
        - `TupletError.invalidIndex`
        - `TupletError.internalError`
        - `MeasureError.noteIndexOutOfRange`
     */
    public func note(at index: Int, inSet setIndex: Int = 0) throws -> Note {
        let collectionIndex = try noteCollectionIndex(fromNoteIndex: index, inSet: setIndex)
        let noteIndex = collectionIndex.tupletIndex ?? 0
        return try notes[setIndex][collectionIndex.noteIndex].note(at: noteIndex)
    }

    /**
     Replaces note at `index` in `setIndex` with `noteCollection`.
     
     The `Tie` state of the note being replaced is preserved in `noteCollection`.

     - parameter index: The index of the note in the specified note set.
     - parameter noteCollection: `NoteCollection` used in note replacement.
     - parameter setIndex: Note set index.
     - throws:
        - `MeasureError.noteIndexOutOfRange`
        - `MeasureError.internalError`

     */
    public mutating func replaceNote(at index: Int, with noteCollection: NoteCollection, inSet setIndex: Int = 0) throws {
        try replaceNote(at: index, with: [noteCollection], inSet: setIndex)
    }

    /**
     Replaces note at `index` in `setIndex` with `noteCollections` array.
     
     The `Tie` state of the note being replaced is preserved in the `noteCollections` array.
     
     - parameter index: The index of the note in the specified note set.
     - parameter noteCollections: `NoteCollection` array used in note replacement.
     - parameter setIndex: Note set index.
     - throws:
        - `MeasureError.invalidNoteCollection` If `noteCollections` is empty.
        - `MeasureError.noteIndexOutOfRange`
        - `MeasureError.internalError`
     */
    public mutating func replaceNote(at index: Int, with noteCollections: [NoteCollection], inSet setIndex: Int = 0) throws {
        var newMeasure = self
        let newNoteCollections = try newMeasure.prepTiesForReplacement(in: index...index, with: noteCollections, inSet: setIndex)
        let collectionIndex = try newMeasure.noteCollectionIndex(fromNoteIndex: index, inSet: setIndex)
        try newMeasure.replaceNote(at: collectionIndex, with: newNoteCollections, inSet: setIndex)
        self = newMeasure
    }

    /**
     Replaces a notes array in `setIndex` `range` with `noteCollection`.
     
     The `Tie` state of the notes being replaced is preserved in `noteCollection`. 
     
     - parameter range: The range of notes to replace.
     - parameter noteCollection: `NoteCollection` used in note replacement.
     - parameter setIndex: Note set index.
     - throws:
        - `MeasureError.noteIndexOutOfRange`
        - `MeasureError.tupletNotCompletelyCovered1`
        - `MeasureError.internalError`

     */
    public mutating func replaceNotes(in range: CountableClosedRange<Int>, with noteCollection: NoteCollection, inSet setIndex: Int = 0) throws {
        try replaceNotes(in: range, with: [noteCollection], inSet: setIndex)
    }

    /**
     Replaces a notes array in `setIndex` `range` with `noteCollections`.
     
     The `Tie` state of the notes being replaced is preserved in `noteCollection`.

     - parameter range: The range of notes to replace.
     - parameter noteCollections: `NoteCollection` array used in note replacement.
     - parameter setIndex: Note set index.
     - throws:
        - `MeasureError.invalidNoteCollection` if `noteCollections` is empty.

     */
    public mutating func replaceNotes(in range: CountableClosedRange<Int>, with noteCollections: [NoteCollection], inSet setIndex: Int = 0) throws {
        var newMeasure = self
        let newNoteCollections = try newMeasure.prepTiesForReplacement(in: range, with: noteCollections, inSet: setIndex)
        try newMeasure.removeNotesInRange(range, inSet: setIndex, shouldIgnoreTieStates: true)
        try newMeasure.insert(newNoteCollections, at: range.lowerBound, inSet: setIndex, shouldIgnoreTieStates: true)
        self = newMeasure
    }

    /**
     Adds a new `noteCollection` at the end of the note set.
     
     - parameter noteCollection: `NoteCollection` to add.
     - parameter setIndex: Note set index.
     */
    public mutating func append(_ noteCollection: NoteCollection, inSet setIndex: Int = 0) {
        // Fill with empty arrays up to the specified set index
        while !notes.isValidIndex(setIndex) {
            notes.append([])
        }
        var noteCollectionWithClef = noteCollection
        if let lastClef = lastClef {
            noteCollectionWithClef.setClef(lastClef)
        }
        notes[setIndex].append(noteCollectionWithClef)
    }

    /**
     Inserts a new `noteCollection` at note `index`.
     
     - parameter noteCollection: `NoteCollection` to insert.
     - parameter index: The index of the note in the specified note set.
     - parameter setIndex: Note set index.
     - throws:
        - `MeasureError.invalidTupletIndex`
        - `MeasureError.noteIndexOutOfRange`
        - `MeasureError.invalidTieState`
     */
    public mutating func insert(_ noteCollection: NoteCollection, at index: Int, inSet setIndex: Int = 0) throws {
        try insert(noteCollection, at: index, inSet: setIndex, shouldIgnoreTieStates: false)
    }

    /**
     Inserts `noteCollections` at note `index`.
     
     - parameter noteCollections: Array of `NoteCollection` to insert.
     - parameter index: The index of the note in the specified note set.
     - parameter setIndex: Note set index.
     - throws:
        - `MeasureError.invalidTupletIndex`
        - `MeasureError.noteIndexOutOfRange`
        - `MeasureError.invalidTieState`
     */
    internal mutating func insert(_ noteCollections: [NoteCollection], at index: Int, inSet setIndex: Int = 0) throws {
        try insert(noteCollections, at: index, inSet: setIndex, shouldIgnoreTieStates: false)
    }

    /**
     Removes a single note from `index`.
     
     - parameter index: The index of the note in the specified note set.
     - parameter setIndex: Note set index.
     - throws:
        - `MeasureError.invalidTieState`
        - `MeasureError.noteIndexOutOfRange`
        - `MeasureError.removeNoteFromTuplet`
        - `TupletError.invalidIndex`
        - `TupletError.internalError`
     */
    public mutating func removeNote(at index: Int, inSet setIndex: Int = 0) throws {
        try removeNote(at: index, inSet: setIndex, shouldIgnoreTieStates: false)
    }

    /**
     Removes array of notes from range.
     
     - parameter indexRange: Notes range.
     - parameter setIndex: Note set index.
     - throws:
        - `MeasureError.internalError`
        - `MeasureError.tupletNotCompletelyCovered`
        - `MeasureError.invalidTieState`

     */
    public mutating func removeNotesInRange(_ indexRange: CountableClosedRange<Int>, inSet setIndex: Int = 0) throws {
        try removeNotesInRange(indexRange, inSet: setIndex, shouldIgnoreTieStates: false)
    }

    /**
     Creates a `Tuplet` from a note range. See `Tuplet.init` for more details. This function also makes sure that the
     `noteRange` does not start or end across a `Tuplet` boundary.

     - throws:
        - `MeasureError.tupletNotCompletelyCovered`
        - `MeasureError.internalError`
        - `MeasureError.invalidNoteRange`
        - `MeasureError.invalidTieState`
        - `MeasureError.invalidTupletIndex`
        - `MeasureError.noteIndexOutOfRange`
    */
    public mutating func createTuplet(_ count: Int, _ baseNoteDuration: NoteDuration, inSpaceOf baseCount: Int? = nil, fromNotesInRange noteRange: CountableClosedRange<Int>, inSet setIndex: Int = 0) throws {
        var newMeasure = self
        let startCollectionIndex = try newMeasure.noteCollectionIndex(fromNoteIndex: noteRange.lowerBound, inSet: setIndex)
        if let tupletIndex = startCollectionIndex.tupletIndex, tupletIndex != 0 {
            throw MeasureError.invalidTupletIndex
        }

        let endCollectionIndex = try newMeasure.noteCollectionIndex(fromNoteIndex: noteRange.upperBound, inSet: setIndex)
        if let tupletIndex = endCollectionIndex.tupletIndex {
            guard let tuplet = newMeasure.notes[setIndex][endCollectionIndex.noteIndex] as? Tuplet else {
                assertionFailure("note collection should be tuplet, but case failed")
                throw MeasureError.internalError
            }
            guard tuplet.noteCount == tupletIndex + 1 else {
                throw MeasureError.invalidTupletIndex
            }
        }

        guard newMeasure.notes[setIndex].isValidIndexRange(Range(noteRange)) else {
            throw MeasureError.invalidNoteRange
        }
        let tupletNotes = Array(newMeasure.notes[setIndex][noteRange])

        let newTuplet = try Tuplet(count, baseNoteDuration, inSpaceOf: baseCount, notes: tupletNotes)
        try newMeasure.removeNotesInRange(noteRange, inSet: setIndex)
        try newMeasure.insert(newTuplet, at: noteRange.lowerBound, inSet: setIndex)
        self = newMeasure
    }

    /**
     Breaks outer `Tuplet` into its `NoteCollection` components.
     
     - parameter index: Note index.
     - parameter setIndex: Note set index.
     - throws:
        - `MeasureError.invalidTupletIndex` When `index` does not point to a valid `Tuplet`.
        - `MeasureError.internalError`
        - `MeasureError.noteIndexOutOfRange`
     */
    public mutating func breakdownTuplet(at index: Int, inSet setIndex: Int = 0) throws {
        var newMeasure = self
        let collectionIndex = try newMeasure.noteCollectionIndex(fromNoteIndex: index, inSet: setIndex)
        guard collectionIndex.tupletIndex != nil else {
            throw MeasureError.invalidTupletIndex
        }
        guard let tuplet = newMeasure.notes[setIndex][collectionIndex.noteIndex] as? Tuplet else {
            assertionFailure("note collection should be tuplet, but cast failed")
            throw MeasureError.internalError
        }
        newMeasure.notes[setIndex].remove(at: collectionIndex.noteIndex)

        for note in tuplet.notes.reversed() {
            newMeasure.notes[setIndex].insert(note, at: collectionIndex.noteIndex)
        }
        self = newMeasure
    }

    public func clef(at noteIndex: Int, inSet setIndex: Int) throws -> Clef {
        guard !clefs.isEmpty else {
            if let lastClef = lastClef {
                return lastClef
            } else {
                throw MeasureError.noClefSpecified
            }
        }
        let ticks = try cumulativeTicks(at: noteIndex, inSet: setIndex)
        return try clef(forTicks: ticks)
    }

    private func clef(at noteCollectionIndex: NoteCollectionIndex, inSet setIndex: Int) throws -> Clef {
        guard !clefs.isEmpty else {
            if let lastClef = lastClef {
                return lastClef
            } else {
                throw MeasureError.noClefSpecified
            }
        }
        let ticks = try cumulativeTicks(at: noteCollectionIndex, inSet: setIndex)
        return try clef(forTicks: ticks)
    }

    private func clef(forTicks ticks: Int) throws -> Clef {
        let sortedClefs = clefs.sorted { $0.key < $1.key }
        let prefixedClefs = sortedClefs.prefix { $0.key <= ticks }
        guard let lastClef = prefixedClefs.last?.value else {
            if let originalClef = originalClef {
                return originalClef
            } else {
                throw MeasureError.noClefSpecified
            }
        }
        return lastClef
    }

    // MARK: - Internal Methods

    internal mutating func changeClef(_ clef: Clef, at noteIndex: Int, inSet setIndex: Int = 0) throws {
        let ticks = try cumulativeTicks(at: noteIndex, inSet: setIndex)
        clefs[ticks] = clef
        // Set clef on the note
        var note = try self.note(at: noteIndex, inSet: setIndex)
        note.clef = clef
        let index = try noteCollectionIndex(fromNoteIndex: noteIndex, inSet: setIndex)
        try replaceNote(at: index, with: [note], inSet: setIndex)
    }

    /**
     This method will set the `originalClef` and `lastClef` properties if
     there are no clef changes associated with this measure.
     This is to be used for when a clef change is done to a measure before
     this one and you need to ripple the change throughout.

     - parameter clef: The new clef to change this measure to.
     - returns: True if it changed the clef; false if it didn't change the clef.
     */
    internal mutating func changeFirstClefIfNeeded(to clef: Clef) -> Bool {
        guard clefs.isEmpty else {
            return false
        }
        originalClef = clef
        lastClef = clef
        return true
    }

    /**
     Inserts `noteCollection` at `index`.
     
     - parameter index: Note index.
     - parameter setIndex: Note set index.
     - throws:
        - `MeasureError.invalidTupletIndex`
        - `MeasureError.noteIndexOutOfRange`
        - `MeasureError.invalidTieState`
     */
    internal mutating func insert(_ noteCollection: NoteCollection, at index: Int, inSet setIndex: Int = 0, shouldIgnoreTieStates skipTieConfig: Bool) throws {
        // Set clef to the last clef at the given note index
        let newNoteCollection: NoteCollection
        do {
            let newClef = try clef(at: index, inSet: setIndex)
            var noteCollectionWithClef = noteCollection
            noteCollectionWithClef.setClef(newClef)
            newNoteCollection = noteCollectionWithClef
        } catch {
            newNoteCollection = noteCollection
        }

        if index == 0 && notes[setIndex].isEmpty {
            append(newNoteCollection, inSet: setIndex)
            return
        }

        // If the index points to the end of the note collection, then
        // append entry.
        guard index != noteCount[setIndex] else {
            append(newNoteCollection, inSet: setIndex)
            return
        }

        var newMeasure = self
        let collectionIndex = try newMeasure.noteCollectionIndex(fromNoteIndex: index, inSet: setIndex)

        guard collectionIndex.tupletIndex == nil else {
            throw MeasureError.invalidTupletIndex
        }

        if !skipTieConfig {
            try newMeasure.prepTiesForInsertion(at: index, inSet: setIndex)
        }
        newMeasure.notes[setIndex].insert(newNoteCollection, at: collectionIndex.noteIndex)
        self = newMeasure
    }

    /**
     Inserts `noteCollections` array.
     
     - parameter index: Note index to insert notes.
     - parameter setIndex: Note set index.
     - throws:
        - `MeasureError.invalidTupletIndex`
        - `MeasureError.noteIndexOutOfRange`
        - `MeasureError.invalidTieState`
     */
    internal mutating func insert(_ noteCollections: [NoteCollection], at index: Int, inSet setIndex: Int = 0, shouldIgnoreTieStates skipTieConfig: Bool) throws {
        var newMeasure = self
        for noteCollection in noteCollections.reversed() {
            try newMeasure.insert(noteCollection, at: index, inSet: setIndex, shouldIgnoreTieStates: skipTieConfig)
        }
        self = newMeasure
    }

    /**
     Replaces note at `collectionIndex`.
     
     - parameter collectionIndex: Note collection index.
     - parameter noteCollection: `NoteCollection` to replace note.
     - parameter setIndex: Note set index.
     - throws:
        - `MeasureError.internalError`
     */
    internal mutating func replaceNote(at collectionIndex: NoteCollectionIndex, with noteCollections: [NoteCollection], inSet setIndex: Int) throws {
        // Get the clef for this index
        let noteCollectionsWithClef: [NoteCollection]
        do {
        let clefForNote = try clef(at: collectionIndex, inSet: setIndex)
        noteCollectionsWithClef = noteCollections.map { $0.withClef(clefForNote) }
        } catch {
            noteCollectionsWithClef = noteCollections
        }

        guard let tupletIndex = collectionIndex.tupletIndex else {
            notes[setIndex].remove(at: collectionIndex.noteIndex)
            for noteCollection in noteCollectionsWithClef.reversed() {
                notes[setIndex].insert(noteCollection, at: collectionIndex.noteIndex)
            }
            return
        }

        guard var tuplet = notes[setIndex][collectionIndex.noteIndex] as? Tuplet else {
            assertionFailure("note collection should be tuplet, but cast failed")
            throw MeasureError.internalError
        }
        try tuplet.replaceNote(at: tuplet.flatIndexes[tupletIndex], with: noteCollectionsWithClef)
        notes[setIndex][collectionIndex.noteIndex] = tuplet
    }

    /**
     Removes note at note `index.
     
     - parameter index: The index of the note in the specified note set.
     - parameter setIndex: The index of the note set holding the note.
     - throws:
        - `MeasureError.invalidTieState`
        - `MeasureError.noteIndexOutOfRange`
        - `MeasureError.removeNoteFromTuplet`
        - `TupletError.invalidIndex`
        - `TupletError.internalError`
     */
    internal mutating func removeNote(at index: Int, inSet setIndex: Int, shouldIgnoreTieStates skipTieConfig: Bool) throws {
        var newMeasure = self

        if !skipTieConfig {
            try newMeasure.prepTiesForRemoval(at: index, inSet: setIndex)
        }

        let collectionIndex = try newMeasure.noteCollectionIndex(fromNoteIndex: index, inSet: setIndex)
        guard collectionIndex.tupletIndex == nil else {
            throw MeasureError.removeNoteFromTuplet
        }
        newMeasure.notes[setIndex].remove(at: collectionIndex.noteIndex)
        self = newMeasure
    }

    /**
     Remove notes in range.
     
     - parameter indexRange:
     - parameter setIndex:
     - parameter skipTieConfig:
     - throws:
        - `MeasureError.internalError`
        - `MeasureError.tupletNotCompletelyCovered`
        - `MeasureError.invalidTieState`
     */
    internal mutating func removeNotesInRange(_ indexRange: CountableClosedRange<Int>, inSet setIndex: Int = 0, shouldIgnoreTieStates skipTieConfig: Bool) throws {
        var newMeasure = self

        if !skipTieConfig {
            try newMeasure.prepTiesForRemoval(at: indexRange.lowerBound, inSet: setIndex)
            try newMeasure.prepTiesForRemoval(at: indexRange.upperBound, inSet: setIndex)
        }

        for index in indexRange.reversed() {
            let collectionIndex = try newMeasure.noteCollectionIndex(fromNoteIndex: index, inSet: setIndex)
            if collectionIndex.tupletIndex != nil {
                guard let tupletIndex = collectionIndex.tupletIndex,
                    let tuplet = newMeasure.notes[setIndex][collectionIndex.noteIndex]  as? Tuplet else {
                        assertionFailure("note collection should be tuplet, but cast failed")
                        throw MeasureError.internalError
                }
                // Range starts with  an incomplete lower bound
                if index == indexRange.lowerBound {
                    guard tupletIndex == 0 else {
                        throw MeasureError.tupletNotCompletelyCovered
                    }
                }
                // Error if provided indexRange does not cover the tuple.
                guard indexRange.upperBound - index >= tuplet.noteCount - tupletIndex - 1 else {
                    throw MeasureError.tupletNotCompletelyCovered
                }
                if tupletIndex > 0 {
                    continue
                }
            }
            newMeasure.notes[setIndex].remove(at: collectionIndex.noteIndex)
        }
        self  = newMeasure
    }

    /**
     Prepare notes for replacement to make sure the tie state of the notes being replaced is
     preserved in the `newCollections` replacement.

     - parameter range: Note range of notes being replaced.
     - parameter newCollections: New notes to use in replacement.
     - parameter setIndex: Note set index.
     - throws:
         - `MeasureError.invalidNoteCollection` If `noteCollections` is empty.
         - `MeasureError.internalError`

     */
    internal func prepTiesForReplacement(in range: CountableClosedRange<Int>, with newCollections: [NoteCollection], inSet setIndex: Int) throws -> [NoteCollection] {

        guard newCollections.count > 0 else {
            throw MeasureError.invalidNoteCollection
        }

        var modifiedCollections = newCollections

        func modifyCollections(atFirst first: Bool, with note: Note) throws {
            let index = first ? 0 : modifiedCollections.lastIndex
            if var tuplet = modifiedCollections[index] as? Tuplet {
                try tuplet.replaceNote(at: first ? 0 : tuplet.flatIndexes.lastIndex, with: note)
                modifiedCollections[index] = tuplet
            } else {
                modifiedCollections[index] = note
            }
        }

        func modifyState(forTie originalTie: Tie?) throws {
            switch originalTie {
            case .begin?:
                guard var lastNote = newCollections.last?.last else {
                    assertionFailure("last note was nil")
                    throw MeasureError.internalError
                }
                try lastNote.modifyTie(.begin)
                try modifyCollections(atFirst: false, with: lastNote)
            case .end?:
                guard var firstNote = newCollections.first?.first else {
                    assertionFailure("first note was nil")
                    throw MeasureError.internalError
                }
                try firstNote.modifyTie(.end)
                try modifyCollections(atFirst: true, with: firstNote)
            case .beginAndEnd?:
                if newCollections.count == 1 && newCollections[0].noteCount == 1 {
                    var onlyNote = try newCollections[0].note(at: 0)
                    try onlyNote.modifyTie(.beginAndEnd)
                    modifiedCollections[0] = onlyNote
                } else {
                    guard var firstNote = newCollections.first?.first else {
                        assertionFailure("first note was nil")
                        throw MeasureError.internalError
                    }
                    try firstNote.modifyTie(.end)
                    guard var lastNote = newCollections.last?.last else {
                        assertionFailure("last note was nil")
                        throw MeasureError.internalError
                    }
                    try lastNote.modifyTie(.begin)
                    try modifyCollections(atFirst: true, with: firstNote)
                    try modifyCollections(atFirst: false, with: lastNote)
                }
            case nil:
                break
            }
        }

        guard range.count != 1 else {
            let originalTie = try note(at: range.lowerBound, inSet: setIndex).tie
            try modifyState(forTie: originalTie)
            return modifiedCollections
        }

        let firstOriginalTie = try note(at: range.lowerBound, inSet: setIndex).tie
        let lastOriginalTie = try note(at: range.upperBound, inSet: setIndex).tie

        guard firstOriginalTie != .beginAndEnd && lastOriginalTie != .beginAndEnd else {
            throw MeasureError.invalidTieState
        }
        if firstOriginalTie != .begin && lastOriginalTie != .end {
            try modifyState(forTie: firstOriginalTie)
            try modifyState(forTie: lastOriginalTie)
        }
        return modifiedCollections
    }

    /**
     Check for tie state of note at index before insert. Since the new note is
     inserted before the current note, we have to make sure that the tie
     index is not .end or .beginend otherwise the tie state of adjacent
     notes will end up in a bad state.
     
     - parameter index: The index of the note in the specified note set.
     - parameter setIndex: The index of the note set holding the note.
     - throws:
        - `MeasureError.invalidTieState`

     */
    internal mutating func prepTiesForInsertion(at index: Int, inSet setIndex: Int) throws {
        let currIndexTieState = try tieState(for: index, inSet: setIndex)
        if currIndexTieState == .end || currIndexTieState == .beginAndEnd {
            throw MeasureError.invalidTieState
        }
    }

    /**
     Check for tie state of note at index before removal. Throws `MeasureError.invalidTieState`
     if the index points to the first or last note of the measure containing a `Tie`
     state other than `nil`.
     
     - parameter index: The index of the note in the specified note set.
     - parameter setIndex: The index of the note set holding the note.
     - throws:
        - `MeasureError.invalidTieState`
     */
    internal mutating func prepTiesForRemoval(at index: Int, inSet setIndex: Int) throws {
        let currentIndexTieState = try tieState(for: index, inSet: setIndex)
        guard currentIndexTieState != nil else {
            return
        }

        // Don't allow changes for notes with cross-measure ties:
        // - if the index points to the first note in the measure and the tie state is either 
        //   .end or .beginAndEnd
        // - if the index points to the last note in the measure and the tie state is .begin
        if (index == 0 && (currentIndexTieState == .end || currentIndexTieState == .beginAndEnd)) ||
           (index == noteCount[setIndex] - 1 && (currentIndexTieState == .begin)) {
            throw MeasureError.invalidTieState
        }
        try removeTie(at: index, inSet: setIndex)
    }

    /**
     Starts a tie at note `index`.
     
     - parameter index: Note index.
     - parameter setIndex: Note set index.
     */
    internal mutating func startTie(at index: Int, inSet setIndex: Int) throws {
        try modifyTie(at: index, requestedTieState: .begin, inSet: setIndex)
    }

    /**
     Removes tie state from note at `index`.
     
     - parameter index: Note index.
     - parameter setIndex: Note set index.
     */
    internal mutating func removeTie(at index: Int, inSet setIndex: Int) throws {
        try modifyTie(at: index, requestedTieState: nil, inSet: setIndex)
    }

    /**
     Modifies the tie state of the note at `index` with `requestedTieState`. The tie state of adjacent notes
     may be updated as well to preserve the overall tie state of the measure.
     
     - parameter index: Note index.
     - parameter requestedTieState: Requested tie state.
     - parameter setIndex: Note set index.
     - throws:
        - `MeasureError.invalidRequestedTieState`
        - `MeasureError.notesMustHaveSameTonesToTie`
     */
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
            try replaceNote(at: collectionIndex, with: [secondNote], inSet: setIndex)
        }


        try requestedModificationMethod(&firstNote)(primaryRequestedTieState)
        let collectionIndex = try noteCollectionIndex(fromNoteIndex: index, inSet: setIndex)
        try replaceNote(at: collectionIndex, with: [firstNote], inSet: setIndex)
    }

    /**
     Returns the `NoteCollectionIndex` for the note at the specified note set and index.
     
     - parameter index: Note index.
     - parameter setIndex: Note set index.
     - throws:
        - `MeasureError.noteIndexOutOfRange`
     */
    internal func noteCollectionIndex(fromNoteIndex index: Int, inSet setIndex: Int) throws -> NoteCollectionIndex {
        // Gets the index of the given element in the notes array by translating the index of the
        // single note within the NoteCollection array.
        guard let value = noteCollectionIndexes[safe: setIndex]?[safe: index] else {
            throw MeasureError.noteIndexOutOfRange
        }
        return value
    }

    internal func hasClefAfterNote(at noteIndex: Int) -> Bool {
        do {
            let ticksForRequest = try cumulativeTicks(at: noteIndex)
            return clefs.contains { (key, value) in
                return key > ticksForRequest
            }
        } catch {
            return false
        }
    }

    // MARK: - Private Methods

    /**
     Calculates the note collection indexes stored in the measure.
     */
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

    /**
     Returns tie state of note at `index`.
     
     - parameter index: Note index.
     - parameter setIndex: Note set index.
     - throws:
        - `TupletError.invalidIndex`
        - `TupletError.internalError`
        - `MeasureError.noteIndexOutOfRange`
     */
    private func tieState(for index: Int, inSet setIndex: Int) throws -> Tie? {
        return try note(at: index, inSet: setIndex).tie
    }

    /**
     Returns the number of ticks that exist in the measure up to, but not including
     the given note index.
     */
    internal func cumulativeTicks(at noteIndex: Int, inSet setIndex: Int = 0) throws -> Int {
        // Total # of ticks up to, but not including the given noteIndex
        let index = try noteCollectionIndex(fromNoteIndex: noteIndex, inSet: setIndex)
        return try cumulativeTicks(at: index, inSet: setIndex)
    }

    private func cumulativeTicks(at noteCollectionIndex: NoteCollectionIndex, inSet setIndex: Int = 0) throws -> Int {
        // If tupletIndex is nil or < 1, we can just get a total of all before
        let ticks: Int
        if noteCollectionIndex.tupletIndex ?? 0 < 1 {
            let noteCollections = notes[setIndex]
            // Go up to index before
            ticks = noteCollections[0..<noteCollectionIndex.noteIndex].reduce(0) { prev, currentCollection in
                return prev + currentCollection.ticks
            }
        } else {
            let noteCollections = notes[setIndex]
            // Total up ticks before the last one
            let lastCollectionIndex = Swift.max(noteCollectionIndex.noteIndex - 1, 0)
            let ticksBeforeLast = noteCollections[0..<lastCollectionIndex].reduce(0) { prev, currentCollection in
                return prev + currentCollection.ticks
            }
            guard let lastNoteCollection = noteCollections[noteCollectionIndex.noteIndex] as? Tuplet, let tupletIndex = noteCollectionIndex.tupletIndex else {
                assertionFailure("note collection should be tuplet, but cast failed")
                throw MeasureError.internalError
            }
            ticks = ticksBeforeLast + lastNoteCollection.notes[0..<tupletIndex].reduce(0) { prev, currentCollection in
                return prev + currentCollection.ticks
            }
        }
        return ticks
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
    case invalidNoteRange
    case internalError
    case notesMustHaveSameTonesToTie
    case removeNoteFromTuplet
    case removeTupletFromNote
    case tupletNotCompletelyCovered
    case noClefSpecified
}
