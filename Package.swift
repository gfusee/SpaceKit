// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let isWasm = Context.environment["SWIFT_WASM"]?.lowercased() == "true"

let swiftSettings: [SwiftSetting] = isWasm ? [
    .enableExperimentalFeature("Extern"),
    .enableExperimentalFeature("Embedded")
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

if !isWasm {
    packageDependencies.append(contentsOf: [
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
        .package(url: "https://github.com/kylef/Commander.git", exact: "0.9.1")
    ])
    
    libraryDependencies.append(contentsOf: [
        .product(name: "BigInt", package: "BigInt")
    ])
    
    testTargets.append(contentsOf: [
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
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "Space", targets: ["Space"]),
        .executable(name: "SpaceCLI", targets: ["SpaceCLI"])
    ],
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
            swiftSettings: swiftSettings
        ),
        .target(
            name: "BondingCurve",
            dependencies: [
                "Space"
            ],
            path: "Examples/BondingCurve",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "CheckPause",
            dependencies: [
                "Space"
            ],
            path: "Examples/CheckPause",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "CrowdfundingEsdt",
            dependencies: [
                "Space"
            ],
            path: "Examples/CrowdfundingEsdt",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "CryptoBubbles",
            dependencies: [
                "Space"
            ],
            path: "Examples/CryptoBubbles",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "CryptoKittiesAuction",
            dependencies: [
                "Space"
            ],
            path: "Examples/CryptoKitties/Auction",
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
            swiftSettings: swiftSettings
        ),
        .target(
            name: "DigitalCash",
            dependencies: [
                "Space"
            ],
            path: "Examples/DigitalCash",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "Empty",
            dependencies: [
                "Space"
            ],
            path: "Examples/Empty",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "EsdtTransferWithFee",
            dependencies: [
                "Space"
            ],
            path: "Examples/EsdtTransferWithFee",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "Factorial",
            dependencies: [
                "Space"
            ],
            path: "Examples/Factorial",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "LotteryEsdt",
            dependencies: [
                "Space"
            ],
            path: "Examples/LotteryEsdt",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "PingPongEgld",
            dependencies: [
                "Space"
            ],
            path: "Examples/PingPongEgld",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "ProxyPause",
            dependencies: [
                "Space"
            ],
            path: "Examples/ProxyPause",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "Multisig",
            dependencies: [
                "Space"
            ],
            path: "Examples/Multisig",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "NftMinter",
            dependencies: [
                "Space"
            ],
            path: "Examples/NftMinter",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "OrderBookPair",
            dependencies: [
                "Space"
            ],
            path: "Examples/OrderBookPair",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "TokenRelease",
            dependencies: [
                "Space"
            ],
            path: "Examples/TokenRelease",
            swiftSettings: swiftSettings
        ),
        .target(
            name: "Space",
            dependencies: libraryDependencies,
            swiftSettings: swiftSettings
        ),
        .target(
            name: "SpaceCLI",
            dependencies: [
                .product(name: "Commander", package: "Commander")
            ]
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
