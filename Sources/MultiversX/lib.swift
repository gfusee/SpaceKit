// TODO: report a Swift error in which Int64(<Int32 or UInt64 variable>) and UInt64(<Int32 or Int64 variable>) don't work in -no-allocations mode

#if WASM
var API = VMApi()
#else
public var API = DummyApi()
#endif

@attached(peer)
@attached(member, names: arbitrary)
#if !WASM
@attached(extension, conformances: ContractEndpointSelector, names: arbitrary)
#endif
public macro Contract() = #externalMacro(module: "ContractMacro", type: "Contract")

@attached(extension, conformances: TopEncode & TopEncodeMulti & TopDecode & TopDecodeMulti & NestedEncode & NestedDecode & ArrayItem, names: arbitrary)
public macro Codable() = #externalMacro(module: "CodableMacro", type: "Codable")

@attached(extension, names: arbitrary)
public macro Event(dataType: TopEncode.Type) = #externalMacro(module: "EventMacro", type: "Event")

@attached(extension, names: arbitrary)
public macro Proxy() = #externalMacro(module: "ProxyMacro", type: "Proxy")

var nextHandle: Int32 = -100
func getNextHandle() -> Int32 {
    let currentHandle = nextHandle
    nextHandle -= 1

    return currentHandle
}
