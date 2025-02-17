// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SpaceKitABIGenerator",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "SpaceKitABIGenerator", targets: ["SpaceKitABIGenerator"])
    ],
    dependencies: [
        .package(path: "../app"),
        ##SPACEKIT_PACKAGE_DECLARATION##
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "SpaceKitABIGenerator",
            dependencies: [
                .product(name: "##TARGET_NAME##", package: "app"),
                .product(name: "SpaceKit", package: "SpaceKit")
            ]
        ),
    ]
)
