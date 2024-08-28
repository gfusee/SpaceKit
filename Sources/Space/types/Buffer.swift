@inline(__always)
fileprivate func initFromBytesPointer(handle: Int32, pointer: UnsafeMutableRawBufferPointer) {
    guard let baseAddress = pointer.baseAddress else {
        fatalError()
    }
    
    let _ = API.bufferSetBytes(handle: handle, bytePtr: baseAddress, byteLen: Int32(pointer.count))
}

public struct Buffer {
    public let handle: Int32
    
    public var count: Int32 {
        get {
            return self.getCountSized()
        }
    }
    
    public var isEmpty: Bool {
        // TODO: add tests
        return self.count == 0
    }

    public init(_ string: StaticString) {
        let handle = getNextHandle()
        let _ = API.bufferSetBytes(handle: handle, bytePtr: string.utf8Start, byteLen: Int32(string.utf8CodeUnitCount))

        self.handle = handle
    }
    
    #if !WASM
    public init(_ string: String) {
        self.init(data: Array(string.utf8))
    }
    
    @inline(__always)
    package init(data: [UInt8]) {
        let handle = getNextHandle()
        
        var data = data
        
        let _ = API.bufferSetBytes(handle: handle, bytePtr: &data, byteLen: Int32(data.count))
        
        self.handle = handle
    }
    #endif
    
    @inline(__always)
    package init(data: UInt8) {
        let handle = getNextHandle()
        
        var data = data
        
        let _ = API.bufferSetBytes(handle: handle, bytePtr: &data, byteLen: 1)
        
        self.handle = handle
    }
    
    @inline(__always)
    package init(data: Bytes2) {
        let handle = getNextHandle()
        
        var data = data
        
        let _ = API.bufferSetBytes(handle: handle, bytePtr: &data, byteLen: 2)
        
        self.handle = handle
    }
    
    @inline(__always)
    package init(data: Bytes4) {
        let handle = getNextHandle()
        
        var data = data
        
        let _ = API.bufferSetBytes(handle: handle, bytePtr: &data, byteLen: 4)
        
        self.handle = handle
    }
    
    @inline(__always)
    package init(data: Bytes8) {
        let handle = getNextHandle()
        
        var data = data
        
        let _ = API.bufferSetBytes(handle: handle, bytePtr: &data, byteLen: 8)
        
        self.handle = handle
    }
    
    @inline(__always)
    package init(data: Bytes32) {
        let handle = getNextHandle()
        
        var data = data
        
        let _ = API.bufferSetBytes(handle: handle, bytePtr: &data, byteLen: 32)
        
        self.handle = handle
    }

    public init() {
        self.init("")
    }

    public init(handle: Int32) {
        self.handle = handle
    }

    public func appended(_ other: Self) -> Buffer {
        var cloned = self.clone()
        cloned.appendUnsafe(other)
        
        return cloned
    }
    
    private mutating func appendUnsafe(_ other: Self) {
        let _ = API.bufferAppend(accumulatorHandle: self.handle, dataHandle: other.handle)
    }
    
    package mutating func setRandomUnsafe(length: Int32) {
        let _ = API.mBufferSetRandom(destinationHandle: self.handle, length: length)
    }
    
    public func clone() -> Buffer {
        let cloned = Buffer()
        let _ = API.bufferAppend(accumulatorHandle: cloned.handle, dataHandle: self.handle)
        
        return cloned
    }
    
    #if !WASM
    public func toBytes() -> [UInt8] {
        let selfCount = self.count
        var result: [UInt8] = Array(repeating: 0, count: Int(selfCount))
        
        let _ = API.bufferGetBytes(handle: self.handle, resultPointer: &result)
        
        return result
    }
    #endif
    
    @inline(__always)
    package func to32BytesStackArray() -> Bytes32 {
        require(
            self.count <= 32,
            "TODO" // TODO: add an error message
        )
        
        var bytes: Bytes32 = (
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0
        )
        
        let _ = API.bufferGetBytes(handle: self.handle, resultPointer: &bytes)
        
        return bytes
    }
    
    package func toBigEndianBytes8() -> Bytes8 {
        let count = self.count
        
        require(
            count <= 8,
            "wrong buffer bytes count"
        )
        
        var resultWithoutLeadingZeros = getZeroedBytes8()
        
        let _ = API.bufferGetBytes(handle: self.handle, resultPointer: &resultWithoutLeadingZeros)
        
        var result = getZeroedBytes8()
        
        var counter: Int32 = 0
        let lastIndex: Int32 = 7
        let numberOfLeadingZeros = 8 - count
        
        // If self is [4, 3, 2], then resultWithoutLeadingZeros is 43200000 and result should be 00000432
        while counter <= lastIndex {
            if counter >= numberOfLeadingZeros {
                let sourceByte = accessNthElementOfBytes8(index: counter - numberOfLeadingZeros, bytes: resultWithoutLeadingZeros)
                setNthElementOfBytes8(index: counter, bytes: &result, value: sourceByte)
            }
            
            counter += 1
        }
        
        return result
    }
    
    func getCountSized() -> Int32 {
        return API.bufferGetLength(handle: self.handle)
    }

    public func finish() {
        let _ = API.bufferFinish(handle: self.handle)
    }
    
