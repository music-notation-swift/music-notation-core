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
        try replaceNotes(in: range, with: [noteCollection])
    }

    public mutating func replaceNotes<T: NoteCollection>(in range: CountableClosedRange<Int>, with noteCollections: [T]) throws {
        guard try isValidReplacementRange(range) else {
            throw TupletError.rangeToReplaceMustFullyCoverMultipleTuplets
        }
        let flatIndexesInRange = Array(flatIndexes[range])
        try replaceNotes(at: flatIndexesInRange, with: noteCollections, firstNoteIndex: range.lowerBound)
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
                if !currentIndexesOfTuplet.isEmpty {
                    indexesOfFullTuplets.append(try closedRange(fromIndexes: currentIndexesOfTuplet))
                }
                previousTupletIndex = nil
                previousIndexCount = nil
                currentIndexesOfTuplet.removeAll()
                continue
            }
            if previousIndexCount == nil {
                previousIndexCount = flatIndex.count
            } else if previousIndexCount != flatIndex.count {
                previousTupletIndex = nil
                if !currentIndexesOfTuplet.isEmpty {
                    indexesOfFullTuplets.append(try closedRange(fromIndexes: currentIndexesOfTuplet))
                }
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
            // Also, need to check if the rest of tuplet indexes are in currentIndexesOfTuplet or not
            if let firstLastIndex = neededFlatIndexes[currentIndexesOfTuplet[0]].last, firstLastIndex == 0,
                let lastIndexToModify = indexes.max() {
                let nextIndex = lastIndexToModify + 1
                if flatIndexes.count > nextIndex {
                    let nextFlatIndex = flatIndexes[nextIndex]
                    let currentFlatIndex = flatIndexes[lastIndexToModify]
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
            currentIndexesOfTuplet.removeAll()
        }

        // TODO: Need to account for case where multiple full tuplets complete a tuplet that had them as children

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
            var currentFlatIndex = flatIndexOfTuplet
            repeat {
                tuplet = tuplet?.notes[currentFlatIndex[0]] as? Tuplet
                currentFlatIndex = Array(currentFlatIndex.dropFirst())
            } while currentFlatIndex.count != 1
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

    private func isValidReplacementRange(_ range: CountableClosedRange<Int>) throws -> Bool {
        guard range.lowerBound >= 0 && range.lowerBound < flatIndexes.count
            && range.upperBound >= 0 && range.upperBound < flatIndexes.count else {
                throw TupletError.invalidIndex
        }
        let firstFlatIndex = flatIndexes[range.lowerBound]
        let lastFlatIndex = flatIndexes[range.upperBound]

        func nextToLastIndex(from flatIndex: [Int]) -> Int? {
            // Array.endIndex == count
            return flatIndex.count > 1 ? flatIndex[flatIndex.endIndex - 2] : nil
        }

        func isSameTuplet(_ first: [Int], _ second: [Int]) -> Bool {
            // Same tuplet: counts are equal; nextToLast indexes are equal
            if first.count == second.count && nextToLastIndex(from: first) == nextToLastIndex(from: second) {
                return true
            } else {
                return false
            }
        }

        // first & last are in same tuplet
        if isSameTuplet(firstFlatIndex, lastFlatIndex) {
            return true
        }

        func flatIndex(at index: Int) -> [Int]? {
            guard index >= 0 && index < flatIndexes.count else {
                return nil
            }
            return flatIndexes[index]
        }

        // If first - 1 (tuplet) != first (tuplet) && last + 1 (tuplet) != last (tuplet): return true;
        // OR the count is 1 (not a nested tuplet)
        // else return false
        let beforeFirstFlatIndex = flatIndex(at: range.lowerBound - 1)
        let afterLastFlatIndex = flatIndex(at: range.upperBound + 1)

        switch (beforeFirstFlatIndex, afterLastFlatIndex) {
        case (nil, nil):
            return true
        case (nil, let afterLast?):
            return !isSameTuplet(afterLast, lastFlatIndex) || lastFlatIndex.count == 1
        case (let beforeFirst?, nil):
            return !isSameTuplet(beforeFirst, firstFlatIndex) || firstFlatIndex.count == 1
        case (let beforeFirst?, let afterLast?):
            return (!isSameTuplet(beforeFirst, firstFlatIndex) || firstFlatIndex.count == 1)
                && (!isSameTuplet(afterLast, lastFlatIndex) || lastFlatIndex.count == 1)
        }
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

    private mutating func replaceNotes(at flatIndexes: [[Int]], with noteCollection: NoteCollection,
                                       firstNoteIndex: Int) throws {
        try replaceNotes(at: flatIndexes, with: [noteCollection], firstNoteIndex: firstNoteIndex)
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
        if !toModify.validate() {
            throw TupletError.replacementNotSameDuration
        } else {
            self = toModify
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

    private mutating func removeNotesRec(at flatIndexes: [[Int]]) throws {
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
            try tuplet.removeNotesRec(at: sliced)
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
                let removeRange = tupletGroup[0][1]...tupletGroup[tupletGroup.count - 1][1]
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
            let removeRange = flatIndexes[0][0]...flatIndexes[flatIndexes.count - 1][0]
            notes.removeSubrange(removeRange)
        }
    }

    private mutating func removeNotes(at flatIndexes: [[Int]]) throws {
        let counts = Set(flatIndexes.map { $0.count }) // .sorted().reversed()
        let flatIndexCountGroups = counts.map { count in
            flatIndexes.filter { flatIndex in
                return flatIndex.count == count
            }
        }
        for flatIndexes in flatIndexCountGroups {
            try removeNotesRec(at: flatIndexes)
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
            notesTicks += noteCollection.noteDuration.ticks * noteCollection.noteTimingCount
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
