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
			throw TupletError.InvalidNumberOfNotes
		}
	}
	
	// MARK: - Methods
	// MARK: Public
	
	public mutating func appendNote(note: Note) throws {
		try verifyNewNote(note)
		notes.append(note)
	}
	
	public mutating func insertNote(note: Note, atIndex index: Int) throws {
		try verifyNewNote(note)
		if index > 6 {
			throw TupletError.InvalidIndex
		}
		notes.insert(note, atIndex: index)
	}
	
	public mutating func removeNoteAtIndex(index: Int) throws {
		guard notes.count <= 2 else {
			throw TupletError.TooFewNotes
		}
		guard index < notes.count else {
			throw TupletError.InvalidIndex
		}
		notes.removeAtIndex(index)
	}
	
	// MARK: Private
	// MARK: Verification
	
	private func verifyNewNote(note: Note) throws {
		try verifyNotFull()
		try verifySameDuration(newNote: note)
		try Tuplet.verifyNotRest(note)
	}
	
	private static func verifyNoRests(notes: [Note]) throws {
		for note in notes {
			try verifyNotRest(note)
		}
	}
	
	private static func verifyNotRest(note: Note) throws {
		if note.isRest == true {
			throw TupletError.RestsNotValid
		}
	}
	
	private static func verifySameDuration(notes: [Note]) throws {
		// Map all durations into new set
		// If set has more than 1 member, it is invalid
		let durations: Set<NoteDuration> = Set(notes.map { $0.noteDuration })
		if durations.count > 1 {
			throw TupletError.NotSameDuration
		}
	}
	
	private func verifySameDuration(newNote newNote: Note) throws {
		if newNote.noteDuration != duration {
			throw TupletError.NotSameDuration
		}
	}
	
	private func verifyNotFull() throws {
		if notes.count >= 7 {
			throw TupletError.GroupingFull
		}
	}
}

extension Tuplet: NoteCollection {
	
}

public enum TupletError: ErrorType {
	case InvalidNumberOfNotes
	case GroupingFull
	case TooFewNotes
	case RestsNotValid
	case NotSameDuration
	case InvalidIndex
}
