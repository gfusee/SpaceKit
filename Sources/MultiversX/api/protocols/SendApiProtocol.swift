public protocol SendApiProtocol {
    mutating func managedTransferValueExecute(
        dstHandle: Int32,
        valueHandle: Int32,
        gasLimit: Int64,
        functionHandle: Int32,
        argumentsHandle: Int32
    ) -> Int32
}
