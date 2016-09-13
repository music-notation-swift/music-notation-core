//
//  TestHelpers.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 7/12/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

import XCTest

func assertThrowsError<T: Error>(_ expectedError: T, expression: () throws -> ()) where T: Equatable {
    XCTAssertThrowsError(try expression()) { error in
        XCTAssertEqual(error as? T, expectedError, "Expected error \(expectedError), but got: \(error).")
    }
}

func assertNoErrorThrown(expression: () throws -> ()) {
    do {
        try expression()
    } catch {
        XCTFail("Expected no error, but got: \(error)")
    }
}

