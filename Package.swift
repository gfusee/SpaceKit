// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let isWasm = Context.environment["SWIFT_WASM"]?.lowercased() == "true"

let unsafeFlags = isWasm ? [
    "-gnone",
    "-Osize",
    "-enable-experimental-feature",
    "Extern",
    "-enable-experimental-feature",
    "Embedded",
    "-Xcc",
    "-fdeclspec",
    "-Xcc",
    "-fno-stack-protector",
    "-Xcc",
    "-fno-stack-check",
    "-whole-module-optimization",
    "-D",
    "WASM"
] : []

var packageDependencies: [Package.Dependency] = [
    .package(url: "https://github.com/apple/swift-syntax", from: "510.0.1")
]

var libraryDependencies: [Target.Dependency] = [
    "ContractMacro"
]

var testTargets: [Target] = []

if !isWasm {
    packageDependencies.append(contentsOf: [
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0")
    ])
    
    libraryDependencies.append(contentsOf: [
        .product(name: "BigInt", package: "BigInt")
    ])
    
    testTargets.append(contentsOf: [
        .testTarget(
            name: "BufferTests",
            dependencies: [
                "MultiversX"
            ]
        ),
        .testTarget(
            name: "BigUintTests",
            dependencies: [
                "MultiversX"
            ]
        ),
        .testTarget(
            name: "ContractStorageTests",
            dependencies: [
                "MultiversX"
            ]
        ),
        .testTarget(
            name: "TestEngineTests",
            dependencies: [
                "MultiversX"
            ]
        ),
        .testTarget(
            name: "ContractMacroTests",
            dependencies: [
                "ContractMacro",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]
        )
    ])
}

let package = Package(
    name: "swift-mvx-contract",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "swift-mvx-contract", targets: ["swift-mvx-contract"])
    ],
    dependencies: packageDependencies,
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "swift-mvx-contract",
            dependencies: [
                "MultiversX"
            ],
            swiftSettings: [
                .unsafeFlags(unsafeFlags)
            ]
        ),
        .target(
            name: "MultiversX",
            dependencies: libraryDependencies,
            swiftSettings: [
                .unsafeFlags(unsafeFlags)
            ]
        ),
        .macro(
            name: "ContractMacro",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        )
    ] + testTargets
)
