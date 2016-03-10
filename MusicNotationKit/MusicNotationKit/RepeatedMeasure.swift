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
}
