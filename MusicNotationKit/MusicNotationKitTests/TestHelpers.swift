//
//  TestHelpers.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 7/12/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

import XCTest

func expected<T>(expected: T, actual: ErrorType) {
	XCTFail("Expected: \(expected), Actual: \(actual)")
}

func shouldFail() {
	XCTFail("Should have failed, but didn't")
}
