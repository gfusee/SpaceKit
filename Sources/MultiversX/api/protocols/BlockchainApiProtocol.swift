public protocol BlockchainApiProtocol {
    mutating func managedSCAddress(resultHandle: Int32)
    
    mutating func getBlockTimestamp() -> Int64
    
    mutating func bigIntGetESDTExternalBalance(
        addressPtr: UnsafeRawPointer,
        tokenIDOffset: UnsafeRawPointer,
        tokenIDLen: Int32,
        nonce: Int64,
        dest: Int32
    )
    
    mutating func getCaller(resultOffset: UnsafeRawPointer)
    
    mutating func getGasLeft() -> Int64
}
