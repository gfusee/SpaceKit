#if !WASM
public struct ABITypeStructField: Encodable {
    let name: String
    let type: String

    public init(name: String, type: String) {
        self.name = name
        self.type = type
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKey.self)

        try container.encode(self.name, forKey: DynamicCodingKey("__spacekit_json_0__name"))
        try container.encode(self.type, forKey: DynamicCodingKey("__spacekit_json_1__type"))
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
