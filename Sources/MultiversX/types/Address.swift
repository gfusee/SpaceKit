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
        if buffer.count != 32 {
            fatalError()
        }
        
        self.buffer = buffer
    }
    
    public func isZero() -> Bool {
        self == Address()
    }
}

extension Address: Equatable {
    public static func == (lhs: Address, rhs: Address) -> Bool {
        return lhs.buffer == rhs.buffer
    }
}

extension Address: TopEncode { // TODO: add tests
    public func topEncode<T>(output: inout T) where T: TopEncodeOutput {
        self.buffer.topEncode(output: &output)
    }
}

extension Address: TopDecode { // TODO: add tests
    public static func topDecode(input: MXBuffer) -> Address {
        let buffer = MXBuffer.topDecode(input: input)
        
        return Address(buffer: buffer)
    }
}

extension Address: TopDecodeMulti {}

extension Address: NestedEncode { // TODO: add tests
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        dest.write(buffer: self.buffer)
    }
}

extension Address: NestedDecode { // TODO: add tests
    public static func depDecode<I>(input: inout I) -> Address where I : NestedDecodeInput {
        let buffer = input.getEntireBuffer()
        
        return Address(buffer: buffer)
    }
}
