#if WASM
public typealias SpaceCodable = TopDecode & TopDecodeMulti & TopEncode & TopEncodeMulti & NestedDecode & NestedEncode & ArrayItem
#else
public typealias SpaceCodable = TopDecode & TopDecodeMulti & TopEncode & TopEncodeMulti & NestedDecode & NestedEncode & ArrayItem & ABITypeExtractor
#endif
