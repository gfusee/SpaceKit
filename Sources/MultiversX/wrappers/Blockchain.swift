public struct Blockchain {
    private init() {}
    
    public static func getSCAddress() -> Address {
        let handle = getNextHandle()
        
        API.managedSCAddress(resultHandle: handle)
        
        return Address(handle: handle)
    }
    
    public static func getBlockTimestamp() -> UInt64 { // TODO: add tests
        return UInt64(API.getBlockTimestamp()) // TODO: is this cast fine?
    }
    
    public static func getSCBalance(
        tokenIdentifier: MXBuffer, // TODO: use TokenIdentifier type once implemented
        nonce: UInt64
    ) -> BigUint {
        let addressBytes = self.getSCAddress().buffer.to32BytesStackArray()
        let tokenIdentifierBytes = tokenIdentifier.to32BytesStackArray()
        
        let destHandle = getNextHandle()
        
        API.bigIntGetESDTExternalBalance(
            addressPtr: addressBytes,
            tokenIDOffset: tokenIdentifierBytes,
            tokenIDLen: tokenIdentifier.count,
            nonce: Int64(nonce), // TODO: Is this cast safe?
            dest: destHandle
        )
        
        return BigUint(handle: destHandle)
    }
    
    public static func getGasLeft() -> UInt64 {
        return UInt64(API.getGasLeft()) // TODO: Is this cast safe?
    }
}
