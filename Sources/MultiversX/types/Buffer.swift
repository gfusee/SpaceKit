public typealias MXString = MXBuffer

@inline(__always)
fileprivate func initFromBytesPointer(handle: Int32, pointer: UnsafeMutableRawBufferPointer) {
    guard let baseAddress = pointer.baseAddress else {
        fatalError()
    }
    
    let _ = API.bufferSetBytes(handle: handle, bytePtr: baseAddress, byteLen: Int32(pointer.count))
}

public struct MXBuffer {
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

    public func appended(_ other: Self) -> MXBuffer {
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
    
    public func clone() -> MXBuffer {
        let cloned = MXBuffer()
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
    
    package func withReplaced(startingPosition: Int32, with buffer: MXBuffer) -> MXBuffer {
        let bufferCount = buffer.count
        
        let sliceBeforeCount = startingPosition
        let sliceBefore = sliceBeforeCount == 0 ? MXBuffer() : self.getSubBuffer(startIndex: 0, length: sliceBeforeCount)
        
        let endPosition = startingPosition + bufferCount
        let sliceAfterCount = self.count - bufferCount - sliceBeforeCount
        let sliceAfter = sliceAfterCount == 0 ? MXBuffer() :  self.getSubBuffer(startIndex: endPosition, length: sliceAfterCount)
        
        return sliceBefore + buffer + sliceAfter
    }
    
    public func getSubBuffer(startIndex: Int32, length: Int32) -> MXBuffer {
        guard length > 0 else {
            if length == 0 {
                return MXBuffer()
            }
            
            smartContractError(message: "Negative slice length.")
        }
        
        let resultHandle = getNextHandle()
        
        let _ = API.bufferCopyByteSlice(
            sourceHandle: self.handle,
            startingPosition: startIndex,
            sliceLength: length,
            destinationHandle: resultHandle
        )
        
        return MXBuffer(handle: resultHandle)
    }
    
    public func toHexadecimalBuffer() -> MXBuffer {
        let resultHandle = getNextHandle()
        
        API.managedBufferToHex(sourceHandle: self.handle, destinationHandle: resultHandle)
        
        return MXBuffer(handle: resultHandle)
    }
}

extension MXBuffer: TopDecode {
    public init(topDecode input: MXBuffer) {
        self = input.clone()
    }
}

extension MXBuffer: TopDecodeMulti {}

extension MXBuffer: NestedDecode {
    public init(depDecode input: inout some NestedDecodeInput) {
        self = input.readNextBufferOfDynamicLength()
    }
}

extension MXBuffer: TopEncodeOutput {
    public mutating func setBuffer(buffer: MXBuffer) {
        self = buffer
    }
}

extension MXBuffer: TopEncode {
    @inline(__always)
    public func topEncode<EncodeOutput>(output: inout EncodeOutput) where EncodeOutput: TopEncodeOutput {
        output.setBuffer(buffer: self)
    }
}

extension MXBuffer: TopEncodeMulti {}

extension MXBuffer: NestedEncode {
    @inline(__always)
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        Int(self.count).depEncode(dest: &dest)
        dest.write(buffer: self)
    }
}

extension MXBuffer: NestedEncodeOutput {
    public mutating func write(buffer: MXBuffer) {
        self.appendUnsafe(buffer)
    }
}

extension MXBuffer: ArrayItem {
    public static var payloadSize: Int32 {
        return 4
    }
    
    public static func decodeArrayPayload(payload: MXBuffer) -> MXBuffer {
        var payloadInput = BufferNestedDecodeInput(buffer: payload)
        
        let handle = Int32(Int(depDecode: &payloadInput))
        
        guard !payloadInput.canDecodeMore() else {
            fatalError()
        }
        
        return MXBuffer(handle: handle)
    }
    
    public func intoArrayPayload() -> MXBuffer {
        return MXBuffer(data: self.handle.toBytes4())
    }
}

extension MXBuffer: Equatable {
    public static func == (lhs: MXBuffer, rhs: MXBuffer) -> Bool {
        return API.bufferEqual(handle1: lhs.handle, handle2: rhs.handle) > 0
    }
}

extension MXBuffer {
    public static func + (lhs: MXBuffer, rhs: MXBuffer) -> MXBuffer {
        return lhs.appended(rhs)
    }
}

extension MXBuffer: ExpressibleByStringLiteral {
    public init(stringInterpolation: BufferInterpolationMatcher) {
        self.handle = stringInterpolation.buffer.handle
    }

    public init(stringLiteral value: StaticString) {
        self.init(value)
    }
}

public struct BufferInterpolationMatcher: StringInterpolationProtocol {
    var buffer: MXBuffer

    public init(literalCapacity: Int, interpolationCount: Int) {
        self.buffer = MXBuffer()
    }

    public mutating func appendLiteral(_ literal: StaticString) {
        self.buffer = self.buffer + MXBuffer(literal)
    }

    public mutating func appendInterpolation(_ value: MXBuffer) {
        self.buffer = self.buffer + value
    }
    
    #if !WASM
    public mutating func appendInterpolation(_ value: String) {
        self.buffer = self.buffer + MXBuffer(value)
    }
    #endif
    
    public mutating func appendInterpolation(_ value: StaticString) {
        self.buffer = self.buffer + MXBuffer(value)
    }

    public mutating func appendInterpolation(_ value: BigUint) {
        self.buffer = self.buffer + value.toBuffer()
    }
}

extension MXBuffer: ExpressibleByStringInterpolation {}

#if !WASM
extension MXBuffer: CustomDebugStringConvertible {
    public var debugDescription: String {
        var result = "0x\(self.hexDescription)"
        
        if let utf8Description = self.utf8Description {
            result = "\(result) (UTF8: \(utf8Description))"
        }
        
        return result
    }
}

extension MXBuffer {
    public var utf8Description: String? {
        API.bufferToUTF8String(handle: self.handle)
    }
    
    public var hexDescription: String {
        API.bufferToDebugString(handle: self.handle)
    }
}
#endif
