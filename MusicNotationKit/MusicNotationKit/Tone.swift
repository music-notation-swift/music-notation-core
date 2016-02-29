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
		var result = String(format:"%@%d", String(self.noteLetter), self.octave.rawValue)
		if (self.accidental != nil ) {
			result = String(format: "[%@%@]", result, self.accidental!.rawValue)
		}
		return result
	}
}
