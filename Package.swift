// swift-tools-version:5.3
import Foundation
import PackageDescription

var package = Package(
	name: "MusicNotationCore",
	products: [
		.library(name: "MusicNotationCoreMac", targets: ["MusicNotationCoreMac"]),
		.library(name: "MusicNotationCoreiOS", targets: ["MusicNotationCoreiOS"]),
		.library(name: "MusicNotationCoreTV", targets: ["MusicNotationCoreTV"]),
	],
	targets: [
		.target(name: "MusicNotationCoreMac", path: "MusicNotationCore"),
		.testTarget(name: "MusicNotationCoreMacTests", dependencies: ["MusicNotationCoreMac"]),
		.target(name: "MusicNotationCoreiOS", path: "MusicNotationCore"),
		.target(name: "MusicNotationCoreTV", path: "MusicNotationCore"),
	],
	swiftLanguageVersions: [
		.v5
	]
)
