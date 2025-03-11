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
    
    mutating func managedExecuteOnDestContext(
        gas: Int64,
        addressHandle: Int32,
        valueHandle: Int32,
        functionHandle: Int32,
        argumentsHandle: Int32,
        resultHandle: Int32
    ) -> Int32
    
    mutating func managedCreateAsyncCall(
        dstHandle: Int32,
        valueHandle: Int32,
        functionHandle: Int32,
        argumentsHandle: Int32,
        successOffset: UnsafeRawPointer,
        successLength: Int32,
        errorOffset: UnsafeRawPointer,
        errorLength: Int32,
        gas: Int64,
        extraGasForCallback: Int64,
        callbackClosureHandle: Int32
    ) -> Int32
    
    mutating func managedDeployFromSourceContract(
        gas: Int64,
        valueHandle: Int32,
        addressHandle: Int32,
        codeMetadataHandle: Int32,
        argumentsHandle: Int32,
        resultAddressHandle: Int32,
        resultHandle: Int32
    ) -> Int32
    
    mutating func cleanReturnData()
    
    mutating func isSmartContract(addressPtr: UnsafeRawPointer) -> Int32
}
