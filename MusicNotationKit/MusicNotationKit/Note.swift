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
	
	public mutating func modifyTie(tie: Tie) throws {
		// Nothing to do if it's the same value
		guard self.tie != tie else { return }
		
		switch (self.tie, tie) {
		case (.Begin?, .End), (.End?, .Begin):
			self.tie = .BeginAndEnd
		case (nil, let value):
			self.tie = value
		default:
			throw NoteError.InvalidRequestedTieState
		}
	}
	
	public mutating func removeTie(currentTie: Tie) throws {
		switch (currentTie, tie) {
		case (.BeginAndEnd, _):
			throw NoteError.InvalidRequestedTieState
		case (_, nil):
			return
		case (let request, let current?) where request == current:
			tie = nil
		case (.Begin, .BeginAndEnd?):
			tie = .End
		case (.End, .BeginAndEnd?):
			tie = .Begin
		default:
			throw NoteError.InvalidRequestedTieState
		}
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
	
	public var noteCount: Int { return 1 }
}

extension Note: CustomDebugStringConvertible {
	public var debugDescription: String {
		let tonesString: String
		if tones.count > 1 {
			tonesString = "\(tones)"
		} else {
			if let tone = tones.first {
				tonesString = "\(tone)"
			} else {
				tonesString = ""
			}
		}
		let dotString: String
		if let dot = dot {
			dotString = "\(dot)"
		} else {
			dotString = ""
		}
		return "\(noteDuration)\(dotString)\(tonesString)\(isRest ? "R" : "")"
	}
}

public enum NoteError: ErrorType {
	case InvalidRequestedTieState
}
