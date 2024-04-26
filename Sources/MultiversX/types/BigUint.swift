public struct BigUint {
    let handle: Int32
    
    public init() {
        self.init(value: 0)
    }

    public init(value: Int64) {
        let handle = getNextHandle()
        API.bigIntSetInt64Value(destination: handle, value: value)
        self.handle = handle
    }

    public func toBuffer() -> MXBuffer {
        let destHandle = getNextHandle()
        API.bigIntToBuffer(bigIntHandle: self.handle, destHandle: destHandle)

        return MXBuffer(handle: destHandle)
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

extension BigUint: TopEncode {
    public func topEncode<T>(output: inout T) where T : TopEncodeOutput {
        output.setBuffer(buffer: self.toBytesBigEndianBuffer())
    }
}

extension BigUint: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value: Int64(value))
    }
}

