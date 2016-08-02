//
//  RepeatedMeasure.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 3/9/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

/**
 This represents a measure that is part of a repeat. This is not one of the original measures that
 will be repeated. This represents a measure that is a repeat of one of the original measures to
 be repeated.
 
 i.e. If we want to repeat measure A 2 times, you would have

    | A, repeated A, repeated A |

 This structure represents those repeated measures "repeated A", so that they can be differentiated from the
 original measure "A".
 
 - Note: Look at `MeasureRepeat.expand()` to see how this is used.
 */
public struct RepeatedMeasure: ImmutableMeasure {

    public let timeSignature: TimeSignature
    public let key: Key
    public private(set) var notes: [NoteCollection]
    public let measureCount: Int = 1
    public let noteCount: Int

    public init(timeSignature: TimeSignature, key: Key) {
        self.init(timeSignature: timeSignature, key: key, notes: [])
    }

    public init(timeSignature: TimeSignature, key: Key, notes: [NoteCollection]) {
        self.timeSignature = timeSignature
        self.key = key
        self.notes = notes
        noteCount = notes.reduce(0) { prev, noteCollection in
            return prev + noteCollection.noteCount
        }
    }

    internal init(immutableMeasure: ImmutableMeasure) {
        self.init(timeSignature: immutableMeasure.timeSignature, key: immutableMeasure.key,
                  notes: immutableMeasure.notes)
    }
}

extension RepeatedMeasure: Equatable {
    static public func ==(lhs: RepeatedMeasure, rhs: RepeatedMeasure) -> Bool {
        guard lhs.timeSignature == rhs.timeSignature &&
            lhs.key == rhs.key &&
            lhs.notes.count == rhs.notes.count else {
                return false
        }
        for i in 0..<lhs.notes.count {
            if lhs.notes[i] == rhs.notes[i] {
                continue
            } else {
                return false
            }
        }
        return true
    }
}
