public protocol BlockchainApiProtocol {
    mutating func managedSCAddress(resultHandle: Int32)
    
    mutating func getBlockTimestamp() -> Int64
    
    mutating func getBlockRound() -> Int64
    
    mutating func getBlockEpoch() -> Int64
    
    mutating func managedGetBlockRandomSeed(resultHandle: Int32)
    
    mutating func managedGetOriginalTxHash(resultHandle: Int32)
    
    mutating func bigIntGetExternalBalance(addressPtr: UnsafeRawPointer, dest: Int32)
    
    mutating func bigIntGetESDTExternalBalance(
        addressPtr: UnsafeRawPointer,
        tokenIDOffset: UnsafeRawPointer,
        tokenIDLen: Int32,
        nonce: Int64,
        dest: Int32
    )
    
    mutating func getCaller(resultOffset: UnsafeRawPointer)
    
    mutating func managedOwnerAddress(resultHandle: Int32)

    mutating func getGasLeft() -> Int64
    
    mutating func getESDTLocalRoles(tokenIdHandle: Int32) -> Int64
    
    mutating func getShardOfAddress(addressPtr: UnsafeRawPointer) -> Int32
}
