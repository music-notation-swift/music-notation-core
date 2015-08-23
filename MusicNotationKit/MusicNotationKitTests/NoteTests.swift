//
//  NoteTests.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 6/15/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

import XCTest
@testable import MusicNotationKit

class NoteTests: XCTestCase {

	var note = Note(noteDuration: .Eighth, tone: Tone(noteLetter: .C, octave: .Octave1))
	
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func testModifyTie() {
		XCTAssert(note.tie == nil)
		// Success
		do {
			try note.modifyTie(.Begin)
			XCTAssert(note.tie == .Begin)
			note.tie = nil
			try note.modifyTie(.End)
			XCTAssert(note.tie == .End)
			note.tie = nil
			try note.modifyTie(.BeginAndEnd)
			XCTAssert(note.tie == .BeginAndEnd)
			note.tie = .Begin
			try note.modifyTie(.End)
			XCTAssert(note.tie == .BeginAndEnd)
			note.tie = .End
			try note.modifyTie(.Begin)
			XCTAssert(note.tie == .BeginAndEnd)
			note.tie = .Begin
			try note.modifyTie(.Begin)
			XCTAssert(note.tie == .Begin)
			note.tie = .End
			try note.modifyTie(.End)
			XCTAssert(note.tie == .End)
			note.tie = .BeginAndEnd
			try note.modifyTie(.BeginAndEnd)
			XCTAssert(note.tie == .BeginAndEnd)
		} catch {
			XCTFail()
		}
		
		// Failure
		note.tie = .BeginAndEnd
		do {
			try note.modifyTie(.Begin)
			shouldFail()
		} catch NoteError.InvalidTieState {
		} catch {
			expected(NoteError.InvalidTieState, actual: error)
		}
		
		XCTAssert(note.tie == .BeginAndEnd)
		do {
			try note.modifyTie(.End)
			shouldFail()
		} catch NoteError.InvalidTieState {
		} catch {
			expected(NoteError.InvalidTieState, actual: error)
		}
	}
}
