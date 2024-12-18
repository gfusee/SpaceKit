#if !WASM
public enum ABIType {
    case `struct`(fields: [ABITypeStructField])
    case `enum`(variants: [ABITypeEnumVariant])
}

extension ABIType: Encodable {
    private struct StructEncoding: Encodable {
        let type: String
        let fields: [ABITypeStructField]
    }

    private struct EnumEncoding: Encodable {
        let type: String
        let variants: [ABITypeEnumVariant]
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
#endif
