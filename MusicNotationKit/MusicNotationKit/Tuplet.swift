//
//  Tuplet.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 6/15/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

/**
 Represents Duplet, Triplet, ... Septuplet, etc.
 */
public struct Tuplet: NoteCollection {

    /// The notes that make up the tuplet. They can be other tuplets.
    public private(set) var notes: [NoteCollection] {
        didSet {
            flatIndexes = recomputeFlatIndexes()
        }
    }
    /// The number of notes of the specified duration that this tuplet contains
    public let noteCount: Int
    /// The duration of the notes that define this tuplet
    public let noteDuration: NoteDuration
    /// The number of notes that this tuplet fits in the space of
    public let noteTimingCount: Int
    public var first: Note? {
        return try? note(at: 0)
    }
    public var last: Note? {
        return try? note(at: flatIndexes.count - 1)
    }
    /// A 2-dimensional array that can be used to index into every note in the tuplet within compound tuplets as well.
    internal var flatIndexes: [[Int]] = [[Int]]()

    /**
     This maps the standard number of notes in the tuplet (`noteCount`), to the number of notes the tuplet should fit
     in the space of (`noteTimingCount`).
     */
    public static let standardRatios = [
        2: 3,
        3: 2,
        4: 3,
        5: 4,
        6: 4,
        7: 4,
        8: 6,
        9: 8,
    ]

    /**
     There are two ways you can initialize a `Tuplet`: 
     
     1) If you would like to create a tuplet with a count between
        2 and 9, inclusive, and wish to use the standard ratio associated with that count, then you can specify only the
        `count`, `baseDuration` and `notes`. Example:
        ````
        Tuplet(3, .quarter, [quarterNote1, quarterNote2, quarterNote3])
        ````
     2) If you would like specify a non-standard ratio or a `count` larger than 9, then you must specify the
        `baseCount` parameter. Example:
        ````
        Tuplet(35, .sixteenth, inSpaceOf: 25, notes: [sixteenth1, ... sixteenth35])
        ````
     */
    public init(_ count: Int, _ baseNoteDuration: NoteDuration, inSpaceOf baseCount: Int? = nil, notes: [NoteCollection]) throws {
        guard count > 1 else {
            throw TupletError.countMustBeLargerThan1
        }
        noteCount = count
        let fullTupletTicks = count * baseNoteDuration.ticks
        let notesTicks = notes.reduce(0) { prev, noteCollection in
            return prev + noteCollection.ticks
        }
        guard notesTicks == fullTupletTicks else {
            if notesTicks < fullTupletTicks {
                throw TupletError.notesDoNotFillTuplet
            } else {
                throw TupletError.notesOverfillTuplet
            }
        }
        self.notes = notes
        noteDuration = baseNoteDuration
        if let baseCount = baseCount {
            noteTimingCount = baseCount
        } else if let baseCount = Tuplet.standardRatios[count] {
            noteTimingCount = baseCount
        } else {
            throw TupletError.countHasNoStandardRatio
        }
        flatIndexes = recomputeFlatIndexes()
    }

    // MARK: - Methods
    // MARK: Public

    public func note(at index: Int) throws -> Note {
        guard flatIndexes.isValidIndex(index) else {
            throw TupletError.invalidIndex
        }
        let fullIndexes = flatIndexes[index]
        var finalTuplet: Tuplet? = self
        guard fullIndexes.count != 0 else {
            assertionFailure("one of the index arrays was empty")
            throw TupletError.internalError
        }

        // nested function to get a note from the `finalTuplet` using the indexes last index
        func note(from indexes: [Int]) throws -> Note {
            if let lastIndex = fullIndexes.last,
                let note = finalTuplet?.notes[lastIndex] as? Note {
                return note
            } else {
                assertionFailure("last index was not a note")
                throw TupletError.internalError
            }
        }

        guard fullIndexes.count != 1 else {
            return try note(from: fullIndexes)
        }
        for tupletIndex in 0..<fullIndexes.lastIndex {
            finalTuplet = finalTuplet?.notes[fullIndexes[tupletIndex]] as? Tuplet
        }
        return try note(from: fullIndexes)
    }

    public mutating func replaceNote<T: NoteCollection>(at index: Int, with noteCollection: T) throws {
        guard try note(at: index, sameDurationAs: [noteCollection]) else {
            throw TupletError.replacementNotSameDuration
        }
        let flatIndex = flatIndexes[index]
        let preservedTieStateCollection = try preserveTieStateForReplacement(in: index...index, with: noteCollection)
        try replaceNote(at: flatIndex, with: preservedTieStateCollection)
    }

