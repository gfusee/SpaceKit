public protocol BlockchainApiProtocol {
    mutating func managedSCAddress(resultHandle: Int32)
    
    mutating func getBlockTimestamp() -> Int64
}
