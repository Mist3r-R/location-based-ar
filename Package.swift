// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LBAR",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "LBAR",
            targets: ["LocationBasedAR"]),
    ],
    targets: [
        .target(
            name: "LocationBasedAR",
            dependencies: []),
    ]
)
