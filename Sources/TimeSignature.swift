//
//  TimeSignature.swift
//  MusicNotation
//
//  Created by Kyle Sherman on 06/12/2015.
//  Copyright (c) 2015 Kyle Sherman. All rights reserved.
//

/// A structure that describes a music notation time signature.
///
/// A time signature (also known as meter signature,[1] metre signature,[2] and measure signature)[3]
/// is a convention in Western music notation that specifies how many note values of a particular type
/// are contained in each measure (bar). The time signature indicates the meter of a musical movement
/// at the bar level.
///
/// In a music score the time signature appears as two stacked numerals, such as 4/4 (spoken as four–four time),
/// or a time symbol, such as common time (spoken as common time). It immediately follows the key signature
/// (or if there is no key signature, the clef symbol). A mid-score time signature, usually immediately
/// following a barline, indicates a change of meter.
///
/// Most time signatures are either simple (the note values are grouped in pairs, like 2/4, 3/4, and 4/4),
/// or compound (grouped in threes, like 6/8, 9/8, and 12/8). Less common signatures indicate complex,
/// mixed, additive, and irrational meters.
///
public struct TimeSignature: Sendable {
	public let numerator: Int
	public let denominator: Int
	public let tempo: Int

	public init(numerator: Int, denominator: Int, tempo: Int) {
		// TODO: Check the validity of all these values
		self.numerator = numerator
		self.denominator = denominator
		self.tempo = tempo
	}
}

extension TimeSignature: CustomDebugStringConvertible {
	public var debugDescription: String {
		"\(numerator)/\(denominator)"
	}
}

extension TimeSignature: Equatable {
	public static func == (lhs: TimeSignature, rhs: TimeSignature) -> Bool {
		if lhs.numerator == rhs.numerator,
			lhs.denominator == rhs.denominator,
			lhs.tempo == rhs.tempo {
			return true
		} else {
			return false
		}
	}
}
