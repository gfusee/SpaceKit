// TODO: report a Swift error in which Int64(<Int32 or UInt64 variable>) and UInt64(<Int32 or Int64 variable>) don't work in -no-allocations mode

#if WASM
nonisolated(unsafe) var API = VMApi()
#else
nonisolated(unsafe) public var API = DummyApi()
#endif

@attached(peer)
@attached(member, names: arbitrary)
#if !WASM
@attached(extension, conformances: ContractEndpointSelector & SwiftVMCompatibleContract, names: arbitrary)
#endif
public macro Contract() = #externalMacro(module: "ContractMacro", type: "Contract")

@attached(extension, conformances: TopEncode & TopEncodeMulti & TopDecode & TopDecodeMulti & NestedEncode & NestedDecode & ArrayItem, names: arbitrary)
public macro Codable() = #externalMacro(module: "CodableMacro", type: "Codable")

@attached(peer, names: arbitrary)
public macro Callback() = #externalMacro(module: "CallbackMacro", type: "Callback");

@attached(extension, names: arbitrary)
public macro Event(dataType: TopEncode.Type? = nil) = #externalMacro(module: "EventMacro", type: "Event")

@attached(peer)
public macro Init() = #externalMacro(module: "InitMacro", type: "Init")

@attached(extension, names: arbitrary)
public macro Proxy() = #externalMacro(module: "ProxyMacro", type: "Proxy")
