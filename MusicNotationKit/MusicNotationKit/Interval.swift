//
//  Interval.swift
//  MusicNotationKit
//
//  Created by Rob Hudson on 8/1/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

import Foundation

public enum IntervalQuality: String {
    case perfect
    case minor
    case major
    case diminished
    case augmented
    case doublyDiminished = "doubly diminished"
    case doublyAugmented = "doubly augmented"
    
    public var abbreviation: String {
        switch self {
        case .perfect:
            return "P"
        case .minor:
            return "m"
        case .major:
            return "M"
        case .diminished:
            return "d"
        case .augmented:
            return "A"
        case .doublyDiminished:
            return "dd"
        case .doublyAugmented:
            return "AA"
        }
    }
}

public struct Interval {
    public let quality: IntervalQuality
    public let number: Int
    
    public init?(quality: IntervalQuality, number: Int) {
        guard number > 0 else {
            return nil
        }
        
        let simpleInterval = ((number - 1) % 7) + 1
        
        switch simpleInterval {
        case 1, 4, 5:
            guard quality != .major && quality != .minor else {
                return nil
            }
        default:
            guard quality != .perfect else {
                return nil
            }
        }
        
        self.quality = quality
        self.number = number
    }
}

extension Interval: CustomDebugStringConvertible {
    public var debugDescription: String {
        var description = "\(quality.rawValue) "
        switch number {
        case 1:
            description += "unison"
        case 8:
            description += "octave"
        default:
            let formatter = NumberFormatter()
            if #available(OSX 10.11, *) {
                formatter.numberStyle = .ordinal
                description += formatter.string(from: number)!
            } else {
                description += "\(number)"
            }
        }
        
        return description
    }
    
    public var abbreviation: String {
        return "\(quality.abbreviation)\(number)"
    }
}
