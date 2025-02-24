#!/bin/bash

set -e

SPACEKIT_FOLDER=$(pwd)

# Detect OS and architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

if [[ "$ARCH" == "aarch64" ]]; then
    ARCH="arm64"
fi

# Determine the correct executable
if [[ "$OS" == "Darwin" && "$ARCH" == "arm64" ]]; then
    EXECUTABLE="scenariostest_darwin_arm64"
elif [[ "$OS" == "Linux" && "$ARCH" == "arm64" ]]; then
    EXECUTABLE="scenariostest_linux_arm64"
elif [[ "$OS" == "Linux" && "$ARCH" == "x86_64" ]]; then
    EXECUTABLE="scenariostest_linux_amd64"
else
    echo "❌ Error: Unsupported OS/architecture combination: $OS $ARCH"
    exit 1
fi

SCENARIO_JSON_EXECUTABLE="$(pwd)/Utils/Scenarios/$EXECUTABLE"

# Declare an associative array
declare -A TARGETS
TARGETS=(
    ["Adder"]="$(pwd)/Examples/Adder"
    #["BondingCurve"]="$(pwd)/Examples/BondingCurve"
    #["BlockInfo"]="$(pwd)/Examples/FeatureTests/BlockInfo"
    #["CallbackNotExposed"]="$(pwd)/Examples/FeatureTests/CallbackNotExposed"
    #["CheckPause"]="$(pwd)/Examples/CheckPause"
    #["CrowdfundingEsdt"]="$(pwd)/Examples/CrowdfundingEsdt"
    #["CryptoBubbles"]="$(pwd)/Examples/CryptoBubbles"
    #["CryptoKittiesAuction"]="$(pwd)/Examples/CryptoKitties/Auction"
    #["CryptoKittiesGeneticAlg"]="$(pwd)/Examples/CryptoKitties/GeneticAlg"
    #["CryptoKittiesOwnership"]="$(pwd)/Examples/CryptoKitties/Ownership"
    #["DigitalCash"]="$(pwd)/Examples/DigitalCash"
    #["Empty"]="$(pwd)/Examples/Empty"
    #["EsdtTransferWithFee"]="$(pwd)/Examples/EsdtTransferWithFee"
    #["Factorial"]="$(pwd)/Examples/Factorial"
    #["LotteryEsdt"]="$(pwd)/Examples/LotteryEsdt"
    #["MultiFile"]="$(pwd)/Examples/MultiFile"
    #["Multisig"]="$(pwd)/Examples/Multisig"
    #["NftMinter"]="$(pwd)/Examples/NftMinter"
    #["OrderBookPair"]="$(pwd)/Examples/OrderBookPair"
    #["PingPongEgld"]="$(pwd)/Examples/PingPongEgld"
    #["ProxyPause"]="$(pwd)/Examples/ProxyPause"
    #["SendTestsExample"]="$(pwd)/Examples/SendTests"
    #["TokenOperations"]="$(pwd)/Examples/FeatureTests/TokenOperations"
    #["TokenRelease"]="$(pwd)/Examples/TokenRelease"
    # Add more targets as needed
)

# Create a temporary directory for the CLI
TEMP_CLI_DIR=$(mktemp -d)
TEMP_CLI_BIN=$TEMP_CLI_DIR/space

TEMP_WASM_DIR=$(mktemp -d)

swift build --product SpaceKitCLI && cp -f .build/debug/SpaceKitCLI "$TEMP_CLI_BIN"

# Build all targets
for TARGET in "${!TARGETS[@]}"; do
    echo "Building $TARGET..."
    
    TARGET_PACKAGE_PATH="${TARGETS[$TARGET]}"
    TARGET_OUTPUT_DIR=$TEMP_WASM_DIR/$TARGET/Output
    mkdir -p "$TARGET_OUTPUT_DIR"
    
    # Create a temporary directory and navigate into it
    TEMP_TARGET_DIR=$(mktemp -d)
    cd "$TEMP_TARGET_DIR" || exit 1
    
    # Run the SpaceKitCLI command
    "$TEMP_CLI_BIN" init Test --spacekit-local-path "$SPACEKIT_FOLDER"
    
    # Navigate into the Test directory
    cd Test || exit 1
    
    # Remove everything except Package.swift
    find . -mindepth 1 -maxdepth 1 ! -name "Package.swift" -exec rm -rf {} +

    # Create required folder structure
    mkdir -p Contracts/Test/Sources
    mkdir -p Contracts/Test/Tests/TestTests
    
    # Copy sources from TARGET_PACKAGE_PATH to the newly created Sources folder
    cp -r "$TARGET_PACKAGE_PATH"/* Contracts/Test/Sources/
    
    # Run the space contract build command
    # The first time the command is ran we might encounter an unknown error such as "<unknown>:0: error: missing required module 'SwiftParser'"
    # Running the command a second time fixes the error
    "$TEMP_CLI_BIN" contract build --spacekit-local-path "$SPACEKIT_FOLDER" || "$TEMP_CLI_BIN" contract build --spacekit-local-path "$SPACEKIT_FOLDER" || exit 1
    
    cp Contracts/Test/Output/Test.wasm "$TARGET_OUTPUT_DIR/$TARGET.wasm"
    
    # Cleanup: Remove temporary directory (optional, comment out if needed)
    rm -rf "$TEMP_TARGET_DIR"
    
    # Return to the original directory
    cd "$SPACEKIT_FOLDER" || exit 1
done

# Test all targets
for TARGET in "${!TARGETS[@]}"; do
    echo "Testing $TARGET..."
    
    TARGET_PACKAGE_PATH="${TARGETS[$TARGET]}"
    TARGET_OUTPUT_DIR=$TEMP_WASM_DIR/$TARGET
    
    TARGET_SCENARIOS_DIR=$TEMP_WASM_DIR/$TARGET/Scenarios
    mkdir -p "$TARGET_SCENARIOS_DIR"
    cp -r "$TARGET_PACKAGE_PATH/Scenarios/." "$TARGET_SCENARIOS_DIR"
    
    SCENARIOS_JSON_DIR="$TARGET_OUTPUT_DIR/Scenarios"
    
    echo "yeah"
    echo "$SCENARIO_JSON_EXECUTABLE run $SCENARIOS_JSON_DIR"

    "$SCENARIO_JSON_EXECUTABLE" run "$SCENARIOS_JSON_DIR"
done
