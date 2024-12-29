#if !WASM
import Foundation

public struct ABITypeEnumVariant: Encodable {
    let name: String
    let discriminant: UInt8
    let fields: [ABITypeStructField]?

    public init(
        name: String,
        discriminant: UInt8,
        fields: [ABITypeStructField]? = nil
    ) {
        self.name = name
        self.discriminant = discriminant
        self.fields = fields
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKey.self)

        try container.encode(self.name, forKey: DynamicCodingKey("__spacekit_json_0__name"))
        try container.encode(self.discriminant, forKey: DynamicCodingKey("__spacekit_json_1__discriminant"))
        try container.encodeIfPresent(self.fields, forKey: DynamicCodingKey("__spacekit_json_2__fields"))
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
