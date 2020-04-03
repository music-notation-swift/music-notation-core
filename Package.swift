// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "MusicNotationCore",
    targets: [
        .target(name: "MusicNotationCore"),
        .testTarget(
            name: "MusicNotationCoreTests",
            dependencies: ["MusicNotationCore"])
    ]
)
