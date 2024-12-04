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
    "InitMacro",
    "ProxyMacro"
]

var testTargets: [Target] = []

var products: [Product] = [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(name: "SpaceKit", targets: ["SpaceKit"])
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
                "SpaceKit"
            ]
        ),
        .testTarget(
            name: "BufferTests",
            dependencies: [
                "SpaceKit"
            ]
        ),
        .testTarget(
            name: "BigUintTests",
            dependencies: [
                "SpaceKit"
            ]
        ),
        .testTarget(
            name: "IntTests",
            dependencies: [
                "SpaceKit"
            ]
        ),
        .testTarget(
            name: "ContractStorageTests",
            dependencies: [
                "SpaceKit"
            ]
        ),
        .testTarget(
            name: "TestEngineTests",
            dependencies: [
                "SpaceKit"
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
                "SpaceKit"
            ]
        ),
        .testTarget(
            name: "CallbackMacroImplTests",
            dependencies: [
                "SpaceKit"
            ]
        ),
        .testTarget(
            name: "AdderTests",
            dependencies: [
                "SpaceKit"
            ]
        ),
        .testTarget(
            name: "ArrayTests",
            dependencies: [
                "SpaceKit"
            ]
        ),
        .testTarget(
            name: "EventTests",
            dependencies: [
                "SpaceKit"
            ]
        ),
        .testTarget(
            name: "FactorialTests",
            dependencies: [
                "SpaceKit"
            ]
        ),
        .testTarget(
            name: "BlockchainTests",
            dependencies: [
                "SpaceKit"
            ]
        ),
        .testTarget(
            name: "MessageTests",
            dependencies: [
                "SpaceKit"
            ]
        ),
        .testTarget(
            name: "MultiArgsTests",
            dependencies: [
                "SpaceKit"
            ]
        ),
        .testTarget(
            name: "ProxyTests",
            dependencies: [
                "SpaceKit"
            ]
        ),
        .testTarget(
            name: "SendTests",
            dependencies: [
                "SpaceKit",
                "BigInt"
            ]
        ),
        .testTarget(
            name: "ErrorTests",
            dependencies: [
                "SpaceKit",
                "BigInt"
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
            name: "InitMacro",
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
