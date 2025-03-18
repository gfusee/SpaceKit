// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let isWasm = Context.environment["SWIFT_WASM"]?.lowercased() == "true"

let swiftSettings: [SwiftSetting] = isWasm ? [
    .unsafeFlags([
        "-gnone",
        "-Osize",
        "-enable-experimental-feature",
        "Extern",
        "-enable-experimental-feature",
        "Embedded",
        "-Xcc",
        "-fdeclspec",
        "-whole-module-optimization",
        "-D",
        "WASM",
        "-disable-stack-protector"
    ])
] : []

let macroSwiftSettings: [SwiftSetting] = isWasm ? [
    .unsafeFlags([
        "-D",
        "WASM"
    ])
] : []

let experimentalFeatures: [String] = []

var packageDependencies: [Package.Dependency] = [
    .package(url: "https://github.com/swiftlang/swift-syntax", from: "510.0.1"),
    .package(url: "https://github.com/swiftlang/swift-docc-symbolkit.git", exact: "1.0.0")
]

var libraryDependencies: [Target.Dependency] = [
    "CallbackMacro",
    "ControllerMacro",
    "CodableMacro",
    "EventMacro",
    "InitMacro",
    "ProxyMacro"
]

var nonWasmTargets: [Target] = []

var products: [Product] = [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(name: "SpaceKit", targets: ["SpaceKit"]),
    .library(name: "SpaceKitTesting", targets: ["SpaceKitTesting"]),
    .library(name: "SpaceKitABI", targets: ["SpaceKitABI"])
]

