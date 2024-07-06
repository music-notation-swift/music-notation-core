//
//  Types.swift
//  MusicNotation
//
//  Created by Kyle Sherman on 06/12/2015.
//  Copyright (c) 2015 Kyle Sherman. All rights reserved.
//

public enum Octave: Int, Sendable {
	case octaveNegative1 = -1
	case octave0 = 0
	case octave1 = 1
	case octave2 = 2
	case octave3 = 3
	case octave4 = 4
	case octave5 = 5
	case octave6 = 6
	case octave7 = 7
	case octave8 = 8
	case octave9 = 9
}

public enum Striking: Sendable {
	case left, up
	case right, down
}

public enum Accidental: Sendable {
	case sharp
	case doubleSharp
	case flat
	case doubleFlat
	case natural
}

extension Accidental: CustomDebugStringConvertible {
	public var debugDescription: String {
		switch self {
		case .sharp: return "♯"
		case .doubleSharp: return "𝄪"
		case .flat: return "♭"
		case .doubleFlat: return "𝄫"
		case .natural: return "♮"
		}
	}
}

public enum NoteLetter: Int, Sendable {
	case c = 1
	case d
	case e
	case f
	case g
	case a
	case b
}

public enum Instrument {
	case guitar6
	case drums
}

public enum Accent: Sendable {
	case standard
	case strong
	case ghost
}

public enum Dynamics: Sendable {
	case ppp
	case pp
	case p
	case mp
	case mf
	case f
	case ff
	case fff
}

public enum Tie: Sendable {
	case begin
	case end
	case beginAndEnd
}

public enum KeyType: Sendable {
	case major
	case minor
}
