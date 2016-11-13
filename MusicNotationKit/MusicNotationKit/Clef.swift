//
//  Clef.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 10/16/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

public struct Clef {

    /**
     The tone that defines the clef. This tone is specified to be at a
     certain `StaffLocation` using the `staffLocation` property.
     */
    public let tone: Tone?

    /**
     The location on the staff at which the tone for the clef is located.
     */
    public let staffLocation: StaffLocation

    /**
     You can create a custom clef by providing a tone and line number.

     - parameter tone: The tone that the clef represents. Tone is optional to support un-pitched (i.e. drums)
     - parameter location: The location on the staff
     */
    public init(tone: Tone?, location: StaffLocation) {
        self.tone = tone
        self.staffLocation = location
    }

    public static let treble = Clef(tone: Tone(noteLetter: .g, octave: .octave4), location: StaffLocation(type: .line, number: 1))
    public static let bass = Clef(tone: Tone(noteLetter: .f, octave: .octave3), location: StaffLocation(type: .line, number: 3))
    public static let tenor = Clef(tone: Tone(noteLetter: .c, octave: .octave4), location: StaffLocation(type: .line, number: 3))
    public static let alto = Clef(tone: Tone(noteLetter: .c, octave: .octave4), location: StaffLocation(type: .line, number: 2))
    /// Un-pitched (drums, percussion, etc.)
    public static let neutral = Clef(tone: nil, location: StaffLocation(type: .line, number: 2))
    /// For tabulature (guitar, etc.)
    public static let tab = Clef(tone: nil, location: StaffLocation(type: .line, number: 2))
    // Less common
    public static let frenchViolin = Clef(tone: Tone(noteLetter: .g, octave: .octave4), location: StaffLocation(type: .line, number: 0))
    public static let soprano = Clef(tone: Tone(noteLetter: .c, octave: .octave4), location: StaffLocation(type: .line, number: 0))
    public static let mezzoSoprano = Clef(tone: Tone(noteLetter: .c, octave: .octave4), location: StaffLocation(type: .line, number: 1))
    public static let baritone = Clef(tone: Tone(noteLetter: .f, octave: .octave3), location: StaffLocation(type: .line, number: 4))
    // TODO: Is this one correct?
    public static let suboctaveTreble = Clef(tone: Tone(noteLetter: .g, octave: .octave3), location: StaffLocation(type: .line, number: 1))

    internal func tone(at location: StaffLocation) throws -> Tone? {
        guard let tone = tone else { return nil }
        let largestNoteLetter = NoteLetter.b.rawValue
        let delta = location.halfSteps - staffLocation.halfSteps
        guard delta != 0 else {
            return tone
        }
        let noteValue = tone.noteLetter.rawValue
        let newNoteAbsoluteValue = noteValue + delta
        let startingNoteValue = newNoteAbsoluteValue > 0 ? 0 : largestNoteLetter
        let newNoteValue = newNoteAbsoluteValue % largestNoteLetter
        guard let newNoteLetter = NoteLetter(rawValue: newNoteValue == 0 ? largestNoteLetter : startingNoteValue + newNoteValue) else {
            assertionFailure("modulus failed, because logic is flawed")
            throw ClefError.internalError
        }
        let octaveDeltaRaw = Double(newNoteAbsoluteValue) / Double(largestNoteLetter)
        let octaveDelta: Int = {
            switch octaveDeltaRaw {
            case 1.0: return 0
            case 0.0: return -1
            default: return Int(floor(octaveDeltaRaw))
            }
        }()
        let newOctaveValue = tone.octave.rawValue + octaveDelta
        guard let newOctave = Octave(rawValue: newOctaveValue) else {
            throw ClefError.octaveOutOfRange
        }
        return Tone(noteLetter: newNoteLetter, octave: newOctave)
    }
}

public enum ClefError: Error {
    case octaveOutOfRange
    case internalError
}

extension Clef: Equatable {
    public static func ==(lhs: Clef, rhs: Clef) -> Bool {
        return lhs.tone == rhs.tone && lhs.staffLocation.halfSteps == rhs.staffLocation.halfSteps
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
            return "\(tone!)@\(staffLocation.locationType)\(staffLocation.number)"
        }
    }
}
