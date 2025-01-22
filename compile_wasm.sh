#!/bin/zsh

set -e

# Declare an associative array
declare -A TARGETS
TARGETS=(
        # ["Adder"]="$(pwd)/Examples/Adder"
        # ["BondingCurve"]="$(pwd)/Examples/BondingCurve"
        # ["CallbackNotExposed"]="$(pwd)/Examples/FeatureTests/CallbackNotExposed"
        # ["CheckPause"]="$(pwd)/Examples/CheckPause"
        # ["CrowdfundingEsdt"]="$(pwd)/Examples/CrowdfundingEsdt"
        # ["CryptoBubbles"]="$(pwd)/Examples/CryptoBubbles"
        # ["CryptoKittiesAuction"]="$(pwd)/Examples/CryptoKitties/Auction"
        # ["CryptoKittiesGeneticAlg"]="$(pwd)/Examples/CryptoKitties/GeneticAlg"
        # ["CryptoKittiesOwnership"]="$(pwd)/Examples/CryptoKitties/Ownership"
        # ["DigitalCash"]="$(pwd)/Examples/DigitalCash"
        # ["Empty"]="$(pwd)/Examples/Empty"
        # ["EsdtTransferWithFee"]="$(pwd)/Examples/EsdtTransferWithFee"
        # ["Factorial"]="$(pwd)/Examples/Factorial"
        # ["LotteryEsdt"]="$(pwd)/Examples/LotteryEsdt"
        # ["MultiFile"]="$(pwd)/Examples/MultiFile"
        # ["Multisig"]="$(pwd)/Examples/Multisig"
        # ["NftMinter"]="$(pwd)/Examples/NftMinter"
        # ["OrderBookPair"]="$(pwd)/Examples/OrderBookPair"
        # ["PingPongEgld"]="$(pwd)/Examples/PingPongEgld"
        # ["ProxyPause"]="$(pwd)/Examples/ProxyPause"
        # ["SendTestsExample"]="$(pwd)/Examples/SendTests"
    ["TokenOperations"]="$(pwd)/Examples/FeatureTests/TokenOperations"
    # ["TokenRelease"]="$(pwd)/Examples/TokenRelease"
    # Add more targets as needed
)

SCENARIO_JSON_EXECUTABLE="$(pwd)/Utils/Scenarios/scenariostest"

MEMCPY_C_FILE_PATH="$(pwd)/Utils/Memory/memcpy.c"
MEMCPY_OBJECT_FILE_PATH="$(pwd)/Utils/Memory/memcpy.o"
INIT_C_FILE_PATH="$(pwd)/Utils/Stub/init.c"
INIT_OBJECT_FILE_PATH="$(pwd)/Utils/Stub/init.o"
WASM32_LIB_ARCHIVE_PATH="$(pwd)/Utils/Builtins/libclang_rt.builtins-wasm32.a"

clang --target=wasm32 -O3 -c -o $MEMCPY_OBJECT_FILE_PATH $MEMCPY_C_FILE_PATH
clang --target=wasm32 -O3 -c -o $INIT_OBJECT_FILE_PATH $INIT_C_FILE_PATH

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

    SWIFT_WASM=true swift build --target $TARGET --triple wasm32-unknown-none-wasm --disable-index-store -Xswiftc -Osize -Xswiftc -gnone
    
    wasm-ld --no-entry --export init --allow-undefined $OBJECT_FILE_PATH "$WASM32_LIB_ARCHIVE_PATH" "$MEMCPY_OBJECT_FILE_PATH" "$INIT_OBJECT_FILE_PATH" -o $WASM_BUILT_FILE_PATH
    wasm-opt -Os -o $WASM_OPT_FILE_PATH $WASM_BUILT_FILE_PATH

    mkdir -p $TARGET_PACKAGE_OUTPUT_PATH
    cp $WASM_OPT_FILE_PATH $WASM_DEST_FILE_PATH
done

# Test all targets
for TARGET in "${(k)TARGETS[@]}"; do
    TARGET_PACKAGE_PATH="${TARGETS[$TARGET]}"
    
    SCENARIOS_JSON_DIR="$TARGET_PACKAGE_PATH/Scenarios"

    $SCENARIO_JSON_EXECUTABLE run $SCENARIOS_JSON_DIR
done
