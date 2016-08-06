//
//  MeasureDurationValidator.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 8/6/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

public enum MeasureDurationValidator {

    public enum CompletionState {
        case notFull
        case full
        case overfilled
    }

    public static func completionState(of measure: ImmutableMeasure) -> CompletionState {
        // TODO: Implement
        return .notFull
    }

    public static func number(of noteDuration: NoteDuration, fittingIn: ImmutableMeasure) -> Int {
        // TODO: Implement
        return 0
    }

    public static func overflowingNotes(for measure: ImmutableMeasure) -> Range<Int>? {
        // TODO: Implement
        return nil
    }

    public static func availableNotes(for measure: ImmutableMeasure) -> [NoteDuration : Int] {
        // TODO: Implement
        return [:]
    }
}
