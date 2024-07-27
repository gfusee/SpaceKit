private let ADDRESS_LENGTH: Int32 = 32

public struct Address {
    public let buffer: MXBuffer
    
    public init() {
        // Literal arrays avoid the use of heap allocations
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
        // TODO: for endpoint's argument decode, this doesn't tell which parameter cannot be decoded (this todo is not restricted to the Address type)
        if buffer.count != ADDRESS_LENGTH {
            smartContractError(message: "Cannot decode address: bad array length")
        }
        
        self.buffer = buffer
    }
    
    public func isZero() -> Bool {
        self == Address()
    }
    
    public func send(egldValue: BigUint) {
        let emptyBuffer = MXBuffer()
        
        let _ = API.managedTransferValueExecute( // TODO: do something with the result
            dstHandle: self.buffer.handle,
            valueHandle: egldValue.handle,
            gasLimit: 0,
            functionHandle: emptyBuffer.handle,
            argumentsHandle: emptyBuffer.handle
        )
    }

    // TODO: use the TokenIdentifier type once implemented
    public func send(tokenIdentifier: MXBuffer, nonce: UInt64, amount: BigUint) {
        // TODO: add tests
        if tokenIdentifier == "EGLD" { // TODO: no hardcoded EGLD
            self.send(egldValue: amount)
        } else {
            // TODO: instantiating a MXArray<TokenPayment> through a literal expression causes heap allocation, while instantiating some other types, such as MXArray<UInt64> doesn't. I should investigate on this
            let payments: MXArray<TokenPayment> = MXArray()
                .appended(TokenPayment.new(
                    tokenIdentifier: tokenIdentifier,
                    nonce: nonce,
                    amount: amount
                ))
            self.send(payments: payments)
        }
    }

    public func send(payments: MXArray<TokenPayment>) {
        // TODO: add tests
        let emptyBuffer = MXBuffer()

        let _ = API.managedMultiTransferESDTNFTExecute( // TODO: do something with the result
            dstHandle: self.buffer.handle,
            tokenTransfersHandle: payments.buffer.handle,
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

extension Address: TopEncodeMulti {}

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
extension Address: ExpressibleByStringLiteral {
    public init(stringLiteral value: StaticString) {
        self.init(buffer: MXBuffer(data: Array("\(value)".toAddressData())))
    }
}

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
