//
//  MeasureDurationValidator.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 8/6/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

public enum MeasureDurationValidator {

    public enum CompletionState: Equatable {
        case notFull(availableNotes: [NoteDuration : Int])
        case full
        case overfilled(overflowingNotes: Range<Int>)
        case invalid

        public static func ==(lhs: CompletionState, rhs: CompletionState) -> Bool {
            switch (lhs, rhs) {
            case (.full, .full):
                return true
            case (.notFull(let lhsValue), .notFull(let rhsValue)) where lhsValue == rhsValue:
                return true
            case (.overfilled(let lhsValue), .overfilled(let rhsValue)) where lhsValue == rhsValue:
                return true
            case (.invalid, .invalid):
                return true
            default:
                return false
            }
        }
    }

    /**
     For the given measure, returns an array of `CompletionState` for each set in the measure in order.
     */
    public static func completionState(of measure: ImmutableMeasure) -> [CompletionState] {
        let baseDuration: NoteDuration
        do {
            baseDuration = try baseNoteDuration(from: measure)
        } catch {
            return [.invalid]
        }
        let fullMeasureTicksBudget = measure.timeSignature.topNumber * baseDuration.ticks
        // Validate each set separately
        return measure.notes.map { noteCollection in
            let filledTicks = noteCollection.reduce(0) { prev, currentCollection in
                return prev + currentCollection.noteTimingCount * currentCollection.noteDuration.ticks
            }
            switch filledTicks {
            case fullMeasureTicksBudget:
                return .full
            // TODO: Add other cases
            default:
                return .invalid
            }
        }
    }

    public static func number(of noteDuration: NoteDuration, fittingIn: ImmutableMeasure) -> Int {
        // TODO: Implement
        return 0
    }

    internal static func baseNoteDuration(from measure: ImmutableMeasure) throws -> NoteDuration {
        let bottomNumber = measure.timeSignature.bottomNumber
        let rationalizedBottomNumber = Int(pow(2, floor(log(Double(bottomNumber)) / log(2))))

        // TODO: (Kyle) We should validate in TimeSignature to make sure the number
        // isn't too large. Then I guess we can make this a force unwrap, because the math above 
        // means it will always be a power of 2 and NoteDuration is always power of 2.
        if let timeSignatureValue = NoteDuration.TimeSignatureValue(rawValue: rationalizedBottomNumber) {
            return NoteDuration(timeSignatureValue: timeSignatureValue)
        } else {
            throw MeasureDurationValidatorError.invalidBottomNumber
        }
    }
}

public enum MeasureDurationValidatorError: Error {
    case invalidBottomNumber
    case internalError
}
