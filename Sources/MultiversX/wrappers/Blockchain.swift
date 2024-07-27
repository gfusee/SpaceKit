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
    
    public static func getBlockRound() -> UInt64 { // TODO: add tests
        return UInt64(API.getBlockRound()) // TODO: is this cast fine?
    }
    
    public static func getBalance(
        address: Address
    ) -> BigUint {
        let addressBytes = address.buffer.to32BytesStackArray()
        
        let destHandle = getNextHandle()
        
        API.bigIntGetExternalBalance(
            addressPtr: addressBytes,
            dest: destHandle
        )
        
        return BigUint(handle: destHandle)
    }
    
    public static func getESDTBalance(
        address: Address,
        tokenIdentifier: MXBuffer,
        nonce: UInt64
    ) -> BigUint {
        let addressBytes = address.buffer.to32BytesStackArray()
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

    public static func getOwner() -> Address {
        // TODO: add caching
        let resultHandle = getNextHandle()
        
        API.managedOwnerAddress(resultHandle: resultHandle)
        
        return Address(handle: resultHandle)
    }
    
    public static func getGasLeft() -> UInt64 {
        return UInt64(API.getGasLeft()) // TODO: Is this cast safe?
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
