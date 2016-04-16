//
//  RepeatedMeasure.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 3/9/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

public struct RepeatedMeasure: ImmutableMeasure {
	
	public let timeSignature: TimeSignature
	public let key: Key
	private(set) var notes: [NoteCollection]
	
	public init(timeSignature: TimeSignature, key: Key) {
		self.init(timeSignature: timeSignature, key: key, notes: [])
	}
	
	internal init(timeSignature: TimeSignature, key: Key, notes: [NoteCollection]) {
		self.timeSignature = timeSignature
		self.key = key
		self.notes = notes
	}
	
	internal init(immutableMeasure: ImmutableMeasure) {
		self.init(timeSignature: immutableMeasure.timeSignature, key: immutableMeasure.key,
			notes: immutableMeasure.notes)
	}
}

extension RepeatedMeasure: Equatable {}

public func ==(lhs: RepeatedMeasure, rhs: RepeatedMeasure) -> Bool {
	guard lhs.timeSignature == rhs.timeSignature &&
		lhs.key == rhs.key &&
		lhs.notes.count == rhs.notes.count else {
			return false
	}
	for i in 0..<lhs.notes.count {
		if lhs.notes[i] == rhs.notes[i] {
			continue
		} else {
			return false
		}
	}
	return true
}
