//
//  Measure.swift
//  MusicNotation
//
//  Created by Kyle Sherman on 6/12/15.
//  Copyright (c) 2015 Kyle Sherman. All rights reserved.
//

public struct Measure {
	
	private(set) var timeSignature: TimeSignature
	private(set) var key: Key
	private(set) var notes: [NoteCollection] = []
	
	public init(timeSignature: TimeSignature, key: Key) {
		self.init(timeSignature: timeSignature, key: key, notes: [])
	}
	
	internal init(timeSignature: TimeSignature, key: Key, notes: [NoteCollection]) {
		self.timeSignature = timeSignature
		self.key = key
		self.notes = notes
	}
	
	public mutating func addNote(note: Note) {
		notes.append(note)
	}
	
	public mutating func insertNote(note: Note, atIndex index: Int) throws {
		// TODO: Implement
	}
	
	public mutating func removeNoteAtIndex(index: Int) throws {
		// TODO: Implement
	}
	
	public mutating func removeNotesInRange(indexRange: Range<Int>) throws {
		// TODO: Implement
	}
	
	public mutating func addTuplet(tuplet: Tuplet) {
		// TODO: Implement
	}
	
	public mutating func insertTuplet(tuplet: Tuplet, atIndex index: Int) throws {
		// TODO: Implement
	}
	
	public mutating func removeTuplet(tuplet: Tuplet, atIndex index: Int) throws {
		// TODO: Implement
	}
	
	public func startTieAtIndex(index: Int) throws {
		// TODO: Implement
		// Fails if there is no next note
		// Needs to use that index to index into tuplets if needed
	}
	
	public func removeTieAtIndex(index: Int) throws {
		// TODO: Implement
		// Fails if there the tie does not begin at the given index
	}
	
	internal func noteCollectionIndexFromNoteIndex(index: Int) -> (noteIndex: Int, tupletIndex: Int?)? {
		// Gets the index of the given element in the notes array by translating the index of the
		// single note within the NoteCollection array.
		guard index >= 0 && notes.count > 0 else { return nil }
		// Expand notes and tuplets into indexes
		// TODO: Move this into a method that is called on didSet of notes??
		var noteIndexes: [(Int, Int?)] = []
		for (i, noteCollection) in notes.enumerate() {
			switch noteCollection.noteCount {
			case 1:
				noteIndexes.append((noteIndex: i, tupletIndex: nil))
			case let count:
				for j in 0..<count {
					noteIndexes.append((noteIndex: i, tupletIndex: j))
				}
			}
		}
		guard index < noteIndexes.count else { return nil }
		return noteIndexes[index]
	}
}

extension Measure: NotesHolder {
	
}

public enum MeasureError: ErrorType {
	case NoNextNoteToTie
	case NoTieBeginsAtIndex
}
