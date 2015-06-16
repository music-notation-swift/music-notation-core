//
//  Timing.swift
//  MusicNotation
//
//  Created by Kyle Sherman on 6/12/15.
//  Copyright (c) 2015 Kyle Sherman. All rights reserved.
//

import Foundation

public struct Timing {
	
	public let topNumber: Int
	public let bottomNumber: Int
	public let tempo: Int
	
	init(topNumber: Int, bottomNumber: Int, tempo: Int) {
		// TODO: Check the validity of all these values
		self.topNumber = topNumber
		self.bottomNumber = bottomNumber
		self.tempo = tempo
	}
}
