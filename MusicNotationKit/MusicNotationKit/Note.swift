//
//  Note.swift
//  MusicNotation
//
//  Created by Kyle Sherman on 6/12/15.
//  Copyright (c) 2015 Kyle Sherman. All rights reserved.
//

public struct Note: NoteCollection {

    // NoteCollection
    public let noteCount = 1
    public let noteDuration: NoteDuration
    public let noteTimingCount = 1

    public let tones: [Tone]

    public let isRest: Bool

    public var accent: Accent?
    public var isStaccato: Bool = false
    public var dynamics: Dynamics?
    public var striking: Striking?

    internal var tie: Tie?

    /**
     Initialize a rest.
     */
    public init(noteDuration: NoteDuration) {
        self.noteDuration = noteDuration
        self.tones = []
        self.isRest = true
    }

    /**
     Initialize a note with a single tone.
     */
    public init(noteDuration: NoteDuration, tone: Tone) {
        self.noteDuration = noteDuration
        self.tones = [tone]
        self.isRest = false
    }

    /**
     Initialize a note with multiple tones (chord).
     */
    public init(noteDuration: NoteDuration, tones: [Tone]) {
        isRest = false
        self.noteDuration = noteDuration
        self.tones = tones
    }

    // MARK: - Methods
    // MARK: Public

    public func note(at index: Int) throws -> Note {
        guard index == 0 else {
            throw NoteError.invalidNoteIndex
        }
        return self
    }

    internal mutating func modifyTie(_ request: Tie) throws {
        // Nothing to do if it's the same value
        guard tie != request else { return }
        switch (tie, request) {
        case (.begin?, .end), (.end?, .begin):
            tie = .beginAndEnd
        case (nil, let value):
            tie = value
        default:
            throw NoteError.invalidRequestedTieState
        }
    }

    /**
     Remove the tie from the note.

     - parameter currentTie: What part of the tie on the note the caller wants to remove. This is important if the
     note is both the beginning and end of a tie
     - throws:
     - `NoteError.invalidRequestedTieState`
     */
    internal mutating func removeTie(_ currentTie: Tie) throws {
        switch (currentTie, tie) {
        case (.beginAndEnd, _):
            throw NoteError.invalidRequestedTieState
        case (_, nil):
            return
        case (let request, let current?) where request == current:
            tie = nil
        case (.begin, .beginAndEnd?):
            tie = .end
        case (.end, .beginAndEnd?):
            tie = .begin
        default:
            throw NoteError.invalidRequestedTieState
        }
    }
}

extension Note: Equatable {
    public static func ==(lhs: Note, rhs: Note) -> Bool {
        if lhs.noteDuration == rhs.noteDuration &&
            lhs.tones == rhs.tones &&
            lhs.isRest == rhs.isRest &&
            lhs.accent == rhs.accent &&
            lhs.isStaccato == rhs.isStaccato &&
            lhs.dynamics == rhs.dynamics &&
            lhs.striking == rhs.striking &&
            lhs.tie == rhs.tie {
            return true
        } else {
            return false
        }
    }
}

extension Note: CustomDebugStringConvertible {
    public var debugDescription: String {
        let tonesString: String
        if tones.count > 1 {
            tonesString = "\(tones)"
        } else {
            if let tone = tones.first {
                tonesString = "\(tone)"
            } else {
                tonesString = ""
            }
        }
        return "\(tie == .end || tie == .beginAndEnd ? "_" : "")\(noteDuration)\(tonesString)\(isRest ? "R" : "")\(tie == .begin || tie == .beginAndEnd ? "_" : "")"
    }
}

public enum NoteError: Error {
    case invalidRequestedTieState
    case invalidNoteIndex
}