    package func withReplaced(startingPosition: Int32, with buffer: Buffer) -> Buffer {
        let bufferCount = buffer.count
        
        let sliceBeforeCount = startingPosition
        let sliceBefore = sliceBeforeCount == 0 ? Buffer() : self.getSubBuffer(startIndex: 0, length: sliceBeforeCount)
        
        let endPosition = startingPosition + bufferCount
        let sliceAfterCount = self.count - bufferCount - sliceBeforeCount
        let sliceAfter = sliceAfterCount == 0 ? Buffer() :  self.getSubBuffer(startIndex: endPosition, length: sliceAfterCount)
        
        return sliceBefore + buffer + sliceAfter
    }
    
    public func getSubBuffer(startIndex: Int32, length: Int32) -> Buffer {
        guard length > 0 else {
            if length == 0 {
                return Buffer()
            }
            
            smartContractError(message: "Negative slice length.")
        }
        
        let result = Buffer()
        
        let _ = API.bufferCopyByteSlice(
            sourceHandle: self.handle,
            startingPosition: startIndex,
            sliceLength: length,
            destinationHandle: result.handle
        )
        
        return result
    }
    
    public func toHexadecimalBuffer() -> Buffer {
        let resultHandle = getNextHandle()
        
        API.managedBufferToHex(sourceHandle: self.handle, destinationHandle: resultHandle)
        
        return Buffer(handle: resultHandle)
    }
}

extension Buffer: TopDecode {
    public init(topDecode input: Buffer) {
        self = input.clone()
    }
}

extension Buffer: TopDecodeMulti {}

extension Buffer: NestedDecode {
    public init(depDecode input: inout some NestedDecodeInput) {
        self = input.readNextBufferOfDynamicLength()
    }
}

extension Buffer: TopEncodeOutput {
    public mutating func setBuffer(buffer: Buffer) {
        self = buffer
    }
}

extension Buffer: TopEncode {
    @inline(__always)
    public func topEncode<EncodeOutput>(output: inout EncodeOutput) where EncodeOutput: TopEncodeOutput {
        output.setBuffer(buffer: self)
    }
}

extension Buffer: TopEncodeMulti {}

extension Buffer: NestedEncode {
    @inline(__always)
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        Int(self.count).depEncode(dest: &dest)
        dest.write(buffer: self)
    }
}

extension Buffer: NestedEncodeOutput {
    public mutating func write(buffer: Buffer) {
        self.appendUnsafe(buffer)
    }
}

extension Buffer: ArrayItem {
    public static var payloadSize: Int32 {
        return 4
    }
    
    public static func decodeArrayPayload(payload: Buffer) -> Buffer {
        var payloadInput = BufferNestedDecodeInput(buffer: payload)
        
        let handle = Int32(Int(depDecode: &payloadInput))
        
        guard !payloadInput.canDecodeMore() else {
            fatalError()
        }
        
        return Buffer(handle: handle)
    }
    
    public func intoArrayPayload() -> Buffer {
        return Buffer(data: self.handle.toBytes4())
    }
}

extension Buffer: Equatable {
    public static func == (lhs: Buffer, rhs: Buffer) -> Bool {
        return API.bufferEqual(handle1: lhs.handle, handle2: rhs.handle) > 0
    }
}

extension Buffer {
    public static func + (lhs: Buffer, rhs: Buffer) -> Buffer {
        return lhs.appended(rhs)
    }
}

extension Buffer: ExpressibleByStringLiteral {
    public init(stringInterpolation: BufferInterpolationMatcher) {
        self.handle = stringInterpolation.buffer.handle
    }

    public init(stringLiteral value: StaticString) {
        self.init(value)
    }
}

public struct BufferInterpolationMatcher: StringInterpolationProtocol {
    var buffer: Buffer

    public init(literalCapacity: Int, interpolationCount: Int) {
        self.buffer = Buffer()
    }

    public mutating func appendLiteral(_ literal: StaticString) {
        self.buffer = self.buffer + Buffer(literal)
    }

    public mutating func appendInterpolation(_ value: Buffer) {
        self.buffer = self.buffer + value
    }
    
    #if !WASM
    public mutating func appendInterpolation(_ value: String) {
        self.buffer = self.buffer + Buffer(value)
    }
    #endif
    
    public mutating func appendInterpolation(_ value: StaticString) {
        self.buffer = self.buffer + Buffer(value)
    }

    public mutating func appendInterpolation(_ value: BigUint) {
        self.buffer = self.buffer + value.toBuffer()
    }
    
    public mutating func appendInterpolation(_ value: Address) {
        self.buffer = self.buffer + value.buffer // TODO: Is this the correct implementation?
    }
}

extension Buffer: ExpressibleByStringInterpolation {}

#if !WASM
extension Buffer: CustomDebugStringConvertible {
    public var debugDescription: String {
        var result = "0x\(self.hexDescription)"
        
        if let utf8Description = self.utf8Description {
            result = "\(result) (UTF8: \(utf8Description))"
        }
        
        return result
    }
}

extension Buffer {
    public var utf8Description: String? {
        API.bufferToUTF8String(handle: self.handle)
    }
    
    public var hexDescription: String {
        API.bufferToDebugString(handle: self.handle)
    }
}
#endif
