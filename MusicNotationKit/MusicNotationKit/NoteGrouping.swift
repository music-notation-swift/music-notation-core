//
//  NoteGrouping.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 6/15/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

public struct NoteGrouping {
	
	private(set) var notes: [Note]
	
	public mutating func appendNote(note: Note) throws {
		// TODO: Implement
		// Try to add to notes, but can only have 2-7 in a set
	}
	
	public mutating func insertNote(note: Note, atIndex index: Int) throws {
		
	}
	
	public mutating func removeNote(note: Note) throws {
		
	}
	
	public mutating func removeNote(note: Note, atIndex index: Int) throws {
		
	}
}

extension NoteGrouping: NoteCollection {
	
	
}
