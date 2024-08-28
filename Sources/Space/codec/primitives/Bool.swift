// TODO: add tests

fileprivate extension UInt8 {
    init(_ bool: Bool) {
        self = bool ? 1 : 0
    }
}

extension Bool: TopEncode {
    public func topEncode<T>(output: inout T) where T : TopEncodeOutput {
        UInt8(self).topEncode(output: &output)
    }
}

extension Bool: TopEncodeMulti {}

extension Bool: NestedEncode {
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        UInt8(self).depEncode(dest: &dest)
    }
}

extension Bool: TopDecode {
    public init(topDecode input: MXBuffer) {
        let integer = UInt8(topDecode: input)
        
        switch integer {
        case 0:
            self = false
        case 1:
            self = true
        default:
            fatalError() // TODO
        }
    }
}

extension Bool: TopDecodeMulti {}

extension Bool: NestedDecode {
    public init(depDecode input: inout some NestedDecodeInput) {
        let integer = UInt8(depDecode: &input)
        
        switch integer {
        case 0:
            self = false
        case 1:
            self = true
        default:
            fatalError() // TODO
        }
    }
}

extension Bool: ArrayItem {
    public static var payloadSize: Int32 {
        UInt8.payloadSize
    }
    
    public static func decodeArrayPayload(payload: MXBuffer) -> Bool {
        return Bool(topDecode: payload)
    }
    
    public func intoArrayPayload() -> MXBuffer {
        var payload = MXBuffer()
        
        self.depEncode(dest: &payload)
        
        return payload
    }
}