    public mutating func replaceNote<T: NoteCollection>(at index: Int, with noteCollections: [T]) throws {
        guard try note(at: index, sameDurationAs: noteCollections) else {
            throw TupletError.replacementNotSameDuration
        }
        let flatIndex = flatIndexes[index]
        let preservedTieStateCollections = try preserveTieStateForReplacement(in: index...index, with: noteCollections)
        try replaceNote(at: flatIndex, with: preservedTieStateCollections)
    }

    public mutating func replaceNotes<T: NoteCollection>(in range: CountableClosedRange<Int>, with noteCollection: T) throws {
        try replaceNotes(in: range, with: [noteCollection])
    }

    public mutating func replaceNotes<T: NoteCollection>(in range: CountableClosedRange<Int>, with noteCollections: [T]) throws {
        guard try isValidReplacementRange(range) else {
            throw TupletError.rangeToReplaceMustFullyCoverMultipleTuplets
        }
        let flatIndexesInRange = Array(flatIndexes[range])
        let preservedTieStateCollections = try preserveTieStateForReplacement(in: range, with: noteCollections)
        try replaceNotes(at: flatIndexesInRange, with: preservedTieStateCollections, firstNoteIndex: range.lowerBound)
    }

    // MARK: Private

    private func note<T: NoteCollection>(at index: Int, sameDurationAs noteCollections: [T]) throws -> Bool {
        let replacingTicks = noteCollections.reduce(0) { prev, currentCollection in
            return prev + currentCollection.ticks
        }
        let toReplaceNote = try note(at: index)
        let toReplaceTicks = toReplaceNote.ticks
        return toReplaceTicks == replacingTicks
    }

    private func isFlatIndex(_ first: [Int], sameTupletAs second: [Int]) -> Bool {
        // Same tuplet: counts are equal; nextToLast indexes are equal
        return first.count == second.count && nextToLastIndex(from: first) == nextToLastIndex(from: second)
    }

    private func nextToLastIndex(from flatIndex: [Int]) -> Int? {
        return flatIndex.element(at: flatIndex.index(before: flatIndex.lastIndex))
    }

    private func isValidReplacementRange(_ range: CountableClosedRange<Int>) throws -> Bool {
        guard range.lowerBound >= 0 && range.lowerBound < flatIndexes.count
            && range.upperBound >= 0 && range.upperBound < flatIndexes.count else {
                throw TupletError.invalidIndex
        }
        let firstFlatIndex = flatIndexes[range.lowerBound]
        let lastFlatIndex = flatIndexes[range.upperBound]

        // first & last are in same tuplet
        if isFlatIndex(firstFlatIndex, sameTupletAs: lastFlatIndex) {
            return true
        }

        // If first - 1 (tuplet) != first (tuplet) && last + 1 (tuplet) != last (tuplet): return true;
        // OR the count is 1 (not a nested tuplet)
        // else return false
        let beforeFirstFlatIndex = flatIndexes.element(at: range.lowerBound - 1)
        let afterLastFlatIndex = flatIndexes.element(at: range.upperBound + 1)

        switch (beforeFirstFlatIndex, afterLastFlatIndex) {
        case (nil, nil):
            return true
        case (nil, let afterLast?):
            return !isFlatIndex(afterLast, sameTupletAs: lastFlatIndex) || lastFlatIndex.count == 1
        case (let beforeFirst?, nil):
            return !isFlatIndex(beforeFirst, sameTupletAs: firstFlatIndex) || firstFlatIndex.count == 1
        case (let beforeFirst?, let afterLast?):
            return (!isFlatIndex(beforeFirst, sameTupletAs: firstFlatIndex) || firstFlatIndex.count == 1)
                && (!isFlatIndex(afterLast, sameTupletAs: lastFlatIndex) || lastFlatIndex.count == 1)
        }
    }

    /**
     Returns a modified `NoteCollection` with the tie states correct for preserving the original tie states of the notes
     being replaced. The range may also include notes with tie states that represent an invalid state for modification.
     */
    private func preserveTieStateForReplacement(in range: CountableClosedRange<Int>,
                                                with newCollection: NoteCollection) throws -> NoteCollection {
        return try preserveTieStateForReplacement(in: range, with: [newCollection])[0]
    }

