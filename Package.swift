// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iOS-Persistence",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "CDPersistence",
            targets: ["CDPersistence"]),
    ],
    dependencies: [

    ],
    targets: [
        .target(
            name: "CDPersistence",
            dependencies: []),
    ]
)
