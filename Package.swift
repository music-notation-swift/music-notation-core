// swift-tools-version:6.0
//
//  Package.swift
//  MusicNotationCore
//
//  Created by Steven Woolgar on 10/16/2020.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

import Foundation
import PackageDescription

var package = Package(
	name: "MusicNotationCore",
	products: [
		.library(name: "MusicNotationCore", targets: ["MusicNotationCore"]),
	],

    targets: [
		.target(name: "MusicNotationCore", path: "Sources"),

        .testTarget(name: "MusicNotationCoreTests", dependencies: ["MusicNotationCore"]),
	],

    swiftLanguageVersions: [ .v6 ]
)
