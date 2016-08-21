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
    public private(set) var notes: [NoteCollection]
    /// The number of notes of the specified duration that this tuplet contains
    public var noteCount: Int { return notes.count }
    /// The duration of the notes that define this tuplet
    public let noteDuration: NoteDuration
    /// The number of notes that this tuplet fits in the space of
    public let noteTimingCount: Int

    public init(_ count: Int, _ baseNoteDuration: NoteDuration, inSpaceOf baseCount: Int? = nil, notes: [NoteCollection]) throws {
        self.notes = notes
        noteDuration = baseNoteDuration
        noteTimingCount = baseCount
    }

    // MARK: - Methods
    // MARK: Public

    public mutating func replaceNote(at index: Int, with notes: [Note]) throws {
        notes[index] = note
    }

    public mutating func replaceNote(at index: Int, with tuplet: Tuplet) throws {

    }

    public mutating func replaceNotes(in range: Range<Int>, with notes: [Note]) throws {

    }

    public mutating func replaceNotes(in range: Range<Int>, with tuplet: Tuplet) throws {

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
        return "\(notes)"
    }
}

public enum TupletError: Error {
    case restsNotValid
    case notSameDuration
    case invalidIndex
}
