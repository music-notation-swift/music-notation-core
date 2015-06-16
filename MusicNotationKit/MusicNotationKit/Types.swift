//
//  Types.swift
//  MusicNotation
//
//  Created by Kyle Sherman on 6/12/15.
//  Copyright (c) 2015 Kyle Sherman. All rights reserved.
//

// TODO: Octave

public enum Striking {
	case None
	case Left, Up
	case Right, Down
}

public enum NoteDuration {
	case Whole
	case Half
	case Quarter
	case Eighth
	case Sixteenth
	case ThirtySecond
	case SixtyFourth
}

public enum Accidental {
	case None
	case Sharp
	case DoubleSharp
	case Flat
	case DoubleFlat
	case Natural
}

public enum NoteLetter {
	case A
	case B
	case C
	case D
	case E
	case F
	case G
}

public enum Clef {
	case Treble
	case Bass
}

public enum Instrument {
	case Guitar6
	case Drums
}

public enum Dot {
	case None
	case Single
	case Double
}

public enum Accent {
	case None
	case Standard
	case Strong
}

public enum Dynamics {
	case None
	case Ppp
	case Pp
	case P
	case Mp
	case Mf
	case F
	case Ff
	case Fff
}
