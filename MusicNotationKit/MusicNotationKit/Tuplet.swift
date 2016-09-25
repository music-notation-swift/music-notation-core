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
            return prev + noteCollection.noteDuration.ticks * noteCollection.noteTimingCount
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
        guard index >= 0 && index < flatIndexes.count else {
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
        for tupletIndex in 0..<fullIndexes.count - 1 {
            finalTuplet = finalTuplet?.notes[fullIndexes[tupletIndex]] as? Tuplet
        }
        return try note(from: fullIndexes)
    }

    public mutating func replaceNote<T: NoteCollection>(at index: Int, with noteCollection: T) throws {
        // validate they are the same duration
        guard try notes(at: [index], sameDurationAs: [noteCollection]) else {
            throw TupletError.replacementNotSameDuration
        }
        let flatIndex = flatIndexes[index]
        try replaceNote(at: flatIndex, with: noteCollection)
    }

    public mutating func replaceNote<T: NoteCollection>(at index: Int, with noteCollections: [T]) throws {
        // validate they are the same duration
        guard try notes(at: [index], sameDurationAs: noteCollections) else {
            throw TupletError.replacementNotSameDuration
        }
        let flatIndex = flatIndexes[index]
        try replaceNote(at: flatIndex, with: noteCollections)
    }

    public mutating func replaceNotes<T: NoteCollection>(in range: CountableClosedRange<Int>, with noteCollection: T) throws {
        guard try notes(at: range, sameDurationAs: [noteCollection]) else {
            throw TupletError.replacementNotSameDuration
        }
        let flatIndexesInRange = Array(flatIndexes[range])
        try replaceNotes(at: flatIndexesInRange, with: noteCollection)
    }

    public mutating func replaceNotes<T: NoteCollection>(in range: CountableClosedRange<Int>, with noteCollections: [T]) throws {
        guard try notes(at: range, sameDurationAs: noteCollections) else {
            throw TupletError.replacementNotSameDuration
        }
        let flatIndexesInRange = Array(flatIndexes[range])
        try replaceNotes(at: flatIndexesInRange, with: noteCollections)
    }

    // MARK: Private

    private func notes<T: NoteCollection, Indexes: Sequence>(
        at indexes: Indexes,
        sameDurationAs noteCollections: [T]) throws -> Bool where Indexes.Iterator.Element == Int {
        let neededFlatIndexes = indexes.map { flatIndexes[$0] }
        // Figure out if any are full tuplets
        var previousTupletIndex: Int?
        var previousIndexCount: Int?
        var indexesOfFullTuplets = [CountableClosedRange<Int>]()
        var currentIndexesOfTuplet = [Int]()
        func closedRange(fromIndexes: [Int]) throws -> CountableClosedRange<Int> {
            if let first = currentIndexesOfTuplet.first, let last = currentIndexesOfTuplet.last {
                return first...last
            } else {
                assertionFailure("current indexes was empty")
                throw TupletError.internalError
            }
        }
        for (index, flatIndex) in neededFlatIndexes.enumerated() {
            if flatIndex.count == 1 {
                previousTupletIndex = nil
                previousIndexCount = nil
                currentIndexesOfTuplet.removeAll()
                continue
            }
            if previousIndexCount == nil {
                previousIndexCount = flatIndex.count
            } else if previousIndexCount != flatIndex.count {
                previousTupletIndex = nil
                currentIndexesOfTuplet.removeAll()
            }
            let nextToLast = flatIndex.index(before: flatIndex.count - 1)
            if previousTupletIndex == nil {
                currentIndexesOfTuplet.removeAll()
                currentIndexesOfTuplet.append(index)
                previousTupletIndex = flatIndex[nextToLast]
            } else if previousTupletIndex != flatIndex[nextToLast] {
                indexesOfFullTuplets.append(try closedRange(fromIndexes: currentIndexesOfTuplet))
                previousTupletIndex = flatIndex[nextToLast]
                currentIndexesOfTuplet.removeAll()
                currentIndexesOfTuplet.append(index)
            } else {
                currentIndexesOfTuplet.append(index)
            }
        }
        if !currentIndexesOfTuplet.isEmpty {
            // See if the indexes in there are the full tuplet. You can check this by seeing if the next flat index
            // has the same nextToLast index value and same count
            let nextIndex = (indexes.max() ?? 0) + 1
            if flatIndexes.count > nextIndex {
                let nextFlatIndex = flatIndexes[nextIndex]
                let currentFlatIndex = flatIndexes[currentIndexesOfTuplet[0]]
                let nextToLast = currentFlatIndex.index(before: currentFlatIndex.count - 1)
                if (currentFlatIndex.count != nextFlatIndex.count) ||
                    (currentFlatIndex.count == nextFlatIndex.count &&
                    currentFlatIndex[nextToLast] != currentFlatIndex[nextToLast]) {
                    indexesOfFullTuplets.append(try closedRange(fromIndexes: currentIndexesOfTuplet))
                }
            } else {
                indexesOfFullTuplets.append(try closedRange(fromIndexes: currentIndexesOfTuplet))
            }
        }

        var nonFullTupletIndexes = Array(indexes)
        var offsetBy = 0
        for indexOfFullTuplet in indexesOfFullTuplets {
            let offsetRange = (indexOfFullTuplet.lowerBound - offsetBy)...(indexOfFullTuplet.upperBound - offsetBy)
            nonFullTupletIndexes.removeSubrange(offsetRange)
            offsetBy += offsetRange.count
        }

        var toReplaceFullTupletTicks = 0
        for indexOfFullTuplet in indexesOfFullTuplets {
            let flatIndexOfTuplet = neededFlatIndexes[indexOfFullTuplet.lowerBound]
            var tuplet: Tuplet? = self
            var currentFlatIndex = ArraySlice(flatIndexOfTuplet)
            repeat {
                tuplet = tuplet?.notes[currentFlatIndex[0]] as? Tuplet
                currentFlatIndex = flatIndexOfTuplet.dropFirst()
            } while currentFlatIndex.count > 1
            if let tuplet = tuplet {
                toReplaceFullTupletTicks += tuplet.noteDuration.ticks * tuplet.noteTimingCount
            } else {
                assertionFailure("expected Tuplet, but was not one")
                throw TupletError.internalError
            }
        }

        let toReplaceWithoutFullTupletTicks = try nonFullTupletIndexes.reduce(0) { prev, index in
            let note = try self.note(at: index)
            return prev + note.noteDuration.ticks * note.noteTimingCount
        }
        let replacingTicks = noteCollections.reduce(0) { prev, currentCollection in
            return prev + currentCollection.noteDuration.ticks * currentCollection.noteTimingCount
        }
        let toReplaceTicks = toReplaceWithoutFullTupletTicks + toReplaceFullTupletTicks
        return toReplaceTicks == replacingTicks
    }

    private mutating func replaceNote(at flatIndex: [Int], with newCollection: NoteCollection) throws {
        guard flatIndex.count != 1 else {
            notes[flatIndex[0]] = newCollection
            return
        }
        guard var tuplet = notes[flatIndex[0]] as? Tuplet else {
            assertionFailure("all indexes before the last should be tuplets. Must be an error in flatIndexes")
            throw TupletError.internalError
        }
        let slice = Array(flatIndex[1..<flatIndex.count])
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
        let slice = Array(flatIndex[1..<flatIndex.count])
        try tuplet.replaceNote(at: slice, with: noteCollections)
        notes[flatIndex[0]] = tuplet
    }

    private mutating func replaceNotes(at flatIndexes: [[Int]], with noteCollection: NoteCollection) throws {
        try replaceNotes(at: flatIndexes, with: [noteCollection])

        // If at the same depth, it is simple
//        let countsSet = Set(flatIndexes.map { $0.count })
//        if countsSet.count == 1 {
//            // Remove all notes to replace
//            for flatIndex in flatIndexes {
//                guard flatIndex.count != 1 else {
//                    notes.remove(at: flatIndex[0])
//                    return
//                }
//                guard var tuplet = notes[flatIndex[0]] as? Tuplet else {
//                    assertionFailure("all indexes before the last should be tuplets. Must be an error in flatIndexes")
//                    throw TupletError.internalError
//                }
//                let slice = Array(flatIndex[1..<flatIndex.count])
//                try tuplet.replaceNotes(at: [slice], with: noteCollection)
//
//            }
//
//        }
    }

    private mutating func replaceNotes(at flatIndexes: [[Int]], with noteCollections: [NoteCollection]) throws {
        let unmodified = self
        try removeNotes(at: flatIndexes)
        // Insert at the first index
        try insert(noteCollections, at: flatIndexes[0])
        if !validate() {
            self = unmodified
            throw TupletError.rangeToReplaceMustFullyCoverMultipleTuplets
        }
    }

    private mutating func insert(_ noteCollections: [NoteCollection], at flatIndex: [Int]) throws {
        if flatIndex.count != 1 {
            // recurse to get to actual tuplet
            let sliced = Array(flatIndex.dropFirst())
            guard var tuplet = notes[flatIndex[0]] as? Tuplet else {
                assertionFailure("all indexes before the last should be tuplets. Must be an error in flatIndexes")
                throw TupletError.internalError
            }
            try tuplet.insert(noteCollections, at: sliced)
            notes[flatIndex[0]] = tuplet
        } else {
            notes.insert(contentsOf: noteCollections, at: flatIndex[0])
        }
    }

    // FIXME: Probably won't use this
    private func isValidReplacementRange(flatIndexes: [[Int]]) throws -> Bool {
        // If multiple tuplets are encountered, they all need to be fully covered
        var lastFlatIndexCount = 0
        var lastFlatIndexNoteCount = 0
        var currentNoteCount = 0
        var tupletCount = 0
        var returnValue = true
        for flatIndex in flatIndexes {
            if flatIndex.count == 1 {
                // Non-tuplets are fine
                lastFlatIndexCount = 0
                currentNoteCount = 0
                continue
            }
            if flatIndex.count == lastFlatIndexCount {
                currentNoteCount += 1
                continue
            }
            if currentNoteCount != lastFlatIndexNoteCount {
                returnValue = false
            }
            var currentTuplet = self
            var slice = flatIndex
            lastFlatIndexCount = flatIndex.count
            repeat {
                guard let tuplet = currentTuplet.notes[slice[0]] as? Tuplet else {
                    assertionFailure("all indexes before the last should be tuplets. Must be an error in flatIndexes")
                    throw TupletError.internalError
                }
                currentTuplet = tuplet
                slice = Array(flatIndex[1..<flatIndex.count])
            } while slice.count != 1
            lastFlatIndexNoteCount = currentTuplet.noteCount
            tupletCount += 1
        }
        if tupletCount > 1 {
            return returnValue
        } else {
            return true
        }
    }

    private mutating func removeNotesRec(at flatIndexes: [[Int]]) throws -> [Int] {
        var indexesToRemove = [Int]()
        for flatIndex in flatIndexes {
            if flatIndex.count != 1 {
                // recurse to get to actual tuplet
                let first = flatIndexes[0]
                let sliced = Array(flatIndexes.map { Array($0.dropFirst()) })
                guard var tuplet = notes[first[0]] as? Tuplet else {
                    assertionFailure("all indexes before the last should be tuplets. Must be an error in flatIndexes")
                    throw TupletError.internalError
                }
                let indexesToRemove = try tuplet.removeNotesRec(at: sliced)
                let removeRange = indexesToRemove[0]..<indexesToRemove.last! + 1 // TODO: Remove !
                let tupletNotes = tuplet.notes
                if tupletNotes.indices ~= removeRange {
                    tuplet.notes.removeSubrange(removeRange)
                    notes[flatIndex[0]] = tuplet
                }
            } else {
                indexesToRemove.append(flatIndex[0])
            }
        }
        return indexesToRemove
    }

    private mutating func removeNotes(at flatIndexes: [[Int]]) throws {
        _ = try removeNotesRec(at: flatIndexes)
        removeAllEmptyTuplets()
    }

    private mutating func removeAllEmptyTuplets() {
        var indexesToRemove = [Int]()
        for (index, noteCollection) in notes.enumerated() {
            if var tuplet = noteCollection as? Tuplet, tuplet.notes.isEmpty {
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
            notesTicks += noteCollection.noteDuration.ticks * noteCollection.noteTimingCount
        }
        if !isValid {
            return isValid
        } else if fullTupletTicks != notesTicks {
            return false
        } else {
            return true
        }
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
    case internalError
}
