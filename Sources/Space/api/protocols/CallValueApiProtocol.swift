public protocol CallValueApiProtocol {
    mutating func bigIntGetCallValue(dest: Int32)
    mutating func managedGetMultiESDTCallValue(resultHandle: Int32)
}
