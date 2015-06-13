//
//  Measure.swift
//  MusicNotation
//
//  Created by Kyle Sherman on 6/12/15.
//  Copyright (c) 2015 Kyle Sherman. All rights reserved.
//

import Foundation

public struct Measure {
	
	private var index: Int
	private var currentRepeat: Int = 0
	private var repeatCount: Int = 0
	// TODO: If you want to repeat a set of them, set a beginning and ending to repeat, and give the
	// beginning the repeatCount you want. Then, add those to a container in the staff and repeat
	// until the count is done. This will be a special case unlike the repeat of a single measure.
	// Maybe have a RepeatController or Repeater class/struct. Maybe don't even have the repeat
	// stuff in the model like it is now.
	private var repeatMode: Repeat
	private var notes: [Note] = []
	private var isComplete: Bool
	private var timing: Timing
}
