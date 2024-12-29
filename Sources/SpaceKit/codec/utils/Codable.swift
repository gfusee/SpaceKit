#if WASM
public typealias SpaceCodable = TopDecode & TopDecodeMulti & TopEncode & TopEncodeMulti & NestedDecode & NestedEncode & ArrayItem
#else
import SpaceKitABI

public typealias SpaceCodable = TopDecode & TopDecodeMulti & TopEncode & TopEncodeMulti & NestedDecode & NestedEncode & ArrayItem & ABITypeExtractor
#endif
