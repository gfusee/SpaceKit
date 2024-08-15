fileprivate let ESDT_LOCAL_MINT_FUNC_NAME: StaticString = "ESDTLocalMint"
fileprivate let ESDT_NFT_ADD_QUANTITY_FUNC_NAME: StaticString = "ESDTNFTAddQuantity"

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
    
    public static func getESDTLocalRoles(tokenIdentifier: MXBuffer) -> EsdtLocalRoles { // TODO: use TokenIdentifier type
        let flags = API.getESDTLocalRoles(tokenIdHandle: tokenIdentifier.handle)
        
        return EsdtLocalRoles(flags: flags)
    }
    
    public static func deploySCFromSource(
        gas: UInt64,
        sourceAddress: Address,
        codeMetadata: CodeMetadata,
        value: BigUint = 0,
        arguments: ArgBuffer = ArgBuffer()
    ) -> (newAddress: Address, results: MXArray<MXBuffer>) {
        // TODO: add tests
        let resultAddress = Address()
        let resultBuffers: MXArray<MXBuffer> = MXArray()
        
        let codeMetadataBuffer = MXBuffer(data: codeMetadata.getFlag().asBigEndianBytes())
        
        let _ = API.managedDeployFromSourceContract(
            gas: Int64(gas), // TODO: Is this cast safe?
            valueHandle: value.handle,
            addressHandle: sourceAddress.buffer.handle,
            codeMetadataHandle: codeMetadataBuffer.handle,
            argumentsHandle: arguments.buffers.buffer.handle,
            resultAddressHandle: resultAddress.buffer.handle,
            resultHandle: resultBuffers.buffer.handle
        )
        
        return (newAddress: resultAddress, results: resultBuffers)
    }
    
    public static func upgradeSCFromSource(
        contractAddress: Address,
        gas: UInt64,
        sourceAddress: Address,
        codeMetadata: CodeMetadata,
        value: BigUint = 0,
        arguments: ArgBuffer = ArgBuffer()
    ) -> MXArray<MXBuffer> {
        let resultBuffers: MXArray<MXBuffer> = MXArray()
        let codeMetadataBuffer = MXBuffer(data: codeMetadata.getFlag().asBigEndianBytes())
        
        let _ = API.managedUpgradeFromSourceContract(
            dstHandle: contractAddress.buffer.handle,
            gas: Int64(gas), // TODO: Is this cast safe?
            valueHandle: value.handle,
            addressHandle: sourceAddress.buffer.handle,
            codeMetadataHandle: codeMetadataBuffer.handle,
            argumentsHandle: arguments.buffers.buffer.handle,
            resultHandle: resultBuffers.buffer.handle
        )
        
        return resultBuffers
    }
    
    public static func mintTokens(
        tokenIdentifier: MXBuffer, // TODO: use TokenIdentifier type when implemented
        nonce: UInt64,
        amount: BigUint
    ) {
        if nonce == 0 {
            var argBuffer = ArgBuffer()
            argBuffer.pushArg(arg: tokenIdentifier)
            argBuffer.pushArg(arg: amount)
            
            let _: IgnoreValue = ContractCall(
                receiver: Blockchain.getSCAddress(),
                endpointName: MXBuffer(stringLiteral: ESDT_LOCAL_MINT_FUNC_NAME),
                argBuffer: argBuffer
            ).call()
        } else {
            var argBuffer = ArgBuffer()
            argBuffer.pushArg(arg: tokenIdentifier)
            argBuffer.pushArg(arg: nonce)
            argBuffer.pushArg(arg: amount)
            
            let _: IgnoreValue = ContractCall(
                receiver: Blockchain.getSCAddress(),
                endpointName: MXBuffer(stringLiteral: ESDT_NFT_ADD_QUANTITY_FUNC_NAME),
                argBuffer: argBuffer
            ).call()
        }
    }
}
