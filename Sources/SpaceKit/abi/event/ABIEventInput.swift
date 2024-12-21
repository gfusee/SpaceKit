#if !WASM
public struct ABIEventInput: Encodable {
    let name: String
    let type: String
    let indexed: Bool?

    public init(
        name: String,
        type: String,
        indexed: Bool?
    ) {
        self.name = name
        self.type = type
        self.indexed = indexed
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKey.self)

        try container.encode(self.name, forKey: DynamicCodingKey("__spacekit_json_0__name"))
        try container.encode(self.type, forKey: DynamicCodingKey("__spacekit_json_1__type"))
        try container.encodeIfPresent(self.indexed, forKey: DynamicCodingKey("__spacekit_json_2__indexed"))
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
