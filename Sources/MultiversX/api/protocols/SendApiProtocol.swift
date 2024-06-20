public protocol SendApiProtocol {
    mutating func managedMultiTransferESDTNFTExecute(
        dstHandle: Int32,
        tokenTransfersHandle: Int32,
        gasLimit: Int64,
        functionHandle: Int32,
        argumentsHandle: Int32
    ) -> Int32
    
    mutating func managedTransferValueExecute(
        dstHandle: Int32,
        valueHandle: Int32,
        gasLimit: Int64,
        functionHandle: Int32,
        argumentsHandle: Int32
    ) -> Int32
}
