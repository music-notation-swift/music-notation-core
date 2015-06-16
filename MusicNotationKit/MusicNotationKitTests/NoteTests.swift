//
//  NoteTests.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 6/15/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

import XCTest
import MusicNotationKit

class NoteTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInit() {
        // Make a rest; should always succeed
		do {
			let _ = try Note(isRest: true, noteDuration: .Whole)
			let _ = try Note(isRest: true, noteDuration: .Whole,
				tone: Tone(accidental: .None, noteLetter: .A))
		} catch {
			XCTFail("Failed to make rest.")
		}
		
		// Make a note. Should fail if no tone was provided
		let wrongError: Void -> Void = {
			XCTFail("Wrong error thrown.")
		}
		do {
			let _ = try Note(isRest: false, noteDuration: .Whole)
		} catch NoteError.NoToneSpecified {

		} catch {
			wrongError()
		}
		
		do {
			let _ = try Note(isRest: false, noteDuration: .Whole, tone: nil)
		} catch NoteError.NoToneSpecified {
			
		} catch {
			wrongError()
		}
		
		// Success
		do {
			let _ = try Note(isRest: false, noteDuration: .Whole,
				tone: Tone(accidental: .None, noteLetter: .A))
		} catch {
			XCTFail("Valid init of Note failed")
		}
    }
}
