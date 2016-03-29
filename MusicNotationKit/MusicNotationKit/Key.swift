//
//  Key.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 7/11/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

public struct Key {
	
	private let type: KeyType
	private let noteLetter: NoteLetter
	private let accidental: Accidental?
	
	public init(noteLetter: NoteLetter, accidental: Accidental? = nil, type: KeyType = .Major) {
		self.noteLetter = noteLetter
		self.accidental = accidental
		self.type = type
	}
}

extension Key: CustomDebugStringConvertible {
	public var debugDescription: String {
		return "\(noteLetter) \(type)"
	}
}
