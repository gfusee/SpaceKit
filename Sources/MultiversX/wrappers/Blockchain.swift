public struct Blockchain {
    private init() {}
    
    public static func getSCAddress() -> Address {
        let handle = getNextHandle()
        
        API.managedSCAddress(resultHandle: handle)
        
        return Address(handle: handle)
    }
    
    public static func getBlockTimestamp() -> UInt64 {
        // TODO: add tests
        return toBigEndianUInt64(from: API.getBlockTimestamp().toBytes8()) // TODO: super tricky, we should ensure it works
    }
    
    public static func getBlockRound() -> UInt64 { // TODO: add tests
        return toBigEndianUInt64(from: API.getBlockRound().toBytes8()) // TODO: super tricky, we should ensure it works
    }
    
    public static func getBalance(
        address: Address
    ) -> BigUint {
        var addressBytes = address.buffer.to32BytesStackArray()
        
        let destHandle = getNextHandle()
        
        API.bigIntGetExternalBalance(
            addressPtr: &addressBytes,
            dest: destHandle
        )
        
        return BigUint(handle: destHandle)
    }
    
    public static func getESDTBalance(
        address: Address,
        tokenIdentifier: MXBuffer,
        nonce: UInt64
    ) -> BigUint {
        var addressBytes = address.buffer.to32BytesStackArray()
        var tokenIdentifierBytes = tokenIdentifier.to32BytesStackArray()
        
        let destHandle = getNextHandle()
        
        API.bigIntGetESDTExternalBalance(
            addressPtr: &addressBytes,
            tokenIDOffset: &tokenIdentifierBytes,
            tokenIDLen: tokenIdentifier.count,
            nonce: toBigEndianInt64(from: API.getGasLeft().toBytes8()), // TODO: super tricky, we should ensure it works
            dest: destHandle
        )
        
        return BigUint(handle: destHandle)
    }

    public static func getOwner() -> Address {
        // TODO: add caching
        let resultHandle = getNextHandle()
        
        API.managedOwnerAddress(resultHandle: resultHandle)
        
        return Address(handle: resultHandle)
    }
    
    public static func getGasLeft() -> UInt64 {
        return toBigEndianUInt64(from: API.getGasLeft().toBytes8()) // TODO: super tricky, we should ensure it works
    }
    
    private static func getEGLDOrESDTBalance(
        address: Address,
        tokenIdentifier: MXBuffer,
        nonce: UInt64
    ) -> BigUint {
        switch tokenIdentifier {
        case "EGLD": // TODO: no hardcoded EGLD identifier
            Blockchain.getBalance(address: address)
        default:
            Blockchain.getEGLDOrESDTBalance(address: address, tokenIdentifier: tokenIdentifier, nonce: nonce)
        }
    }
}
