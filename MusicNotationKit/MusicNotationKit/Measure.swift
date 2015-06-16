//
//  Measure.swift
//  MusicNotation
//
//  Created by Kyle Sherman on 6/12/15.
//  Copyright (c) 2015 Kyle Sherman. All rights reserved.
//

public struct Measure {
	
	private(set) var timing: Timing
	private(set) var notes: [NoteCollection] = []
	private(set) var isComplete: Bool = false
	
	public mutating func addNote(note: Note) throws {
		// TODO: Implement
	}
	
	public mutating func insertNote(note: Note, atIndex index: Int) throws {
		// TODO: Implement
	}
	
	public mutating func removeNote(note: Note) throws {
		// TODO: Implement
	}
	
	public mutating func removeNoteAtIndex(index: Int) throws {
		// TODO: Implement
	}
}

extension Measure: NotesHolder {
	
}
