public protocol BigIntApiProtocol {
    mutating func bigIntSetInt64Value(destination: Int32, value: Int64)
    mutating func bigIntToBuffer(bigIntHandle: Int32, destHandle: Int32)
    mutating func bigIntCompare(lhsHandle: Int32, rhsHandle: Int32) -> Int32
}
