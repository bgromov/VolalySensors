// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VolalySensorsSwift",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "VolalySensorsSwift", targets: ["VolalySensorsSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/bgromov/TransformSwift", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "VolalySensorsSwift",
            dependencies: [.product(name: "Transform", package: "TransformSwift")]),
    ]
)
