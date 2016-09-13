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
    public var noteCount: Int { return notes.count }
    /// The duration of the notes that define this tuplet
    public let noteDuration: NoteDuration
    /// The number of notes that this tuplet fits in the space of
    public let noteTimingCount: Int
    /// A 2-dimensional array that can be used to index into every note in the tuplet within compound tuplets as well.
    public var flatIndexes: [[Int]] = [[Int]]()

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

    public mutating func replaceNote(at index: Int, with note: Note) throws {
        try replaceNote(at: index, with: note as NoteCollection)
    }

    public mutating func replaceNote(at index: Int, with notes: [Note]) throws {
        throw NSError()
    }

    public mutating func replaceNote(at index: Int, with tuplet: Tuplet) throws {
        try replaceNote(at: index, with: tuplet)
    }

    public mutating func replaceNotes(in range: Range<Int>, with notes: Note) throws {
        throw NSError()
    }

    public mutating func replaceNotes(in range: Range<Int>, with notes: [Note]) throws {
        throw NSError()
    }

    public mutating func replaceNotes(in range: Range<Int>, with tuplet: Tuplet) throws {
        throw NSError()
    }

    // MARK: Private

    internal mutating func replaceNote(at index: Int, with noteCollection: NoteCollection) throws {
        // validate they are the same duration
        let noteToReplace = try note(at: index)
        let noteCollectionDuration = NoteDuration.number(
            of: noteToReplace.noteDuration,
            within: noteCollection.noteDuration) *
            Double(noteCollection.noteTimingCount)
        guard noteCollectionDuration == 1 else {
            throw TupletError.replacingCollectionNotSameDuration
        }
        let fullIndexes = flatIndexes[index]
        try replaceNote(at: fullIndexes, with: noteCollection)
    }

    private mutating func replaceNote(at indexes: [Int], with newCollection: NoteCollection) throws {
        guard indexes.count != 1 else {
            notes[indexes[0]] = newCollection
            return
        }
        guard var tuplet = notes[indexes[0]] as? Tuplet else {
            assertionFailure("all indexes before the last should be tuplets. Must be an error in flatIndexes")
            throw TupletError.internalError
        }
        let slice = Array(indexes[1..<indexes.count])
        try tuplet.replaceNote(at: slice, with: newCollection)
        notes[indexes[0]] = tuplet
    }

    internal mutating func replaceNote(at index: Int, with noteCollections: [NoteCollection]) throws {
        throw NSError()
    }

    internal mutating func replaceNotes(in range: Range<Int>, with noteCollection: NoteCollection) throws {
        throw NSError()
    }

    internal mutating func replaceNotes(in range: Range<Int>, with noteCollections: [NoteCollection]) throws {
        throw NSError()
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
    case replacingCollectionNotSameDuration
    case internalError
}
