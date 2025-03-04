public struct TokenIdentifier {
    nonisolated(unsafe) public static let egld: TokenIdentifier = "EGLD"
    
    public let buffer: Buffer
    
    public var isValidESDT: Bool {
        API.validateTokenIdentifier(tokenIdHandle: self.buffer.handle) != 0
    }
    
    public var isEGLD: Bool {
        self == .egld
    }
    
    public init(buffer: Buffer) {
        self.buffer = buffer
    }
}

extension TokenIdentifier: TopDecode {
    public init(topDecode input: Buffer) {
        let buffer = Buffer(topDecode: input)
        
        self.init(buffer: buffer)
    }
}

extension TokenIdentifier: TopDecodeMulti {}

extension TokenIdentifier: NestedDecode {
    public init(depDecode input: inout some NestedDecodeInput) {
        let buffer = Buffer(depDecode: &input)
        
        self.init(buffer: buffer)
    }
}

extension TokenIdentifier: TopEncode {
    @inline(__always)
    public func topEncode<EncodeOutput>(output: inout EncodeOutput) where EncodeOutput: TopEncodeOutput {
        self.buffer.topEncode(output: &output)
    }
}

extension TokenIdentifier: TopEncodeMulti {}

extension TokenIdentifier: NestedEncode {
    @inline(__always)
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        self.buffer.depEncode(dest: &dest)
    }
}

extension TokenIdentifier: ArrayItem {
    public static var payloadSize: Int32 {
        return Buffer.payloadSize
    }
    
    public static func decodeArrayPayload(payload: Buffer) -> TokenIdentifier {
        let buffer = Buffer.decodeArrayPayload(payload: payload)
        
        return TokenIdentifier(buffer: buffer)
    }
    
    public func intoArrayPayload() -> Buffer {
        return self.buffer.intoArrayPayload()
    }
}

extension TokenIdentifier: Equatable {
    public static func == (lhs: TokenIdentifier, rhs: TokenIdentifier) -> Bool {
        return lhs.buffer == rhs.buffer
    }
}

extension TokenIdentifier: ExpressibleByStringLiteral {
    public init(stringInterpolation: BufferInterpolationMatcher) {
        let buffer = Buffer(stringInterpolation: stringInterpolation)
        
        self.init(buffer: buffer)
    }

    public init(stringLiteral value: StaticString) {
        let buffer = Buffer(stringLiteral: value)
        
        self.init(buffer: buffer)
    }
}

extension TokenIdentifier: ExpressibleByStringInterpolation {}

#if !WASM
extension TokenIdentifier: ABITypeExtractor {
    public static var _abiTypeName: String {
        "TokenIdentifier"
    }
}
#endif

#if !WASM
extension TokenIdentifier: CustomDebugStringConvertible {
    public var debugDescription: String {
        self.buffer.debugDescription
    }
}

extension TokenIdentifier {
    public var utf8Description: String? {
        self.buffer.utf8Description
    }
    
    public var hexDescription: String {
        self.buffer.hexDescription
    }
}
#endif
