//
//  Note.swift
//  MusicNotation
//
//  Created by Kyle Sherman on 6/12/15.
//  Copyright (c) 2015 Kyle Sherman. All rights reserved.
//

public struct Note {
	
	public let noteDuration: NoteDuration
	public let tone: Tone
	
	public var isRest: Bool
	
	public var dot: Dot = .None
	public var accent: Accent = .None
	public var isStaccato: Bool = false
	public var dynamics: Dynamics = .None
	public var striking: Striking = .None
}