if !isWasm {
    products.append(
        .executable(name: "SpaceKitCLI", targets: ["SpaceKitCLI"])
    )
    
    packageDependencies.append(contentsOf: [
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0")
    ])
    
    libraryDependencies.append(contentsOf: [
        "SpaceKitABI",
        "ABIMetaMacro",
        .product(name: "BigInt", package: "BigInt")
    ])
    
    nonWasmTargets.append(contentsOf: [
        .executableTarget(
            name: "SpaceKitCLI",
            dependencies: [
                "SpaceKitCLILib",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/CLI"
        ),
        .target(
            name: "SpaceKitCLILib",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/CLILib"
        ),
        .testTarget(
            name: "ABITests",
            dependencies: [
                "SpaceKitTesting"
            ]
        ),
        .testTarget(
            name: "AsyncCallsTests",
            dependencies: [
                "SpaceKitTesting"
            ]
        ),
        .testTarget(
            name: "BufferTests",
            dependencies: [
                "SpaceKitTesting"
            ]
        ),
        .testTarget(
            name: "BigUintTests",
            dependencies: [
                "SpaceKitTesting"
            ]
        ),
        .testTarget(
            name: "IntTests",
            dependencies: [
                "SpaceKitTesting"
            ]
        ),
        .testTarget(
            name: "ContractStorageTests",
            dependencies: [
                "SpaceKitTesting"
            ]
        ),
        .testTarget(
            name: "TestEngineTests",
            dependencies: [
                "SpaceKitTesting"
            ]
        ),
        .testTarget(
            name: "CLITests",
            dependencies: [
                "SpaceKitCLILib"
            ]
        ),
        .testTarget(
            name: "ControllerMacroTests",
            dependencies: [
                "ControllerMacro",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "CodableMacroTests",
            dependencies: [
                "CodableMacro",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "CodableMacroImplTests",
            dependencies: [
                "SpaceKitTesting"
            ]
        ),
        .testTarget(
            name: "CallbackMacroImplTests",
            dependencies: [
                "SpaceKitTesting"
            ]
        ),
        .testTarget(
            name: "AdderTests",
            dependencies: [
                "SpaceKitTesting"
            ]
        ),
        .testTarget(
            name: "ArrayTests",
            dependencies: [
                "SpaceKitTesting"
            ]
        ),
        .testTarget(
            name: "EventTests",
            dependencies: [
                "SpaceKitTesting"
            ]
        ),
        .testTarget(
            name: "FactorialTests",
            dependencies: [
                "SpaceKitTesting"
            ]
        ),
        .testTarget(
            name: "BlockchainTests",
            dependencies: [
                "SpaceKitTesting"
            ]
        ),
        .testTarget(
            name: "MappersTests",
            dependencies: [
                "SpaceKitTesting"
            ]
        ),
        .testTarget(
            name: "MessageTests",
            dependencies: [
                "SpaceKitTesting"
            ]
        ),
        .testTarget(
            name: "MultiArgsTests",
            dependencies: [
                "SpaceKitTesting"
            ]
        ),
        .testTarget(
            name: "ProxyTests",
            dependencies: [
                "SpaceKitTesting"
            ]
        ),
        .testTarget(
            name: "RandomTests",
            dependencies: [
                "SpaceKitTesting"
            ]
        ),
        .testTarget(
            name: "SendTests",
            dependencies: [
                "SpaceKitTesting"
            ]
        ),
        .testTarget(
            name: "ErrorTests",
            dependencies: [
                "SpaceKitTesting"
            ]
        ),
        .testTarget(
            name: "EsdtLocalRolesTests",
            dependencies: [
                "SpaceKitTesting"
            ]
        ),
        .testTarget(
            name: "TokenIdentifierTests",
            dependencies: [
                "SpaceKitTesting"
            ]
        )
    ])
}

let package = Package(
    name: "SpaceKit",
    platforms: [
        .macOS(.v14)
    ],
    products: products,
    dependencies: packageDependencies,
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Adder",
            dependencies: [
                "SpaceKit"
            ],
            path: "Examples/Adder",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "Address",
            dependencies: [
                "SpaceKit"
            ],
            path: "Examples/FeatureTests/Address",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "BondingCurve",
            dependencies: [
                "SpaceKit"
            ],
            path: "Examples/BondingCurve",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "CallbackNotExposed",
            dependencies: [
                "SpaceKit"
            ],
            path: "Examples/FeatureTests/CallbackNotExposed",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "BlockInfo",
            dependencies: [
                "SpaceKit"
            ],
            path: "Examples/FeatureTests/BlockInfo",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "TokenOperations",
            dependencies: [
                "SpaceKit"
            ],
            path: "Examples/FeatureTests/TokenOperations",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "CheckPause",
            dependencies: [
                "SpaceKit"
            ],
            path: "Examples/CheckPause",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "Codec",
            dependencies: [
                "SpaceKit"
            ],
            path: "Examples/FeatureTests/Codec",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "CrowdfundingEsdt",
            dependencies: [
                "SpaceKit"
            ],
            path: "Examples/CrowdfundingEsdt",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "CryptoBubbles",
            dependencies: [
                "SpaceKit"
            ],
            path: "Examples/CryptoBubbles",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "CryptoKittiesAuction",
            dependencies: [
                "SpaceKit"
            ],
            path: "Examples/CryptoKitties/Auction",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "CryptoKittiesCommon",
            dependencies: [
                "SpaceKit",
                "CryptoKittiesRandom"
            ],
            path: "Examples/CryptoKitties/Common",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "CryptoKittiesRandom",
            dependencies: [
                "SpaceKit"
            ],
            path: "Examples/CryptoKitties/Random",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "CryptoKittiesGeneticAlg",
            dependencies: [
                "SpaceKit",
                "CryptoKittiesCommon",
                "CryptoKittiesRandom"
            ],
            path: "Examples/CryptoKitties/GeneticAlg",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "CryptoKittiesOwnership",
            dependencies: [
                "SpaceKit",
                "CryptoKittiesCommon",
                "CryptoKittiesRandom"
            ],
            path: "Examples/CryptoKitties/Ownership",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "DigitalCash",
            dependencies: [
                "SpaceKit"
            ],
            path: "Examples/DigitalCash",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "Empty",
            dependencies: [
                "SpaceKit"
            ],
            path: "Examples/Empty",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "EsdtTransferWithFee",
            dependencies: [
                "SpaceKit"
            ],
            path: "Examples/EsdtTransferWithFee",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "Factorial",
            dependencies: [
                "SpaceKit"
            ],
            path: "Examples/Factorial",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "LotteryEsdt",
            dependencies: [
                "SpaceKit"
            ],
            path: "Examples/LotteryEsdt",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "PingPongEgld",
            dependencies: [
                "SpaceKit"
            ],
            path: "Examples/PingPongEgld",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "ProxyPause",
            dependencies: [
                "SpaceKit"
            ],
            path: "Examples/ProxyPause",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "MultiFile",
            dependencies: [
                "SpaceKit"
            ],
            path: "Examples/MultiFile",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "Multisig",
            dependencies: [
                "SpaceKit"
            ],
            path: "Examples/Multisig",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "NftMinter",
            dependencies: [
                "SpaceKit"
            ],
            path: "Examples/NftMinter",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "OrderBookPair",
            dependencies: [
                "SpaceKit"
            ],
            path: "Examples/OrderBookPair",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "SendTestsExample",
            dependencies: [
                "SpaceKit"
            ],
            path: "Examples/SendTests",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "TokenIdentifier",
            dependencies: [
                "SpaceKit"
            ],
            path: "Examples/FeatureTests/TokenIdentifier",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "TokenRelease",
            dependencies: [
                "SpaceKit"
            ],
            path: "Examples/TokenRelease",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "SpaceKit",
            dependencies: libraryDependencies,
            swiftSettings: swiftSettings
        ),
        .target(
            name: "SpaceKitTesting",
            dependencies: [
                "SpaceKit"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "SpaceKitABI",
            swiftSettings: swiftSettings
        ),
        .macro(
            name: "ABIMetaMacro",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                "SpaceKitABI",
                .product(name: "SymbolKit", package: "swift-docc-symbolkit")
            ],
            swiftSettings: swiftSettings
        ),
        .macro(
            name: "CallbackMacro",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            swiftSettings: macroSwiftSettings
        ),
        .macro(
            name: "ControllerMacro",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            swiftSettings: macroSwiftSettings
        ),
        .macro(
            name: "CodableMacro",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            swiftSettings: macroSwiftSettings
        ),
        .macro(
            name: "EventMacro",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            swiftSettings: macroSwiftSettings
        ),
        .macro(
            name: "InitMacro",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            swiftSettings: macroSwiftSettings
        ),
        .macro(
            name: "ProxyMacro",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            swiftSettings: macroSwiftSettings
        )
    ] + nonWasmTargets
)
