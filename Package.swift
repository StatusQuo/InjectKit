// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InjectKit",
    products: [
        .library(
            name: "InjectKit",
            targets: ["InjectKit"]),
    ],
    targets: [
        .target(
            name: "InjectKit",
            dependencies: []),
        .testTarget(
            name: "InjectKitTests",
            dependencies: ["InjectKit"]),
    ]
)
