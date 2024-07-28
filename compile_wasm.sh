set -e

TARGET="Empty"
SWIFT_BIN_FOLDER="/Library/Developer/Toolchains/swift-6.0-DEVELOPMENT-SNAPSHOT-2024-07-16-a.xctoolchain/usr/bin/"
SCENARIO_JSON_EXECUTABLE="/Users/quentin/multiversx-sdk/vmtools/v1.5.24/mx-chain-vm-go-1.5.24/cmd/test/test"

# Do not edit the below variables
TARGET_PACKAGE_PATH="$(pwd)/Examples/$TARGET"
TARGET_PACKAGE_OUTPUT_PATH="$TARGET_PACKAGE_PATH/output"
OBJECT_FILE_PATH="$(pwd)/$TARGET.o"
WASM_BUILT_FILE_PATH="$(pwd)/$TARGET.wasm"
WASM_OPT_FILE_PATH="$(pwd)/$TARGET-opt.wasm"
WASM_DEST_FILE_PATH="$TARGET_PACKAGE_OUTPUT_PATH/$TARGET.wasm"
SCENARIOS_JSON_DIR="$TARGET_PACKAGE_PATH/scenarios"

# rm -rf .build || true
# rm -rf *.o || true
# rm -rf *.d || true

SWIFT_WASM=true $SWIFT_BIN_FOLDER/swift build --target $TARGET --triple wasm32-unknown-none-wasm --disable-index-store -Xswiftc -Osize -Xswiftc -gnone
wasm-ld --no-entry --allow-undefined $OBJECT_FILE_PATH -o $WASM_BUILT_FILE_PATH
wasm-opt -Os -o $WASM_OPT_FILE_PATH $WASM_BUILT_FILE_PATH

mkdir -p $TARGET_PACKAGE_OUTPUT_PATH
cp $WASM_OPT_FILE_PATH $WASM_DEST_FILE_PATH

$SCENARIO_JSON_EXECUTABLE $SCENARIOS_JSON_DIR
