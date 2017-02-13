//
//  ImmutableMeasure.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 3/6/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

public protocol ImmutableMeasure: NotesHolder {

    var timeSignature: TimeSignature { get }
    var key: Key { get }
    var notes: [[NoteCollection]] { get }
    var noteCount: [Int] { get }

    init(timeSignature: TimeSignature, key: Key)
    init(timeSignature: TimeSignature, key: Key, notes: [[NoteCollection]])
}

public func ==<T: ImmutableMeasure>(lhs: T, rhs: T) -> Bool {
    guard lhs.timeSignature == rhs.timeSignature &&
        lhs.key == rhs.key &&
        lhs.notes.count == rhs.notes.count else {
            return false
    }
    for i in 0..<lhs.notes.count {
        guard lhs.notes[i].count == rhs.notes[i].count else {
            return false
        }
        for j in 0..<lhs.notes[i].count {
            if lhs.notes[i][j] == rhs.notes[i][j] {
                continue
            } else {
                return false
            }
        }
    }
    return true
}
