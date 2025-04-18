// TODO: report a Swift error in which Int64(<Int32 or UInt64 variable>) and UInt64(<Int32 or Int64 variable>) don't work in -no-allocations mode

#if !WASM
@_exported import SpaceKitABI

#if !canImport (Foundation)
#error("Foundation framework is required when not compiling to WebAssembly.")
#else
@_exported import Foundation
#endif

#endif

#if WASM
nonisolated(unsafe) var API = VMApi()
#else
nonisolated(unsafe) public var API = DummyApi()
#endif

@attached(peer)
@attached(member, names: arbitrary)
#if !WASM
@attached(extension, conformances: ContractEndpointSelector & SwiftVMCompatibleContract & ABIEndpointsExtractor, names: arbitrary)
#endif
public macro Controller() = #externalMacro(module: "ControllerMacro", type: "Controller")

@attached(member, names: arbitrary)
#if WASM
@attached(extension, conformances: TopEncode & TopEncodeMulti & TopDecode & TopDecodeMulti & NestedEncode & NestedDecode & ArrayItem, names: arbitrary)
#else
@attached(extension, conformances: TopEncode & TopEncodeMulti & TopDecode & TopDecodeMulti & NestedEncode & NestedDecode & ArrayItem & ABITypeExtractor, names: arbitrary)
#endif
public macro Codable() = #externalMacro(module: "CodableMacro", type: "Codable")

@attached(peer, names: arbitrary)
public macro Callback() = #externalMacro(module: "CallbackMacro", type: "Callback");

@attached(extension, names: arbitrary)
#if WASM
@attached(extension, names: arbitrary)
#else
@attached(extension, conformances: ABIEventExtractor, names: arbitrary)
#endif
public macro Event(dataType: TopEncode.Type? = nil) = #externalMacro(module: "EventMacro", type: "Event")

@attached(peer, names: named(__ContractInit), named(SpaceKitInitConstructorExtractor))
public macro Init() = #externalMacro(module: "InitMacro", type: "Init")

@attached(extension, names: arbitrary)
public macro Proxy() = #externalMacro(module: "ProxyMacro", type: "Proxy")

#if !WASM
@attached(member, names: arbitrary)
public macro ABIMeta(graphJSONContents: [String], spaceKitGraphJSONContent: String) = #externalMacro(module: "ABIMetaMacro", type: "ABIMeta")
#endif
