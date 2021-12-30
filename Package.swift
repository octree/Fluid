// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Fluid",
    platforms: [
        .macCatalyst(.v14),
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "Fluid",
            targets: ["Fluid"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Fluid",
            dependencies: []),
        .testTarget(
            name: "FluidTests",
            dependencies: ["Fluid"]),
    ])
