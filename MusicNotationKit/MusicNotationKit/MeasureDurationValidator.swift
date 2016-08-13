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

        public static func ==(lhs: CompletionState, rhs: CompletionState) -> Bool {
            switch (lhs, rhs) {
            case (.full, .full):
                return true
            case (.notFull(let lhsValue), .notFull(let rhsValue)) where lhsValue == rhsValue:
                return true
            case (.overfilled(let lhsValue), .overfilled(let rhsValue)) where lhsValue == rhsValue:
                return true
            default:
                return false
            }
        }
    }

    public static func completionState(of measure: ImmutableMeasure) -> CompletionState {
        // TODO: Implement
        return .full
    }

    public static func number(of noteDuration: NoteDuration, fittingIn: ImmutableMeasure) -> Int {
        // TODO: Implement
        return 0
    }
}
