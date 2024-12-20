#if !WASM
public struct ABIConstructor: Encodable {
    let inputs: [ABIInput]
    let outputs: [ABIOutput]
    
    public init(
        inputs: [ABIInput],
        outputs: [ABIOutput]
    ) {
        self.inputs = inputs
        self.outputs = outputs
    }
}
#endif
