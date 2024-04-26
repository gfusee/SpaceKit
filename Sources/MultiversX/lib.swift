#if WASM
var API = VMApi()
#else
var API = DummyApi()
#endif

@attached(peer)
public macro Contract() = #externalMacro(module: "ContractMacro", type: "Contract")

var nextHandle: Int32 = -100
func getNextHandle() -> Int32 {
    let currentHandle = nextHandle
    nextHandle -= 1

    return currentHandle
}
