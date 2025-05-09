#if !WASM
import SpaceKitABI
#endif

public struct BigUint {
    let handle: Int32
    
    public static func max(lhs: BigUint, rhs: BigUint) -> BigUint {
        if lhs >= rhs {
            lhs
        } else {
            rhs
        }
    }
    
    public static func min(lhs: BigUint, rhs: BigUint) -> BigUint {
        if lhs <= rhs {
            lhs
        } else {
            rhs
        }
    }
    
    public init() {
        self.init(value: getZeroedBytes8())
    }
    
    public init(value: Int64) {
        if value < 0 {
            smartContractError(message: "Cannot convert negative Int64 to BigUint.")
        }
        
        let handle = API.getNextHandle()
        API.bigIntSetInt64(destination: handle, value: value)
        self.handle = handle
    }
    
    public init(value: UInt64) {
        self.init(value: value.toBytes8())
    }
    
    public init(value: Int32) {
        if value < 0 {
            smartContractError(message: "Cannot convert negative Int64 to BigUint.")
        }
        
        self.init(value: value.toBytes8())
    }
    
    public init(value: UInt32) {
        self.init(value: value.toBytes8())
    }
    
    public init(value: UInt16) {
        self.init(value: value.toBytes8())
    }
    
    public init(value: UInt8) {
        self.init(value: value.toBytes8())
    }

    package init(value: Bytes8) {
        let buffer = Buffer(data: value)
        
        self = BigUint(bigEndianBuffer: buffer)
    }
    
    public init(bigEndianBuffer: Buffer) {
        let handle = API.getNextHandle()
        let _ = API.bufferToBigIntUnsigned(bufferHandle: bigEndianBuffer.handle, bigIntHandle: handle)
        
        self.handle = handle
    }
    
    init(handle: Int32) {
        self.handle = handle
    }

    public func toBuffer() -> Buffer {
        let destHandle = API.getNextHandle()
        API.bigIntToBuffer(bigIntHandle: self.handle, destHandle: destHandle)

        return Buffer(handle: destHandle)
    }
    
    public func toInt64() -> Int64? {
        return API.bigIntGetInt64(reference: self.handle)
    }
    
    func toBytesBigEndianBuffer() -> Buffer {
        let handle = API.getNextHandle()
        let _ = API.bufferFromBigIntUnsigned(bufferHandle: handle, bigIntHandle: self.handle)
        
        return Buffer(handle: handle)
    }
    
    public func max(other: BigUint) -> BigUint {
        BigUint.max(lhs: self, rhs: other)
    }
    
    public func min(other: BigUint) -> BigUint {
        BigUint.min(lhs: self, rhs: other)
    }
}

extension BigUint: Equatable {
    public static func == (lhs: BigUint, rhs: BigUint) -> Bool {
        return API.bigIntCompare(lhsHandle: lhs.handle, rhsHandle: rhs.handle) == 0
    }
}

extension BigUint {
    public static func + (left: BigUint, right: BigUint) -> BigUint {
        let handle = API.getNextHandle()
        API.bigIntAdd(destHandle: handle, lhsHandle: left.handle, rhsHandle: right.handle)
        
        return BigUint(handle: handle)
    }
    
    public static func += (left: inout BigUint, right: BigUint) {
        left = left + right
    }
    
    public static func - (lhs: BigUint, rhs: BigUint) -> BigUint {
        guard lhs >= rhs else {
            smartContractError(message: Buffer(stringLiteral: BIG_UINT_SUB_NEGATIVE))
        }
        
        let handle = API.getNextHandle()
        API.bigIntSub(destHandle: handle, lhsHandle: lhs.handle, rhsHandle: rhs.handle)
        
        return BigUint(handle: handle)
    }
    
    public static func * (lhs: BigUint, rhs: BigUint) -> BigUint {
        let handle = API.getNextHandle()
        API.bigIntMul(destHandle: handle, lhsHandle: lhs.handle, rhsHandle: rhs.handle)
        
        return BigUint(handle: handle)
    }
    
    public static func / (lhs: BigUint, rhs: BigUint) -> BigUint {
        // TODO: be sure rhs == 0 throws an error on the SpaceVM (critical)
        let handle = API.getNextHandle()
        API.bigIntTDiv(destHandle: handle, lhsHandle: lhs.handle, rhsHandle: rhs.handle)
        
        return BigUint(handle: handle)
    }
    
    public static func % (lhs: BigUint, rhs: BigUint) -> BigUint {
        // TODO: be sure rhs == 0 throws an error on the SpaceVM (critical)
        let handle = API.getNextHandle()
        API.bigIntTMod(destHandle: handle, lhsHandle: lhs.handle, rhsHandle: rhs.handle)
        
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
    public init(topDecode input: Buffer) {
        self = Self(bigEndianBuffer: input)
    }
}

extension BigUint: TopDecodeMulti {}

extension BigUint: NestedDecode {
    public init(depDecode input: inout some NestedDecodeInput) {
        let buffer = Buffer(depDecode: &input)
        
        self = Self(topDecode: buffer)
    }
}

extension BigUint: TopEncode {
    @inline(__always)
    public func topEncode<EncodeOutput>(output: inout EncodeOutput) where EncodeOutput: TopEncodeOutput {
        output.setBuffer(buffer: self.toBytesBigEndianBuffer())
    }
}

extension BigUint: TopEncodeMulti {}

extension BigUint: NestedEncode {
    @inline(__always)
    public func depEncode<O>(dest: inout O) where O : NestedEncodeOutput {
        self.toBytesBigEndianBuffer().depEncode(dest: &dest)
    }
}

extension BigUint: ArrayItem {
    public static var payloadSize: Int32 {
        return 4
    }
    
    public static func decodeArrayPayload(payload: Buffer) -> BigUint {
        var payloadInput = BufferNestedDecodeInput(buffer: payload)
        
        let handle = Int32(Int(depDecode: &payloadInput))
        
        guard !payloadInput.canDecodeMore() else {
            fatalError()
        }
        
        return BigUint(handle: handle)
    }
    
    public func intoArrayPayload() -> Buffer {
        return Buffer(data: self.handle.toBytes4())
    }
}

#if !WASM
extension BigUint: ABITypeExtractor {
    public static var _abiTypeName: String {
        "BigUint"
    }
}
#endif

extension BigUint: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        #if WASM
        self.init(value: Int32(value).toBytes8())
        #else
        self.init(value: Int64(value).toBytes8())
        #endif
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
        let handle = API.getNextHandle()
        API.bigIntToString(bigIntHandle: self.handle, destHandle: handle)
        let utf8Buffer = Buffer(handle: handle)
        
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
