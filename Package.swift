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

let experimentalFeatures: [String] = []

var packageDependencies: [Package.Dependency] = [
    .package(url: "https://github.com/apple/swift-syntax", from: "510.0.1")
]

var libraryDependencies: [Target.Dependency] = [
    "CallbackMacro",
    "ContractMacro",
    "CodableMacro",
    "EventMacro",
    "ProxyMacro"
]

var testTargets: [Target] = []

var products: [Product] = [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(name: "Space", targets: ["Space"])
]

if !isWasm {
    packageDependencies.append(contentsOf: [
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.1.0"),
    ])
    
    libraryDependencies.append(contentsOf: [
        .product(name: "BigInt", package: "BigInt")
    ])
    
    testTargets.append(contentsOf: [
        .testTarget(
            name: "AsyncCallsTests",
            dependencies: [
                "Space"
            ]
        ),
        .testTarget(
            name: "BufferTests",
            dependencies: [
                "Space"
            ]
        ),
        .testTarget(
            name: "BigUintTests",
            dependencies: [
                "Space"
            ]
        ),
        .testTarget(
            name: "IntTests",
            dependencies: [
                "Space"
            ]
        ),
        .testTarget(
            name: "ContractStorageTests",
            dependencies: [
                "Space"
            ]
        ),
        .testTarget(
            name: "TestEngineTests",
            dependencies: [
                "Space"
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
                "Space"
            ]
        ),
        .testTarget(
            name: "CallbackMacroImplTests",
            dependencies: [
                "Space"
            ]
        ),
        .testTarget(
            name: "AdderTests",
            dependencies: [
                "Space"
            ]
        ),
        .testTarget(
            name: "ArrayTests",
            dependencies: [
                "Space"
            ]
        ),
        .testTarget(
            name: "EventTests",
            dependencies: [
                "Space"
            ]
        ),
        .testTarget(
            name: "FactorialTests",
            dependencies: [
                "Space"
            ]
        ),
        .testTarget(
            name: "BlockchainTests",
            dependencies: [
                "Space"
            ]
        ),
        .testTarget(
            name: "MessageTests",
            dependencies: [
                "Space"
            ]
        ),
        .testTarget(
            name: "MultiArgsTests",
            dependencies: [
                "Space"
            ]
        ),
        .testTarget(
            name: "ProxyTests",
            dependencies: [
                "Space"
            ]
        ),
        .testTarget(
            name: "SendTests",
            dependencies: [
                "Space",
                "BigInt"
            ]
        ),
        .testTarget(
            name: "ErrorTests",
            dependencies: [
                "Space",
                "BigInt"
            ]
        ),
    ])
}

let package = Package(
    name: "Space",
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
                "Space"
            ],
            path: "Examples/Adder",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "BondingCurve",
            dependencies: [
                "Space"
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
                "Space"
            ],
            path: "Examples/FeatureTests/CallbackNotExposed",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "CheckPause",
            dependencies: [
                "Space"
            ],
            path: "Examples/CheckPause",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "CrowdfundingEsdt",
            dependencies: [
                "Space"
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
                "Space"
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
                "Space"
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
                "Space",
                "CryptoKittiesRandom"
            ],
            path: "Examples/CryptoKitties/Common",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "CryptoKittiesRandom",
            dependencies: [
                "Space"
            ],
            path: "Examples/CryptoKitties/Random",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "CryptoKittiesGeneticAlg",
            dependencies: [
                "Space",
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
                "Space",
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
                "Space"
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
                "Space"
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
                "Space"
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
                "Space"
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
                "Space"
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
                "Space"
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
                "Space"
            ],
            path: "Examples/ProxyPause",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "Multisig",
            dependencies: [
                "Space"
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
                "Space"
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
                "Space"
            ],
            path: "Examples/OrderBookPair",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "TokenRelease",
            dependencies: [
                "Space"
            ],
            path: "Examples/TokenRelease",
            exclude: [
                "Scenarios",
                "Output"
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "Space",
            dependencies: libraryDependencies,
            swiftSettings: swiftSettings
        ),
        .macro(
            name: "CallbackMacro",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .macro(
            name: "ContractMacro",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .macro(
            name: "CodableMacro",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .macro(
            name: "EventMacro",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .macro(
            name: "ProxyMacro",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        )
    ] + testTargets
)
