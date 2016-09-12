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
        var setIndex = 0
        return measure.notes.map { noteCollection in
            defer {
                setIndex += 1
            }
            var overFilledStartIndex: Int?
            var index: Int = 0
            let filledTicks = noteCollection.reduce(0) { prev, currentCollection in
                let newTicks = prev + currentCollection.noteTimingCount * currentCollection.noteDuration.ticks
                if newTicks > fullMeasureTicksBudget && overFilledStartIndex == nil {
                    overFilledStartIndex = index
                }
                index += 1
                return newTicks
            }
            if filledTicks == fullMeasureTicksBudget {
                return .full
            } else if let overFilledStartIndex = overFilledStartIndex {
                return .overfilled(
                overflowingNotes: Range(
                    uncheckedBounds: (overFilledStartIndex, measure.noteCount[setIndex])
                ))
            } else if filledTicks < fullMeasureTicksBudget {
                return .notFull(availableNotes: availableNotes(within: fullMeasureTicksBudget - filledTicks))
            } else {
                return .invalid
            }
        }
    }

    private static func availableNotes(within ticks: Int) -> [NoteDuration: Int] {
        var ticksLeft = ticks
        var availableNotes: [NoteDuration: Int] = [:]
        while ticksLeft != 0 {
            let duration = findLargestDuration(lessThan: ticksLeft)
            let noteCount = ticksLeft / duration.ticks
            availableNotes[duration] = noteCount
            ticksLeft -= noteCount * duration.ticks
        }
        return availableNotes
    }

    private static func findLargestDuration(lessThan ticks: Int) -> NoteDuration {
        let allDurations: [NoteDuration] = [.large, .long, .doubleWhole, .whole, .half, .quarter, .eighth, .sixteenth,
                                            .thirtySecond, .sixtyFourth, .oneTwentyEighth, .twoFiftySixth]
        let allTicks = allDurations.map { $0.ticks }
        func findLargest(start: Int, end: Int) -> NoteDuration {
            guard end - start > 1 else {
                return allDurations[end]
            }
            let mid = (start + end) / 2
            if allTicks[mid] < ticks {
                return findLargest(start: start, end: mid)
            } else if allTicks[mid] > ticks {
                return findLargest(start: mid, end: end)
            } else {
                return allDurations[mid]
            }
        }
        return findLargest(start: 0, end: allTicks.count - 1)
    }

    public static func number(of noteDuration: NoteDuration, fittingIn measure: ImmutableMeasure) -> Int {
        let baseDuration: NoteDuration
        do {
            baseDuration = try baseNoteDuration(from: measure)
        } catch {
            // TODO: Write TimeSignature validation, so this isn't possible
            return 0
        }
        
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
