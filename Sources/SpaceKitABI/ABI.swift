#if !WASM
import Foundation

public struct ABI: Encodable {
    let buildInfo: ABIBuildInfo
    let name: String
    let constructor: ABIConstructor
    let endpoints: [ABIEndpoint]
    let events: [ABIEvent]
    let types: [String: ABIType]

    public init(
        buildInfo: ABIBuildInfo,
        name: String,
        constructor: ABIConstructor,
        endpoints: [ABIEndpoint],
        events: [ABIEvent],
        types: [String: ABIType]
    ) {
        self.buildInfo = buildInfo
        self.name = name
        self.constructor = constructor
        self.endpoints = endpoints
        self.events = events
        self.types = types
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKey.self)

        try container.encode(buildInfo, forKey: DynamicCodingKey("__spacekit_json_0__buildInfo"))
        try container.encode(name, forKey: DynamicCodingKey("__spacekit_json_1__name"))
        try container.encode(constructor, forKey: DynamicCodingKey("__spacekit_json_2__constructor"))
        try container.encode(endpoints, forKey: DynamicCodingKey("__spacekit_json_3__endpoints"))
        try container.encode(events, forKey: DynamicCodingKey("__spacekit_json_4__events"))
        try container.encode(types, forKey: DynamicCodingKey("__spacekit_json_5__types"))
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
