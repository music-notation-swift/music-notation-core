//
//  ImmutableMeasure.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 3/6/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

public protocol ImmutableMeasure: NotesHolder {
	
	var timeSignature: TimeSignature { get }
	var key: Key { get }
	var notes: [NoteCollection] { get }
    var noteCount: Int { get }
	
	init(timeSignature: TimeSignature, key: Key)
	init(timeSignature: TimeSignature, key: Key, notes: [NoteCollection])
}
