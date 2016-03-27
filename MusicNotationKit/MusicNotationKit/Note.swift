//
//  Note.swift
//  MusicNotation
//
//  Created by Kyle Sherman on 6/12/15.
//  Copyright (c) 2015 Kyle Sherman. All rights reserved.
//

public struct Note {
	
	public let noteDuration: NoteDuration
	public let tones: [Tone]
	
	public let isRest: Bool
	
	public var dot: Dot?
	public var accent: Accent?
	public var isStaccato: Bool = false
	public var dynamics: Dynamics?
	public var striking: Striking?
	
	internal var tie: Tie?
	
	/**
	Initialize a rest.
	*/
	public init(noteDuration: NoteDuration) {
		self.noteDuration = noteDuration
		self.tones = []
		self.isRest = true
	}
	
	/**
	Initialize a note with a single tone.
	*/
	public init(noteDuration: NoteDuration, tone: Tone) {
		self.noteDuration = noteDuration
		self.tones = [tone]
		self.isRest = false
	}
	
	/**
	Initialize a note with multiple tones (chord).
	*/
	public init(noteDuration: NoteDuration, tones: [Tone]) {
		isRest = false
		self.noteDuration = noteDuration
		self.tones = tones
	}
}

extension Note: Equatable {}

public func ==(lhs: Note, rhs: Note) -> Bool {
	if lhs.noteDuration == rhs.noteDuration &&
		lhs.tones == rhs.tones &&
		lhs.isRest == rhs.isRest &&
		lhs.dot == rhs.dot &&
		lhs.accent == rhs.accent &&
		lhs.isStaccato == rhs.isStaccato &&
		lhs.dynamics == rhs.dynamics &&
		lhs.striking == rhs.striking &&
		lhs.tie == rhs.tie {
			return true
	} else {
		return false
	}
}

extension Note: NoteCollection {
	
	internal var noteCount: Int { return 1 }
}
