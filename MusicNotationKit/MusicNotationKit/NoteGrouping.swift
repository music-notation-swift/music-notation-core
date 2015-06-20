//
//  NoteGrouping.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 6/15/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

/**
Represents Duplet, Triplet, ... Septuplet
*/
public struct NoteGrouping {
	
	public var duration: NoteDuration {
		return notes[0].noteDuration
	}
	
	private(set) var notes: [Note]
	
	public init(notes: [Note]) throws {
		switch notes.count {
		case 2...7:
			try NoteGrouping.verifySameDuration(notes)
			try NoteGrouping.verifyNoRests(notes)
			self.notes = notes
		default:
			throw NoteGroupingError.InvalidNumberOfNotes
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
			throw NoteGroupingError.InvalidIndex
		}
		notes.insert(note, atIndex: index)
	}
	
	public mutating func removeNoteAtIndex(index: Int) throws {
		guard notes.count <= 2 else {
			throw NoteGroupingError.TooFewNotes
		}
		guard index < notes.count else {
			throw NoteGroupingError.InvalidIndex
		}
		notes.removeAtIndex(index)
	}
	
	// MARK: Private
	// MARK: Verification
	
	private func verifyNewNote(note: Note) throws {
		try verifyNotFull()
		try verifySameDuration(newNote: note)
		try NoteGrouping.verifyNotRest(note)
	}
	
	private static func verifyNoRests(notes: [Note]) throws {
		for note in notes {
			try verifyNotRest(note)
		}
	}
	
	private static func verifyNotRest(note: Note) throws {
		if note.isRest == true {
			throw NoteGroupingError.RestsNotValid
		}
	}
	
	private static func verifySameDuration(notes: [Note]) throws {
		// Map all durations into new set
		// If set has more than 1 member, it is invalid
		let durations: Set<NoteDuration> = Set(notes.map { $0.noteDuration })
		if durations.count > 1 {
			throw NoteGroupingError.NotSameDuration
		}
	}
	
	private func verifySameDuration(newNote newNote: Note) throws {
		if newNote.noteDuration != duration {
			throw NoteGroupingError.NotSameDuration
		}
	}
	
	private func verifyNotFull() throws {
		if notes.count >= 7 {
			throw NoteGroupingError.GroupingFull
		}
	}
}

extension NoteGrouping: NoteCollection {
	
	
}

public enum NoteGroupingError: ErrorType {
	case InvalidNumberOfNotes
	case GroupingFull
	case TooFewNotes
	case RestsNotValid
	case NotSameDuration
	case InvalidIndex
}
