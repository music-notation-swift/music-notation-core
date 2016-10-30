//
//  Clef.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 10/16/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

public struct Clef {

    public let tone: Tone?
    /**
     Starts from 0 on the first line (from the bottom). Ledger lines below that are negative.
     Each increase by 1 moves a half step. i.e. 1 is the first space on the staff.
     */
    public let lineNumber: Int

    /**
     You can create a custom clef by providing a tone and line number.
     
     - parameter tone: The tone that the clef represents
     - parameter lineNumber: The number representing the location on the staff. The `lineNumber`
        starts at 0 for the first line on the staff (from the bottom). Lower ledger lines are negative 
        and upper ledger lines are positive. Each addition of 1 increases by a half step. This brings
        you to either the next space or line.
     */
    public init(tone: Tone, lineNumber: Int) {
        self.init(tone: .some(tone), lineNumber: lineNumber)
    }

    private init(tone: Tone?, lineNumber: Int) {
        self.tone = tone
        self.lineNumber = lineNumber
    }

    public static let treble = Clef(tone: Tone(noteLetter: .g, octave: .octave4), lineNumber: 3)
    public static let bass = Clef(tone: Tone(noteLetter: .f, octave: .octave3), lineNumber: 1)
    public static let tenor = Clef(tone: Tone(noteLetter: .c, octave: .octave4), lineNumber: 1)
    public static let alto = Clef(tone: Tone(noteLetter: .c, octave: .octave4), lineNumber: 2)
    /// Un-pitched (drums, percussion, etc.)
    public static let neutral = Clef(tone: nil, lineNumber: 2)
    /// For tabulature (guitar, etc.)
    public static let tab = Clef(tone: nil, lineNumber: 2)
    // Less common
    public static let frenchViolin = Clef(tone: Tone(noteLetter: .g, octave: .octave4), lineNumber: 4)
    public static let soprano = Clef(tone: Tone(noteLetter: .c, octave: .octave4), lineNumber: 4)
    public static let mezzoSoprano = Clef(tone: Tone(noteLetter: .c, octave: .octave4), lineNumber: 3)
    public static let baritone = Clef(tone: Tone(noteLetter: .f, octave: .octave3), lineNumber: 2)
    // TODO: Is this one correct?
    public static let suboctaveTreble = Clef(tone: Tone(noteLetter: .g, octave: .octave3), lineNumber: 3)
}

extension Clef: Equatable {
    public static func ==(lhs: Clef, rhs: Clef) -> Bool {
        return lhs.tone == rhs.tone && lhs.lineNumber == rhs.lineNumber
    }
}

extension Clef: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case Clef.treble: return "treble"
        case Clef.bass: return "bass"
        case Clef.tenor: return "tenor"
        case Clef.alto: return "alto"
        case Clef.neutral: return "neutral"
        case Clef.frenchViolin: return "frenchViolin"
        case Clef.soprano: return "soprano"
        case Clef.mezzoSoprano: return "mezzoSoprano"
        case Clef.baritone: return "baritone"
        case Clef.suboctaveTreble: return "suboctaveTreble"
        default:
            return "\(tone!)@\(lineNumber)"
        }
    }
}
