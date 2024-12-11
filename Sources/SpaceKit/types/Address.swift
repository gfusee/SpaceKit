private let ADDRESS_LENGTH: Int32 = 32

public struct Address {
    public let buffer: Buffer
    
    public init() {
        // Literal arrays avoid the use of heap allocations
        let emptyBytes: Bytes32 = getZeroedBytes32()
        
        self.buffer = Buffer(data: emptyBytes)
    }
    
    public init(handle: Int32) {
        let buffer = Buffer(handle: handle)
        
        self.init(buffer: buffer)
    }
    
    public init(buffer: Buffer) {
        // TODO: for endpoint's argument decode, this doesn't tell which parameter cannot be decoded (this todo is not restricted to the Address type)
        if buffer.count != ADDRESS_LENGTH {
            smartContractError(message: "Cannot decode address: bad array length")
        }
        
        self.buffer = buffer
    }
    
    package init(bytes: Bytes32) {
        self.buffer = Buffer(data: bytes)
    }
    
    public func isZero() -> Bool {
        self == Address()
    }
    
    public func getShard() -> UInt32 {
        return Blockchain.getShardOfAddress(address: self)
    }
    
    public func getBalance() -> BigUint {
        // TODO: add tests
        return Blockchain.getBalance(address: self)
    }
    
    public func getBalance(tokenIdentifier: Buffer, nonce: UInt64 = 0) -> BigUint {
        // TODO: add tests
        return Blockchain.getESDTBalance(address: self, tokenIdentifier: tokenIdentifier, nonce: nonce)
    }
    
    public func send(egldValue: BigUint) {
        let emptyBuffer = Buffer()
        
        let _ = API.managedTransferValueExecute( // TODO: do something with the result
            dstHandle: self.buffer.handle,
            valueHandle: egldValue.handle,
            gasLimit: 0,
            functionHandle: emptyBuffer.handle,
            argumentsHandle: emptyBuffer.handle
        )
    }

    // TODO: use the TokenIdentifier type once implemented
    public func send(tokenIdentifier: Buffer, nonce: UInt64, amount: BigUint) {
        // TODO: add tests
        if tokenIdentifier == "EGLD" { // TODO: no hardcoded EGLD
            self.send(egldValue: amount)
        } else {
            // TODO: instantiating a Vector<TokenPayment> through a literal expression causes heap allocation, while instantiating some other types, such as Vector<UInt64> doesn't. I should investigate on this
            let payments: Vector<TokenPayment> = Vector()
                .appended(TokenPayment(
                    tokenIdentifier: tokenIdentifier,
                    nonce: nonce,
                    amount: amount
                ))
            self.send(payments: payments)
        }
    }

    public func send(payments: Vector<TokenPayment>) {
        // TODO: add tests
        let emptyBuffer = Buffer()

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
    public init(topDecode input: Buffer) {
        let buffer = Buffer(topDecode: input)
        
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
        Buffer.payloadSize
    }
    
    public static func decodeArrayPayload(payload: Buffer) -> Address {
        return Address(buffer: Buffer.decodeArrayPayload(payload: payload))
    }
    
    public func intoArrayPayload() -> Buffer {
        self.buffer.intoArrayPayload()
    }
}

#if !WASM
extension Address: ExpressibleByStringLiteral {
    public init(stringLiteral value: StaticString) {
        self.init(buffer: Buffer(data: Array("\(value)".toAddressData())))
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
