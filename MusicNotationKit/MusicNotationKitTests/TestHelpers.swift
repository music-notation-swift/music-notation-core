//
//  TestHelpers.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 7/12/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

import XCTest

func assertNoErrorThrown<T>(_ expression: @autoclosure () throws -> T) {
    do {
        _ = try expression()
    } catch {
        XCTFail("Expected no error, but got: \(error)")
    }
}

func expected<T>(_ expected: T, actual: Error, functionName: String = #function, lineNum: Int = #line) {
    XCTFail("Expected: \(expected), Actual: \(actual) @ \(functionName): \(lineNum)")
}

func shouldFail(_ functionName: String = #function, lineNum: Int = #line) {
    XCTFail("Should have failed, but didn't @ \(functionName): \(lineNum)")
}
