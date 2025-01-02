#if !WASM
public enum ABIType {
    case `struct`(fields: [ABITypeStructField])
    case `enum`(variants: [ABITypeEnumVariant])
}

extension ABIType: Encodable {
    private struct StructEncoding: Encodable {
        let type: String
        let fields: [ABITypeStructField]

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: DynamicCodingKey.self)
            try container.encode(self.type, forKey: DynamicCodingKey("__spacekit_json_0__type"))
            try container.encode(self.fields, forKey: DynamicCodingKey("__spacekit_json_1__fields"))
        }
    }

    private struct EnumEncoding: Encodable {
        let type: String
        let variants: [ABITypeEnumVariant]

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: DynamicCodingKey.self)
            try container.encode(self.type, forKey: DynamicCodingKey("__spacekit_json_0__type"))
            try container.encode(self.variants, forKey: DynamicCodingKey("__spacekit_json_1__variants"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .struct(let fields):
            let structEncoding = StructEncoding(type: "struct", fields: fields)
            try structEncoding.encode(to: encoder)

        case .enum(let variants):
            let enumEncoding = EnumEncoding(type: "enum", variants: variants)
            try enumEncoding.encode(to: encoder)
        }
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
