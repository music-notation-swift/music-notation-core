//
//  Tone.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 6/15/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

public struct Tone {
    
    public let noteLetter: NoteLetter
    public let accidental: Accidental
    public let octave: Octave
    
    public init(noteLetter: NoteLetter, accidental: Accidental = .natural, octave: Octave) {
        self.noteLetter = noteLetter
        self.accidental = accidental
        self.octave = octave
    }
}

extension Tone: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch accidental {
        case .natural:
            return "\(noteLetter)\(octave.rawValue)"
        default:
            return "\(noteLetter)\(accidental)\(octave.rawValue)"
        }
    }
}

extension Tone: Equatable {
    public static func ==(lhs: Tone, rhs: Tone) -> Bool {
        if lhs.accidental == rhs.accidental &&
            lhs.noteLetter == rhs.noteLetter &&
            lhs.octave == rhs.octave {
            return true
        } else {
            return false
        }
    }
}

extension Tone {
    public var midiNoteNumber: Int {
        var result = (octave.rawValue + 1) * 12
        
        switch noteLetter {
        case .c: break
        case .d: result += 2
        case .e: result += 4
        case .f: result += 5
        case .g: result += 7
        case .a: result += 9
        case .b: result += 11
        }
        
        switch accidental {
        case .natural:
            break
        case .flat:
            result -= 1
        case .sharp:
            result += 1
        case .doubleFlat:
            result -= 2
        case .doubleSharp:
            result += 2
        }
        
        return result
    }
}

extension Tone: Enharmonic {
    public func isEnharmonic(with other: Tone) -> Bool {
        return self.midiNoteNumber == other.midiNoteNumber
    }
}
