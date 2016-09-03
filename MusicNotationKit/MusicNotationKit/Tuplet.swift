//
//  Tuplet.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 6/15/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

/**
 Represents Duplet, Triplet, ... Septuplet
 */
public struct Tuplet {

    public var duration: NoteDuration {
        return notes[0].noteDuration
    }

    private(set) var notes: [Note]

    public init(notes: [Note]) throws {
        switch notes.count {
        case 2...7:
            try Tuplet.verifySameDuration(notes)
            try Tuplet.verifyNoRests(notes)
            self.notes = notes
        default:
            throw TupletError.invalidNumberOfNotes
        }
    }

    // MARK: - Methods
    // MARK: Public

    public mutating func appendNote(_ note: Note) throws {
        try verifyNewNote(note)
        notes.append(note)
    }

    public mutating func insertNote(_ note: Note, at index: Int) throws {
        try verifyNewNote(note)
        if index > 6 {
            throw TupletError.invalidIndex
        }
        notes.insert(note, at: index)
    }

    public mutating func removeNote(at index: Int) throws {
        guard notes.count <= 2 else {
            throw TupletError.tooFewNotes
        }
        guard index < notes.count else {
            throw TupletError.invalidIndex
        }
        notes.remove(at: index)
    }

    public mutating func replaceNote(at index: Int, with note: Note) throws {
        try Tuplet.verifyNotRest(note)
        notes[index] = note
    }

    // MARK: Private
    // MARK: Verification

    private func verifyNewNote(_ note: Note) throws {
        try verifyNotFull()
        try verifySameDuration(newNote: note)
        try Tuplet.verifyNotRest(note)
    }

    private static func verifyNoRests(_ notes: [Note]) throws {
        for note in notes {
            try verifyNotRest(note)
        }
    }

    private static func verifyNotRest(_ note: Note) throws {
        if note.isRest == true {
            throw TupletError.restsNotValid
        }
    }

    private static func verifySameDuration(_ notes: [Note]) throws {
        // Map all durations into new set
        // If set has more than 1 member, it is invalid
        let durations: Set<NoteDuration> = Set(notes.map { $0.noteDuration })
        if durations.count > 1 {
            throw TupletError.notSameDuration
        }
    }

    private func verifySameDuration(newNote: Note) throws {
        if newNote.noteDuration != duration {
            throw TupletError.notSameDuration
        }
    }

    private func verifyNotFull() throws {
        if notes.count >= 7 {
            throw TupletError.groupingFull
        }
    }
}

extension Tuplet: Equatable {
    public static func ==(lhs: Tuplet, rhs: Tuplet) -> Bool {
        return lhs.notes == rhs.notes
    }
}

extension Tuplet: NoteCollection {
    
    public var noteCount: Int { return notes.count }
}

extension Tuplet: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\(noteCount)\(notes)"
    }
}

public enum TupletError: Error {
    case invalidNumberOfNotes
    case groupingFull
    case tooFewNotes
    case restsNotValid
    case notSameDuration
    case invalidIndex
}
