// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VolalySensors",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "VolalySensors", targets: ["VolalySensors"]),
    ],
    dependencies: [
        .package(url: "https://github.com/bgromov/TransformSwift", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "VolalySensors",
            dependencies: [.product(name: "Transform", package: "TransformSwift")]),
    ]
)
