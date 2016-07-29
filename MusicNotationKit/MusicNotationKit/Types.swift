//
//  Types.swift
//  MusicNotation
//
//  Created by Kyle Sherman on 6/12/15.
//  Copyright (c) 2015 Kyle Sherman. All rights reserved.
//

public enum Octave: Int {
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

public enum Striking {
    case left, up
    case right, down
}

public enum NoteDuration {
    case whole
    case half
    case quarter
    case eighth
    case sixteenth
    case thirtySecond
    case sixtyFourth
}

extension NoteDuration: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .whole: return "1"
        case .half: return "1/2"
        case .quarter: return "1/4"
        case .eighth: return "1/8"
        case .sixteenth: return "1/16"
        case .thirtySecond: return "1/32"
        case .sixtyFourth: return "1/64"
        }
    }
}

public enum Accidental {
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

public enum NoteLetter {
    case a
    case b
    case c
    case d
    case e
    case f
    case g
}

public enum Clef {
    case treble
    case bass
}

public enum Instrument {
    case guitar6
    case drums
}

public enum Dot {
    case single
    case double
}

extension Dot: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .single: return "."
        case .double: return ".."
        }
    }
}

public enum Accent {
    case standard
    case strong
    case ghost
}

public enum Dynamics {
    case ppp
    case pp
    case p
    case mp
    case mf
    case f
    case ff
    case fff
}

public enum Interval: Int {
    case unison = 0
    case min2
    case maj2
    case min3
    case maj3
    case perfect4
    case aug4
    case perfect5
    case min6
    case maj6
    case min7
    case maj7
    case octave
    case min9
    case maj9
    case min10
    case maj10
    case perfect11
    case aug11
    case perfect12
    case min13
    case maj13
    case min14
    case maj14
    case perfect15
}

public enum AugInterval: Int {
    case dim2 = 0
    case augUnison
    case dim3
    case aug2
    case dim4
    case aug3
    case dim5
    case dim6
    case aug5
    case dim7
    case aug6
    case dimOctave
    case aug7 /* TODO: Also dim9?? */
    case augOctave
    case dim10
    case aug9
    case dim11
    case aug10
    case dim12
    case dim13
    case aug12
    case dim14
    case aug13
    case dim15
    case aug14
    case aug15
}

public enum Tie {
    case begin
    case end
    case beginAndEnd
}

public enum KeyType {
    case major
    case minor
}

