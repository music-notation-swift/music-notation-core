//
//  MeasureDurationValidator.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 8/6/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

public enum MeasureDurationValidator {

    internal static let ticksPerBaseNote = 1024

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

    public static func completionState(of measure: ImmutableMeasure) -> CompletionState {
        let fullMeasureTicksBudget = measure.timeSignature.topNumber * ticksPerBaseNote
        let baseDuration: NoteDuration
        do {
            baseDuration = try baseNoteDuration(from: measure)
        } catch {
            return .invalid
        }
        var filledTicks: Double = 0
        for noteCollection in measure.notes {
            if let note = noteCollection as? Note {
                filledTicks += Double(ticks(for: note.noteDuration, baseDuration: baseDuration))
                filledTicks += Double(ticksFromDot(for: note, baseDuration: baseDuration))
            } else if let tuplet = noteCollection as? Tuplet {

            } else {
                assertionFailure("NoteCollection was note a known type (tuplet or note)")
                return .invalid
            }
        }
        switch filledTicks {
        case Double(fullMeasureTicksBudget):
            return .full
        default:
            return .invalid
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
        if let noteDuration = NoteDuration(rawValue: rationalizedBottomNumber) {
            return noteDuration
        } else {
            throw MeasureDurationValidatorError.invalidBottomNumber
        }
    }

    internal static func ticks(for duration: NoteDuration, baseDuration: NoteDuration) -> Int {
        let basePower = log(Double(baseDuration.rawValue)) / log(2)
        let durationPower = log(Double(duration.rawValue)) / log(2)
        let difference = durationPower - basePower
        let factor = pow(2, abs(difference))
        if difference < 0 {
            return ticksPerBaseNote * Int(factor)
        } else {
            return ticksPerBaseNote / Int(factor)
        }
    }

    internal static func ticksFromDot(for note: Note, baseDuration: NoteDuration) -> Int {
        let ticksForDuration = ticks(for: note.noteDuration, baseDuration: baseDuration)
        switch note.dot {
        case nil:
            return 0
        case .single?:
            return ticksForDuration / 2
        case .double?:
            return ticksForDuration / 2 + ticksForDuration / 4
        }
    }
}

public enum MeasureDurationValidatorError: Error {
    case invalidBottomNumber
    case internalError
}
