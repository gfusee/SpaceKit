#if !WASM
import Foundation

public struct ABIOutput: Encodable {
    let type: String
    let multiResult: Bool?

    public init(
        type: String,
        multiResult: Bool?
    ) {
        self.type = type
        self.multiResult = multiResult
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKey.self)

        try container.encode(type, forKey: DynamicCodingKey("__spacekit_json_0__type"))
        try container.encodeIfPresent(multiResult, forKey: DynamicCodingKey("__spacekit_json_1__multi_result"))
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
