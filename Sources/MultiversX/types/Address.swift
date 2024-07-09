private let ADDRESS_LENGTH: Int32 = 32

public struct Address {
    let buffer: MXBuffer
    
    public init() {
        // Literal arrays avoid the use of posix_memalign symbol
        let emptyBytes: [UInt8] = [
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0
        ]
        
        self.buffer = MXBuffer(data: emptyBytes)
    }
    
    public init(handle: Int32) {
        let buffer = MXBuffer(handle: handle)
        
        self.init(buffer: buffer)
    }
    
    public init(buffer: MXBuffer) {
        if buffer.count != ADDRESS_LENGTH {
            fatalError()
        }
        
        self.buffer = buffer
    }
    
    public func isZero() -> Bool {
        self == Address()
    }
    
    public func send(egldValue: BigUint) {
        let emptyBuffer = MXBuffer()
        
        let _ = API.managedTransferValueExecute(
            dstHandle: self.buffer.handle,
            valueHandle: egldValue.handle,
            gasLimit: 0,
            functionHandle: emptyBuffer.handle,
            argumentsHandle: emptyBuffer.handle
        )
    }
}

extension Address: Equatable {
    public static func == (lhs: Address, rhs: Address) -> Bool {
        return lhs.buffer == rhs.buffer
    }
}

extension Address: TopEncode { // TODO: add tests
    @inline(__always)
    public func topEncode<EncodeOutput>(output: inout EncodeOutput) where EncodeOutput: TopEncodeOutput {
        self.buffer.topEncode(output: &output)
    }
}

extension Address: TopDecode { // TODO: add tests
    public init(topDecode input: MXBuffer) {
        let buffer = MXBuffer(topDecode: input)
        
        self = Self(buffer: buffer)
    }
}

extension Address: TopDecodeMulti {}

extension Address: NestedEncode { // TODO: add tests
    @inline(__always)
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        dest.write(buffer: self.buffer)
    }
}

extension Address: NestedDecode {
    public init(depDecode input: inout some NestedDecodeInput) {
        let buffer = input.readNextBuffer(length: ADDRESS_LENGTH)
        
        self = Self(buffer: buffer)
    }
}

extension Address: ArrayItem {
    public static var payloadSize: Int32 {
        MXBuffer.payloadSize
    }
    
    public static func decodeArrayPayload(payload: MXBuffer) -> Address {
        return Address(buffer: MXBuffer.decodeArrayPayload(payload: payload))
    }
    
    public func intoArrayPayload() -> MXBuffer {
        self.buffer.intoArrayPayload()
    }
}

#if !WASM
extension Address: CustomDebugStringConvertible {
    public var debugDescription: String {
        self.hexDescription
    }
}

extension Address {
    public var hexDescription: String {
        self.buffer.hexDescription
    }
}
#endif
