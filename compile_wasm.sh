#!/bin/zsh

set -e

# Declare an associative array
declare -A TARGETS
TARGETS=(
    #["Adder"]="$(pwd)/Examples/Adder"
    #["BondingCurve"]="$(pwd)/Examples/BondingCurve"
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
    #["Multisig"]="$(pwd)/Examples/Multisig"
    #["NftMinter"]="$(pwd)/Examples/NftMinter"
    #["OrderBookPair"]="$(pwd)/Examples/OrderBookPair"
    #["PingPongEgld"]="$(pwd)/Examples/PingPongEgld"
    #["ProxyPause"]="$(pwd)/Examples/ProxyPause"
    ["TokenRelease"]="$(pwd)/Examples/TokenRelease"
    # Add more targets as needed
)

SWIFT_BIN_FOLDER="/Library/Developer/Toolchains/swift-6.0-DEVELOPMENT-SNAPSHOT-2024-07-16-a.xctoolchain/usr/bin/"
SCENARIO_JSON_EXECUTABLE="/Users/quentin/multiversx-sdk/vmtools/v1.5.24/mx-chain-vm-go-1.5.24/cmd/test/test"

MEMCPY_C_FILE_PATH="$(pwd)/Utils/Memory/memcpy.c"
MEMCPY_OBJECT_FILE_PATH="$(pwd)/Utils/Memory/memcpy.o"
MULTI3_C_FILE_PATH="$(pwd)/Utils/Numbers/__multi3.c"
MULTI3_OBJECT_FILE_PATH="$(pwd)/Utils/Numbers/__multi3.o"
UDIVTI3_C_FILE_PATH="$(pwd)/Utils/Numbers/__udivti3.c"
UDIVTI3_OBJECT_FILE_PATH="$(pwd)/Utils/Numbers/__udivti3.o"
PANIC_C_FILE_PATH="$(pwd)/Utils/Program/panic.c"
PANIC_OBJECT_FILE_PATH="$(pwd)/Utils/Program/panic.o"

clang --target=wasm32 -O3 -c -o $MEMCPY_OBJECT_FILE_PATH $MEMCPY_C_FILE_PATH
clang --target=wasm32 -O3 -c -o $MULTI3_OBJECT_FILE_PATH $MULTI3_C_FILE_PATH
clang --target=wasm32 -O3 -c -o $UDIVTI3_OBJECT_FILE_PATH $UDIVTI3_C_FILE_PATH
clang --target=wasm32 -O3 -c -o $PANIC_OBJECT_FILE_PATH $PANIC_C_FILE_PATH

# This will emit macros build results for the current computer's architecture
# Those macros results are needed despite we will compile later for WASM
# $SWIFT_BIN_FOLDER/swift build --target Space

# Build all targets
for TARGET in "${(k)TARGETS[@]}"; do
    TARGET_PACKAGE_PATH="${TARGETS[$TARGET]}"

    # Do not edit the below variables
    TARGET_PACKAGE_OUTPUT_PATH="$TARGET_PACKAGE_PATH/Output"
    OBJECT_FILE_PATH="$(pwd)/$TARGET.o"
    WASM_BUILT_FILE_PATH="$(pwd)/$TARGET.wasm"
    WASM_OPT_FILE_PATH="$(pwd)/$TARGET-opt.wasm"
    WASM_DEST_FILE_PATH="$TARGET_PACKAGE_OUTPUT_PATH/$TARGET.wasm"

    SWIFT_WASM=true $SWIFT_BIN_FOLDER/swift build --target $TARGET --triple wasm32-unknown-none-wasm --disable-index-store -Xswiftc -Osize -Xswiftc -gnone
    
    wasm-ld --no-entry --allow-undefined $OBJECT_FILE_PATH "$MEMCPY_OBJECT_FILE_PATH" "$MULTI3_OBJECT_FILE_PATH" "$UDIVTI3_OBJECT_FILE_PATH" "$PANIC_OBJECT_FILE_PATH" -o $WASM_BUILT_FILE_PATH
    wasm-opt -Os -o $WASM_OPT_FILE_PATH $WASM_BUILT_FILE_PATH

    mkdir -p $TARGET_PACKAGE_OUTPUT_PATH
    cp $WASM_OPT_FILE_PATH $WASM_DEST_FILE_PATH
done

# Test all targets
for TARGET in "${(k)TARGETS[@]}"; do
    TARGET_PACKAGE_PATH="${TARGETS[$TARGET]}"
    
    SCENARIOS_JSON_DIR="$TARGET_PACKAGE_PATH/Scenarios"

    $SCENARIO_JSON_EXECUTABLE $SCENARIOS_JSON_DIR
done
