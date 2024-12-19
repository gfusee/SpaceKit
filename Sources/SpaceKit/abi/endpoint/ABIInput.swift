#if !WASM
public struct ABIInput: Encodable {
    let name: String
    let type: String
    let multiArg: Bool?

    public init(
        name: String,
        type: String,
        multiArg: Bool?
    ) {
        self.name = name
        self.type = type
        self.multiArg = multiArg
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKey.self)

        try container.encode(name, forKey: DynamicCodingKey("__spacekit_json_0__name"))
        try container.encode(type, forKey: DynamicCodingKey("__spacekit_json_1__type"))
        try container.encodeIfPresent(multiArg, forKey: DynamicCodingKey("__spacekit_json_2__multi_arg"))
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
