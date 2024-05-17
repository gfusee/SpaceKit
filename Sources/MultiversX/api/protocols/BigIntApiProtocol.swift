public protocol BigIntApiProtocol {
    mutating func bigIntSetInt64(destination: Int32, value: Int64)
    mutating func bigIntIsInt64(reference: Int32) -> Int32
    mutating func bigIntGetInt64Unsafe(reference: Int32) -> Int64
    mutating func bigIntGetInt64(reference: Int32) -> Int64?
    mutating func bigIntToBuffer(bigIntHandle: Int32, destHandle: Int32)
    mutating func bigIntCompare(lhsHandle: Int32, rhsHandle: Int32) -> Int32
    mutating func bigIntAdd(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32)
    mutating func bigIntSub(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32)
    mutating func bigIntMul(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32)
    mutating func bigIntDiv(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32)
    mutating func bigIntMod(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32)
    mutating func bigIntToString(bigIntHandle: Int32, destHandle: Int32)
}

extension BigIntApiProtocol {
    public mutating func bigIntGetInt64(reference: Int32) -> Int64? {
        let isInt64Result = self.bigIntIsInt64(reference: reference)
        
        if isInt64Result > 0 {
            return self.bigIntGetInt64Unsafe(reference: reference)
        } else {
            return nil
        }
    }
}
