//
//  Tempo.swift
//  MusicNotationCore
//
//  Created by Steven Woolgar on 07/18/2024.
//  Copyright © 2024 Steven Woolgar. All rights reserved.
//

/// Represents the tempo of the section at the point of attachment.
///
/// In musical terminology, tempo (Italian for 'time'; plural 'tempos', or tempi from the Italian plural),
/// also known as beats per minute, is the speed or pace of a given composition. In classical music,
/// tempo is typically indicated with an instruction at the start of a piece (often using conventional
/// Italian terms) and is usually measured in beats per minute (BPM). In modern classical compositions,
/// a "metronome mark" in beats per minute may supplement or replace the normal tempo marking, while in
/// modern genres like electronic dance music, tempo will typically simply be stated in BPM.
///
public struct Tempo: Sendable {
    public enum TempoType {
        case pause
        case fixed
        case ramp
    }

    public let value: Double
    public let text: String?

    public init(_ tempoValue: Double, text: String? = nil) {
        self.value = tempoValue
        self.text = text
    }
}

extension Tempo: Equatable {
	public static func == (lhs: Tempo, rhs: Tempo) -> Bool {
		guard lhs.value == rhs.value, lhs.text == rhs.text else { return false }
        return true
	}
}

extension Tempo: CustomDebugStringConvertible {
	public var debugDescription: String {
		"\(value) \"(text)\")"
	}
}
