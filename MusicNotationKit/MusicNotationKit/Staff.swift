//
//  Staff.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 6/15/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

public struct Staff {
	
	public let clef: Clef
	public let instrument: Instrument
	
	private(set) var measures: [NotesHolder]
}
