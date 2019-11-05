//
//  Decimal+Extension.swift
//  MusicNotationCore
//
//  Created by Bartłomiej Świerad on 05/11/2019.
//

import Foundation

extension Decimal {
    var intValue: Int {
        (self as NSNumber).intValue
    }
}
