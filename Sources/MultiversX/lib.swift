#if WASM
var API = VMApi()
#else
public var API = DummyApi()
#endif

@attached(peer)
@attached(member, names: arbitrary)
public macro Contract() = #externalMacro(module: "ContractMacro", type: "Contract")

@attached(extension, conformances: TopEncode & TopDecode & TopDecodeMulti & NestedEncode & NestedDecode, names: arbitrary)
public macro Codable() = #externalMacro(module: "CodableMacro", type: "Codable")

var nextHandle: Int32 = -100
func getNextHandle() -> Int32 {
    let currentHandle = nextHandle
    nextHandle -= 1

    return currentHandle
}
