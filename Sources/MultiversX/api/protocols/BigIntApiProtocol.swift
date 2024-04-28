public protocol BigIntApiProtocol {
    mutating func bigIntSetInt64Value(destination: Int32, value: Int64)
    mutating func bigIntToBuffer(bigIntHandle: Int32, destHandle: Int32)
    mutating func bigIntCompare(lhsHandle: Int32, rhsHandle: Int32) -> Int32
    mutating func bigIntAdd(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32)
    mutating func bigIntSub(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32)
    mutating func bigIntMul(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32)
    mutating func bigIntDiv(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32)
    mutating func bigIntMod(destHandle: Int32, lhsHandle: Int32, rhsHandle: Int32)
}
