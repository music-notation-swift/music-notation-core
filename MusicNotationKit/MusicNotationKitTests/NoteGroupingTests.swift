//
//  NoteGroupingTests.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 6/19/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

import XCTest
@testable import MusicNotationKit

class NoteGroupingTests: XCTestCase {

	let tone1 = Tone(accidental: .None, noteLetter: .A)
	let tone2 = Tone(accidental: .Sharp, noteLetter: .B)
	let tone3 = Tone(accidental: .Natural, noteLetter: .D)
	let quarterRest = Note(noteDuration: .Quarter)
	let eighthRest = Note(noteDuration: .Eighth)
	var quarterNote1: Note!
	var quarterNote2: Note!
	var quarterNote3: Note!
	var eighthNote: Note!
	var quarterChord: Note!
	var eighthChord: Note!
	
    override func setUp() {
        super.setUp()
		quarterNote1 = Note(noteDuration: .Quarter, tone: tone1)
		quarterNote2 = Note(noteDuration: .Quarter, tone: tone1)
		quarterNote3 = Note(noteDuration: .Quarter, tone: tone2)
		eighthNote = Note(noteDuration: .Eighth, tone: tone1)
		quarterChord = Note(noteDuration: .Quarter, tones: [tone1, tone2, tone3])
		eighthChord = Note(noteDuration: .Eighth, tones: [tone1, tone2, tone3])
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	// MARK: - Tests
	
	func testInitFailures() {
		// Has a rest
		do {
			let _ = try NoteGrouping(notes: [quarterNote1, quarterRest])
			shouldFail()
		} catch NoteGroupingError.RestsNotValid {
		} catch {
			expected(NoteGroupingError.RestsNotValid, actual: error)
		}
		
		// Too many notes
		do {
			let _ = try NoteGrouping(notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2])
			shouldFail()
		} catch NoteGroupingError.InvalidNumberOfNotes {
		} catch {
			expected(NoteGroupingError.InvalidNumberOfNotes, actual: error)
		}
		
		// Too few notes (1)
		do {
			let _ = try NoteGrouping(notes: [quarterNote1])
			shouldFail()
		} catch NoteGroupingError.InvalidNumberOfNotes {
		} catch {
			expected(NoteGroupingError.InvalidNumberOfNotes, actual: error)
		}
		
		// Too few notes (0)
		do {
			let _ = try NoteGrouping(notes: [])
			shouldFail()
		} catch NoteGroupingError.InvalidNumberOfNotes {
		} catch {
			expected(NoteGroupingError.InvalidNumberOfNotes, actual: error)
		}
		
		// Non-uniform duration
		do {
			let _ = try NoteGrouping(notes: [quarterNote1, quarterNote2, quarterNote3, eighthNote])
			shouldFail()
		} catch NoteGroupingError.NotSameDuration {
		} catch {
			expected(NoteGroupingError.NotSameDuration, actual: error)
		}
	}
	
	func testInitSuccess() {
		do {
			// Test 2 - 7
			let _ = try NoteGrouping(notes: [quarterNote1, quarterNote2])
			let _ = try NoteGrouping(notes: [quarterNote1, quarterNote2, quarterNote3])
			let _ = try NoteGrouping(notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1])
			let _ = try NoteGrouping(notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2])
			let _ = try NoteGrouping(notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3])
			let _ = try NoteGrouping(notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3, quarterNote1])
			// Test with a chord
			let _ = try NoteGrouping(notes: [quarterNote1, quarterChord])
		} catch {
			XCTFail("\(error)")
		}
	}
	
	func testAppendNoteFailures() {
		// Full
		do {
			var noteGroup = try NoteGrouping(notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3, quarterNote1])
			try noteGroup.appendNote(quarterNote3)
			shouldFail()
		} catch NoteGroupingError.GroupingFull {
		} catch {
			expected(NoteGroupingError.GroupingFull, actual: error)
		}
		
		// Rest
		do {
			var noteGroup = try NoteGrouping(notes: [quarterNote1, quarterNote2])
			try noteGroup.appendNote(quarterRest)
			shouldFail()
		} catch NoteGroupingError.RestsNotValid {
		} catch {
			expected(NoteGroupingError.RestsNotValid, actual: error)
		}
		
		// Invalid duration
		do {
			var noteGroup = try NoteGrouping(notes: [quarterNote1, quarterNote2])
			try noteGroup.appendNote(eighthNote)
			shouldFail()
		} catch NoteGroupingError.NotSameDuration {
		} catch {
			expected(NoteGroupingError.NotSameDuration, actual: error)
		}
	}
	
	func testAppendNoteSuccess() {
		do {
			// Test 2 - 7
			var group2 = try NoteGrouping(notes: [quarterNote1, quarterNote2])
			try group2.appendNote(quarterNote1)
			var group3 = try NoteGrouping(notes: [quarterNote1, quarterNote2, quarterNote3])
			try group3.appendNote(quarterNote1)
			var group4 = try NoteGrouping(notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1])
			try group4.appendNote(quarterNote1)
			var group5 = try NoteGrouping(notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2])
			try group5.appendNote(quarterNote1)
			var group6 = try NoteGrouping(notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3])
			try group6.appendNote(quarterNote1)
			// Test with a chord
			var group7 = try NoteGrouping(notes: [quarterNote1, quarterChord])
			try group7.appendNote(quarterNote1)
			// Test appending chord
			try group2.appendNote(quarterChord)
		} catch {
			XCTFail("\(error)")
		}
	}
	
	// MARK: - Helpers
	
	private func expected(expected: NoteGroupingError, actual: ErrorType) {
		XCTFail("Expected: \(expected), Actual: \(actual)")
	}
	
	private func shouldFail() {
		XCTFail("Should have failed, but didn't")
	}
}
