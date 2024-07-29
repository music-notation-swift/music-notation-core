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
	case left
    case up
	case right
    case down
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

/// Defines the type of instrument.
public enum Instrument: Sendable {
    case pitched
    case tab(strings: Int)
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

public struct Bend: Sendable {
    let interval: Int
    let duration: Int
}

public enum BendType: Sendable {
    case bend(bendValue: Bend)
    case release(releaseValue: Bend)
    case bendAndRelease(bendValue: Bend, holdDuration: Int, releaseValue: Bend)
    case hold
    case prebend(interval: Int)
    case prebendAndBend(interval: Int, bendValue: Bend)
    case prebendAndRelease(interval: Int, releaseValue: Bend)
}

