#if !WASM
public struct ABIConstructor: Encodable {
    let inputs: [ABIInput]
    let outputs: [ABIOutput]
}
#endif
