public struct BigUint {
    let handle: Int32

    public init(value: Int64) {
        let handle = getNextHandle()
        BIGINT_API.bigIntSetInt64Value(destination: handle, value: value)
        self.handle = handle
    }

    public func toString() -> Buffer {
        let destHandle = getNextHandle()
        BIGINT_API.bigIntToBuffer(bigIntHandle: self.handle, destHandle: destHandle)

        return Buffer(handle: destHandle)
    }
}

extension BigUint: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value: Int64(value))
    }
}