    private func preserveTieStateForReplacement(in range: CountableClosedRange<Int>,
                                                with newCollections: [NoteCollection]) throws -> [NoteCollection] {
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
                    throw TupletError.internalError
                }
                try lastNote.modifyTie(.begin)
                try modifyCollections(atFirst: false, with: lastNote)
            case .end?:
                guard var firstNote = newCollections.first?.first else {
                    assertionFailure("first note was nil")
                    throw TupletError.internalError
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
                        throw TupletError.internalError
                    }
                    try firstNote.modifyTie(.end)
                    guard var lastNote = newCollections.last?.last else {
                        assertionFailure("last note was nil")
                        throw TupletError.internalError
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
            let originalTie = try note(at: range.lowerBound).tie
            try modifyState(forTie: originalTie)
            return modifiedCollections
        }

        let firstOriginalTie = try note(at: range.lowerBound).tie
        let lastOriginalTie = try note(at: range.upperBound).tie

        guard firstOriginalTie != .beginAndEnd && lastOriginalTie != .beginAndEnd else {
            throw TupletError.invalidTieState
        }
        if firstOriginalTie != .begin && lastOriginalTie != .end {
            try modifyState(forTie: firstOriginalTie)
            try modifyState(forTie: lastOriginalTie)
        }
        return modifiedCollections
    }

    internal mutating func replaceNote(at flatIndex: [Int], with newCollection: NoteCollection) throws {
        guard flatIndex.count != 1 else {
            notes[flatIndex[0]] = newCollection
            return
        }
        guard var tuplet = notes[flatIndex[0]] as? Tuplet else {
            assertionFailure("all indexes before the last should be tuplets. Must be an error in flatIndexes")
            throw TupletError.internalError
        }
        let slice = Array(flatIndex.dropFirst())
        try tuplet.replaceNote(at: slice, with: newCollection)
        notes[flatIndex[0]] = tuplet
    }

    private mutating func replaceNote(at flatIndex: [Int], with noteCollections: [NoteCollection]) throws {
        guard flatIndex.count != 1 else {
            notes.remove(at: flatIndex[0])
            notes.insert(contentsOf: noteCollections, at: flatIndex[0])
            return
        }
        guard var tuplet = notes[flatIndex[0]] as? Tuplet else {
            assertionFailure("all indexes before the last should be tuplets. Must be an error in flatIndexes")
            throw TupletError.internalError
        }
        let slice = Array(flatIndex.dropFirst())
        try tuplet.replaceNote(at: slice, with: noteCollections)
        notes[flatIndex[0]] = tuplet
    }

    private mutating func replaceNotes(at flatIndexes: [[Int]], with noteCollections: [NoteCollection],
                                       firstNoteIndex: Int) throws {
        var toModify = self
        try toModify.removeNotes(at: flatIndexes)
        // Insert at the first index
        // Need to translate the index now that notes have been removed
        if toModify.flatIndexes.count > firstNoteIndex {
            try toModify.insert(noteCollections, at: toModify.flatIndexes[firstNoteIndex])
        } else {
            // Just append
            toModify.notes.append(contentsOf: noteCollections)
        }
        guard toModify.validate() else {
            throw TupletError.replacementNotSameDuration
        }
        self = toModify
    }

    private mutating func insert(_ noteCollections: [NoteCollection], at flatIndex: [Int]) throws {
        guard flatIndex.count != 1 else {
            notes.insert(contentsOf: noteCollections, at: flatIndex[0])
            return
        }
        // recurse to get to actual tuplet
        let sliced = Array(flatIndex.dropFirst())
        guard var tuplet = notes[flatIndex[0]] as? Tuplet else {
            assertionFailure("all indexes before the last should be tuplets. Must be an error in flatIndexes")
            throw TupletError.internalError
        }
        try tuplet.insert(noteCollections, at: sliced)
        notes[flatIndex[0]] = tuplet
    }

    private mutating func removeNotesRecursive(at flatIndexes: [[Int]]) throws {
        guard let first = flatIndexes.first else {
            return
        }
        // Need to get to the level where the final tuplet is
        if first.count > 2 {
            // recurse to get to actual tuplet level
            let sliced = Array(flatIndexes.map { Array($0.dropFirst()) })
            guard var tuplet = notes[first[0]] as? Tuplet else {
                assertionFailure("all indexes before the last should be tuplets. Must be an error in flatIndexes")
                throw TupletError.internalError
            }
            try tuplet.removeNotesRecursive(at: sliced)
            // Set modified tuplet in enclosing tuplet's notes
            notes[first[0]] = tuplet
        } else if first.count == 2 {
            // This is the same as the method that calls this. Should be able to be extracted into helper function
            let tupletIndexes = Set(flatIndexes.map { $0[0] })
            let tupletGroups = tupletIndexes.map { tupletIndex in
                flatIndexes.filter { group in
                    return group[0] == tupletIndex
                }
            }
            for tupletGroup in tupletGroups {
                let removeRange = tupletGroup[0][1]...tupletGroup[tupletGroup.lastIndex][1]
                guard var tuplet = notes[tupletGroup[0][0]] as? Tuplet else {
                    assertionFailure("all indexes before the last should be tuplets. Must be an error in flatIndexes")
                    throw TupletError.internalError
                }
                tuplet.notes.removeSubrange(removeRange)
                notes[tupletGroup[0][0]] = tuplet
            }
        } else {
            // They are not compound tuplets
            // Just remove from the notes
            let removeRange = flatIndexes[0][0]...flatIndexes[flatIndexes.lastIndex][0]
            notes.removeSubrange(removeRange)
        }
    }

    private mutating func removeNotes(at flatIndexes: [[Int]]) throws {
        let counts = Set(flatIndexes.map { $0.count })
        let flatIndexCountGroups = counts.map { count in
            flatIndexes.filter { flatIndex in
                return flatIndex.count == count
            }
        }
        for flatIndexes in flatIndexCountGroups {
            try removeNotesRecursive(at: flatIndexes)
        }
        removeAllEmptyTuplets()
    }

    private mutating func removeAllEmptyTuplets() {
        var indexesToRemove = [Int]()
        // TODO: We should probably figure out note count so that this switch on type isn't needed.
        let accumulateNoteCount: (Int, NoteCollection) -> Int = { prev, currentNoteCollection in
            if let currentTuplet = currentNoteCollection as? Tuplet {
                return prev + currentTuplet.flatIndexes.count
            } else {
                return prev + currentNoteCollection.noteCount
            }
        }
        for (index, noteCollection) in notes.enumerated() {
            if var tuplet = noteCollection as? Tuplet,
                tuplet.notes.isEmpty || tuplet.notes.reduce(0, accumulateNoteCount) == 0 {
                indexesToRemove.append(index)
            } else if var tuplet = noteCollection as? Tuplet {
                tuplet.removeAllEmptyTuplets()
                notes[index] = tuplet
            }
        }
        var alreadyRemoved = 0
        for index in indexesToRemove {
            notes.remove(at: index - alreadyRemoved)
            alreadyRemoved += 1
        }
    }

    private func validate() -> Bool {
        var isValid = true
        var notesTicks = 0
        let fullTupletTicks = noteCount * noteDuration.ticks
        for noteCollection in notes {
            if let tuplet = noteCollection as? Tuplet {
                if !isValid {
                    break
                }
                isValid = tuplet.validate()
            }
            notesTicks += noteCollection.ticks
        }
        if !isValid {
            return isValid
        } else if fullTupletTicks != notesTicks {
            return false
        }
        return true
    }
    
    internal mutating func recomputeFlatIndexes(parentIndexes: [Int] = [Int]()) -> [[Int]] {
        flatIndexes = [[Int]]()
        for (index, noteCollection) in notes.enumerated() {
            if noteCollection is Note {
                let newIndexes = [parentIndexes.flatMap { $0 }, [index]].flatMap { $0 }
                flatIndexes.append(newIndexes)
            } else if var tuplet = noteCollection as? Tuplet {
                let parents = [parentIndexes, [index]].flatMap { $0 }
                flatIndexes.append(contentsOf: tuplet.recomputeFlatIndexes(parentIndexes: parents))
            }
        }
        return flatIndexes
    }
}

extension Tuplet: Equatable {
    public static func ==(lhs: Tuplet, rhs: Tuplet) -> Bool {
        guard lhs.noteTimingCount == rhs.noteTimingCount &&
            lhs.noteDuration == rhs.noteDuration &&
            lhs.noteCount == rhs.noteCount else {
                return false
        }
        guard lhs.notes.count == rhs.notes.count else {
            return false
        }
        for (index, collection) in lhs.notes.enumerated() {
            if collection != rhs.notes[index] {
                return false
            }
        }
        return true
    }
}

extension Tuplet: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\(noteCount)\(notes)"
    }
}

public enum TupletError: Error {
    case invalidIndex
    case countHasNoStandardRatio
    case countMustBeLargerThan1
    case notesDoNotFillTuplet
    case notesOverfillTuplet
    case replacementNotSameDuration
    case rangeToReplaceMustFullyCoverMultipleTuplets
    case invalidTieState
    case internalError
}
