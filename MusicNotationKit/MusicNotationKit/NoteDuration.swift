//
//  NoteDuration.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 8/20/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

public struct NoteDuration {

    public enum Value: CustomDebugStringConvertible {
        case large
        case long
        case doubleWhole
        case whole
        case half
        case quarter
        case eighth
        case sixteenth
        case thirtySecond
        case sixtyFourth
        case oneTwentyEighth
        case twoFiftySixth

        public var debugDescription: String {
            switch self {
            case .large: return "8"
            case .long: return "4"
            case .doubleWhole: return "2"
            case .whole: return "1"
            case .half: return "1/2"
            case .quarter: return "1/4"
            case .eighth: return "1/8"
            case .sixteenth: return "1/16"
            case .thirtySecond: return "1/32"
            case .sixtyFourth: return "1/64"
            case .oneTwentyEighth: return "1/128"
            case .twoFiftySixth: return "1/256"
            }
        }
    }

    public let value: Value
    public let dotCount: Int
    public var timeSignatureValue: Int? {
        switch value {
        case .whole: return 1
        case .half: return 2
        case .quarter: return 4
        case .eighth: return 8
        case .sixteenth: return 16
        case .thirtySecond: return 32
        case .sixtyFourth: return 64
        case .oneTwentyEighth: return 128
        case .twoFiftySixth: return 256
        case .long, .large, .doubleWhole: return nil
        }
    }

    private init(value: Value) {
        self.value = value
        self.dotCount = 0
    }

    public init(value: Value, dotCount: Int) throws {
        guard dotCount >= 0 else {
            throw NoteDurationError.negativeDotCountInvalid
        }
        self.value = value
        self.dotCount = dotCount
    }

    public static let large = NoteDuration(value: .large)
    public static let long = NoteDuration(value: .long)
    public static let doubleWhole = NoteDuration(value: .doubleWhole)
    public static let whole = NoteDuration(value: .whole)
    public static let half = NoteDuration(value: .half)
    public static let quarter = NoteDuration(value: .quarter)
    public static let eighth = NoteDuration(value: .eighth)
    public static let sixteenth = NoteDuration(value: .sixteenth)
    public static let thirtySecond = NoteDuration(value: .thirtySecond)
    public static let sixtyFourth = NoteDuration(value: .sixtyFourth)
    public static let oneTwentyEighth = NoteDuration(value: .oneTwentyEighth)
    public static let twoFiftySixth = NoteDuration(value: .twoFiftySixth)
}

extension NoteDuration: Hashable {
    public var hashValue: Int {
        let valueAsHash: Int
        if let timeSignatureValue = timeSignatureValue {
            valueAsHash = timeSignatureValue
        } else {
            switch value {
            case .doubleWhole: valueAsHash = -2
            case .long: valueAsHash = -4
            case .large: valueAsHash = -8
            default:
                assertionFailure("Should have been covered already")
                valueAsHash = 0
            }
        }
        return valueAsHash ^ dotCount
    }
}

extension NoteDuration: Equatable {
    public static func ==(lhs: NoteDuration, rhs: NoteDuration) -> Bool {
        return lhs.value == rhs.value && lhs.dotCount == rhs.dotCount
    }
}

extension NoteDuration: CustomDebugStringConvertible {
    public var debugDescription: String {
        let dots = String(repeating: ".", count: dotCount)
        return "\(value.debugDescription)\(dots)"
    }
}

public enum NoteDurationError: Error {
    case negativeDotCountInvalid
}
