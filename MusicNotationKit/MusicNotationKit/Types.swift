//
//  Types.swift
//  MusicNotation
//
//  Created by Kyle Sherman on 6/12/15.
//  Copyright (c) 2015 Kyle Sherman. All rights reserved.
//

public enum Octave {
	case OctaveNegative1
	case Octave0
	case Octave1
	case Octave2
	case Octave3
	case Octave4
	case Octave5
	case Octave6
	case Octave7
	case Octave8
	case Octave9
}

public enum Striking {
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
	case Single
	case Double
}

public enum Accent {
	case Standard
	case Strong
	case Ghost
}

public enum Dynamics {
	case Ppp
	case Pp
	case P
	case Mp
	case Mf
	case F
	case Ff
	case Fff
}

public enum Interval: Int {
	case Unison = 0
	case Min2
	case Maj2
	case Min3
	case Maj3
	case Perfect4
	case Aug4
	case Perfect5
	case Min6
	case Maj6
	case Min7
	case Maj7
	case Octave
	case Min9
	case Maj9
	case Min10
	case Maj10
	case Perfect11
	case Aug11
	case Perfect12
	case Min13
	case Maj13
	case Min14
	case Maj14
	case Perfect15
}

public enum AugInterval: Int {
	case Dim2 = 0
	case AugUnison
	case Dim3
	case Aug2
	case Dim4
	case Aug3
	case Dim5
	case Dim6
	case Aug5
	case Dim7
	case Aug6
	case DimOctave
	case Aug7 /* TODO: Also dim9?? */
	case AugOctave
	case Dim10
	case Aug9
	case Dim11
	case Aug10
	case Dim12
	case Dim13
	case Aug12
	case Dim14
	case Aug13
	case Dim15
	case Aug14
	case Aug15
}

public enum Tie {
	case Begin
	case End
}

public enum KeyType {
	case Major
	case Minor
}

