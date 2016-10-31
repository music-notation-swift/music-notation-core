//
//  StaffLocation.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 10/30/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

/**
 Represents a 0-based location on the staff where 0 is the first line/space from the bottom.
 Negative numbers represents ledger lines/spaces below the first line/space of the staff.
 */
public struct StaffLocation {

    public enum LocationType {
        case line
        case space
    }

    public let locationType: LocationType
    /**
     0-based location on the staff where 0 is the first line/space from the bottom.
     Negative numbers represent ledger lines/spaces below the first one.
     */
    public let number: Int

    public init(type: LocationType, number: Int) {
        locationType = type
        self.number = number
    }
}
