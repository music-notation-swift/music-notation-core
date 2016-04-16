//
//  Tone.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 6/15/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

public struct Tone {
	
	public let accidental: Accidental?
	public let noteLetter: NoteLetter
	public let octave: Octave
	
	public init(accidental: Accidental? = nil, noteLetter: NoteLetter, octave: Octave) {
		self.accidental = accidental
		self.noteLetter = noteLetter
		self.octave = octave
	}
}

extension Tone: CustomDebugStringConvertible {
	public var debugDescription: String {
		let accidentalString: String
		if let accidental = accidental {
			accidentalString = "\(accidental)"
		} else {
			accidentalString = ""
		}
		return "\(noteLetter)\(octave.rawValue)\(accidentalString)"
	}
}

extension Tone: Equatable {}

public func ==(lhs: Tone, rhs: Tone) -> Bool {
	if lhs.accidental == rhs.accidental &&
		lhs.noteLetter == rhs.noteLetter &&
		lhs.octave == rhs.octave {
			return true
	} else {
		return false
	}
}
