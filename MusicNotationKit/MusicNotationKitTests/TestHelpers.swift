//
//  TestHelpers.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 7/12/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

import XCTest

extension XCTestCase {

    func assertThrowsError<T: Error>(_ expectedError: T, inFile file: String = #file, atLine line: UInt = #line,
                           expression: () throws -> ()) where T: Equatable {
        do {
            try expression()
            recordFailure(withDescription: "Expected error \(expectedError), but got no error.",
                inFile: file,
                atLine: line,
                expected: false)
        } catch {
            if error as? T != expectedError {
                recordFailure(withDescription: "Expected error \(expectedError), but got: \(error).",
                    inFile: file,
                    atLine: line,
                    expected: false)
            }
        }
    }

    func assertNoErrorThrown(inFile file: String = #file, atLine line: UInt = #line, expression: () throws -> ()) {
        do {
            try expression()
        } catch {
            recordFailure(withDescription: "Expected no error, but got: \(error)", inFile: file, atLine: line, expected: false)
        }
    }
}
