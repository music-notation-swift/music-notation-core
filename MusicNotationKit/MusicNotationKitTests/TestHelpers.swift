//
//  TestHelpers.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 7/12/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

import XCTest

func expected<T>(expected: T, actual: ErrorType, functionName: String = __FUNCTION__, lineNum: Int = __LINE__) {
	XCTFail("Expected: \(expected), Actual: \(actual) @ \(functionName): \(lineNum)")
}

func shouldFail(functionName: String = __FUNCTION__, lineNum: Int = __LINE__) {
	XCTFail("Should have failed, but didn't @ \(functionName): \(lineNum)")
}
