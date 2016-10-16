//
//  Clef.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 10/16/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

public struct Clef {

    public let tone: Tone?
    public let lineNumber: Double // Could be changed to Float. Don't need that precision.

    /**
     You can create a custom clef by providing a tone and line number.
     
     - parameter tone: The tone that the clef represents
     - parameter lineNumber: The number representing the location on the staff. The `lineNumber`
        starts at 0 for the first line on the staff. All spaces are the number of the preceding
        line + 0.5. Upper ledger lines are negative and lower ledger lines are positive.
     */
    public init(tone: Tone, lineNumber: Double) throws {
        try self.init(tone: .some(tone), lineNumber: lineNumber)
    }

    private init(tone: Tone?, lineNumber: Double) throws {
        guard lineNumber.truncatingRemainder(dividingBy: 0.5) == 0 else {
            throw ClefError.invalidLineNumber
        }
        self.tone = tone
        self.lineNumber = lineNumber
    }

    public static let treble = try! Clef(tone: Tone(noteLetter: .g, octave: .octave4), lineNumber: 3)
    public static let bass = try! Clef(tone: Tone(noteLetter: .f, octave: .octave3), lineNumber: 1)
    public static let tenor = try! Clef(tone: Tone(noteLetter: .c, octave: .octave4), lineNumber: 1)
    public static let alto = try! Clef(tone: Tone(noteLetter: .c, octave: .octave4), lineNumber: 2)
    /// Un-pitched (drums, percussion, etc.)
    public static let neutral = try! Clef(tone: nil, lineNumber: 2)
    /// For tabulature (guitar, etc.)
    public static let tab = try! Clef(tone: nil, lineNumber: 2)
    // Less common
    public static let frenchViolin = try! Clef(tone: Tone(noteLetter: .g, octave: .octave4), lineNumber: 4)
    public static let soprano = try! Clef(tone: Tone(noteLetter: .c, octave: .octave4), lineNumber: 4)
    public static let mezzoSoprano = try! Clef(tone: Tone(noteLetter: .c, octave: .octave4), lineNumber: 3)
    public static let baritone = try! Clef(tone: Tone(noteLetter: .f, octave: .octave3), lineNumber: 2)
    // TODO: Is this one correct?
    public static let suboctaveTreble = try! Clef(tone: Tone(noteLetter: .g, octave: .octave3), lineNumber: 3)
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

public enum ClefError: Error {
    case invalidLineNumber
}
