// swift-tools-version:5.3
import Foundation
import PackageDescription

var package = Package(
	name: "swift-MusicNotationCore",
	exclude: ["docs"],
	products: [
		.library(name: "MusicNotationCoreMac", targets: ["MusicNotationCoreMac"]),
		.library(name: "MusicNotationCoreiOS", targets: ["MusicNotationCoreiOS"]),
		.library(name: "MusicNotationCoreTV", targets: ["MusicNotationCoreTV"]),
		.library(name: "MusicNotationCoreWatch", targets: ["MusicNotationCoreWatch"]),
	],
	targets: [
		.target(name: "MusicNotationCoreMac", dependencies: []),
		.testTarget(name: "MusicNotationCoreMacTests", dependencies: ["MusicNotationCoreMac"]),

		.target(name: "MusicNotationCoreiOS"),
		.target(name: "MusicNotationCoreTV"),
		.target(name: "MusicNotationCoreWatchOS"),
	],
	swiftLanguageVersions: [
		.v5
	]
)
