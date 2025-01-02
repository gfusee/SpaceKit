#if !WASM
public struct ABIEndpoint: Encodable {
    let name: String
    let onlyOwner: Bool?
    let mutability: ABIEndpointMutability
    let payableInTokens: [ABIEndpointPayableInTokens]?
    let inputs: [ABIInput]
    let outputs: [ABIOutput]

    public init(
        name: String,
        onlyOwner: Bool?,
        mutability: ABIEndpointMutability,
        payableInTokens: [ABIEndpointPayableInTokens]?,
        inputs: [ABIInput],
        outputs: [ABIOutput]
    ) {
        self.name = name
        self.onlyOwner = onlyOwner
        self.mutability = mutability
        self.payableInTokens = payableInTokens
        self.inputs = inputs
        self.outputs = outputs
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKey.self)

        try container.encode(self.name, forKey: DynamicCodingKey("__spacekit_json_0__name"))
        try container.encodeIfPresent(self.onlyOwner, forKey: DynamicCodingKey("__spacekit_json_1__onlyOwner"))
        try container.encode(self.mutability, forKey: DynamicCodingKey("__spacekit_json_2__mutability"))
        try container.encodeIfPresent(self.payableInTokens, forKey: DynamicCodingKey("__spacekit_json_3__payableInTokens"))
        try container.encode(self.inputs, forKey: DynamicCodingKey("__spacekit_json_4__inputs"))
        try container.encode(self.outputs, forKey: DynamicCodingKey("__spacekit_json_5__outputs"))
    }
}

/// Dynamic coding key to support custom field names
private struct DynamicCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int? { return nil }

    init(_ string: String) {
        self.stringValue = string
    }

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        return nil
    }
}
#endif
