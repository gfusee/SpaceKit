public struct BigUint {
    let handle: Int32
    
    public init() {
        self.init(value: 0)
    }

    public init(value: Int64) {
        let handle = getNextHandle()
        API.bigIntSetInt64(destination: handle, value: value)
        self.handle = handle
    }
    
    public init(bigEndianBuffer: MXBuffer) {
        let handle = getNextHandle()
        let _ = API.bufferToBigIntUnsigned(bufferHandle: bigEndianBuffer.handle, bigIntHandle: handle)
        
        self.handle = handle
    }
    
    init(handle: Int32) {
        self.handle = handle
    }

    public func toBuffer() -> MXBuffer {
        let destHandle = getNextHandle()
        API.bigIntToBuffer(bigIntHandle: self.handle, destHandle: destHandle)

        return MXBuffer(handle: destHandle)
    }
    
    public func toInt64() -> Int64? {
        return API.bigIntGetInt64(reference: self.handle)
    }
    
    func toBytesBigEndianBuffer() -> MXBuffer {
        let handle = getNextHandle()
        let _ = API.bufferFromBigIntUnsigned(bufferHandle: handle, bigIntHandle: self.handle)
        
        return MXBuffer(handle: handle)
    }
}

extension BigUint: Equatable {
    public static func == (lhs: BigUint, rhs: BigUint) -> Bool {
        return API.bigIntCompare(lhsHandle: lhs.handle, rhsHandle: rhs.handle) == 0
    }
}

extension BigUint {
    public static func + (left: BigUint, right: BigUint) -> BigUint {
        let handle = getNextHandle()
        API.bigIntAdd(destHandle: handle, lhsHandle: left.handle, rhsHandle: right.handle)
        
        return BigUint(handle: handle)
    }
    
    public static func += (left: inout BigUint, right: BigUint) {
        left = left + right
    }
    
    public static func - (lhs: BigUint, rhs: BigUint) -> BigUint {
        let handle = getNextHandle()
        API.bigIntSub(destHandle: handle, lhsHandle: lhs.handle, rhsHandle: rhs.handle)
        
        return BigUint(handle: handle)
    }
    
    public static func * (lhs: BigUint, rhs: BigUint) -> BigUint {
        let handle = getNextHandle()
        API.bigIntMul(destHandle: handle, lhsHandle: lhs.handle, rhsHandle: rhs.handle)
        
        return BigUint(handle: handle)
    }
    
    public static func / (lhs: BigUint, rhs: BigUint) -> BigUint {
        let handle = getNextHandle()
        API.bigIntDiv(destHandle: handle, lhsHandle: lhs.handle, rhsHandle: rhs.handle)
        
        return BigUint(handle: handle)
    }
    
    public static func % (lhs: BigUint, rhs: BigUint) -> BigUint {
        let handle = getNextHandle()
        API.bigIntMod(destHandle: handle, lhsHandle: lhs.handle, rhsHandle: rhs.handle)
        
        return BigUint(handle: handle)
    }
    
    public static func > (lhs: BigUint, rhs: BigUint) -> Bool {
        let compareResult = API.bigIntCompare(lhsHandle: lhs.handle, rhsHandle: rhs.handle)
        
        return compareResult == 1
    }
    
    public static func <= (lhs: BigUint, rhs: BigUint) -> Bool {
        !(lhs > rhs)
    }
    
    public static func < (lhs: BigUint, rhs: BigUint) -> Bool {
        lhs <= rhs && lhs != rhs
    }
    
    public static func >= (lhs: BigUint, rhs: BigUint) -> Bool {
        lhs > rhs || lhs == rhs
    }
}

extension BigUint: TopDecode {
    public static func topDecode(input: MXBuffer) -> BigUint {
        BigUint(bigEndianBuffer: input)
    }
}

extension BigUint: TopDecodeMulti {}

extension BigUint: NestedDecode {
    public static func depDecode<I>(input: inout I) -> BigUint where I : NestedDecodeInput {
        let buffer = MXBuffer.depDecode(input: &input)
        
        return BigUint.topDecode(input: buffer)
    }
}

extension BigUint: TopEncode {
    public func topEncode<T>(output: inout T) where T: TopEncodeOutput {
        output.setBuffer(buffer: self.toBytesBigEndianBuffer())
    }
}

extension BigUint: NestedEncode {
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        self.toBytesBigEndianBuffer().depEncode(dest: &dest)
    }
}

extension BigUint: ArrayItem {
    public static var payloadSize: Int32 {
        return 4
    }
    
    public static func decodeArrayPayload(payload: MXBuffer) -> BigUint {
        var payloadInput = BufferNestedDecodeInput(buffer: payload)
        
        let handle = Int32(Int.depDecode(input: &payloadInput))
        
        guard !payloadInput.canDecodeMore() else {
            fatalError()
        }
        
        return BigUint(handle: handle)
    }
    
    public func intoArrayPayload() -> MXBuffer {
        return MXBuffer(data: Int(self.handle).asBigEndianBytes())
    }
}

extension BigUint: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value: Int64(value))
    }
}

#if !WASM
extension BigUint: CustomDebugStringConvertible {
    public var debugDescription: String {
        self.stringDescription
    }
}

extension BigUint {
    public var stringDescription: String {
        let handle = getNextHandle()
        API.bigIntToString(bigIntHandle: self.handle, destHandle: handle)
        let utf8Buffer = MXBuffer(handle: handle)
        
        guard let utf8Description = utf8Buffer.utf8Description else {
            fatalError()
        }
        
        return utf8Description
    }
    
    public var hexDescription: String {
        self.toBytesBigEndianBuffer().hexDescription
    }
}
#endif
