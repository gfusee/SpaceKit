fileprivate let ESDT_LOCAL_MINT_FUNC_NAME: StaticString = "ESDTLocalMint"
fileprivate let ESDT_NFT_ADD_QUANTITY_FUNC_NAME: StaticString = "ESDTNFTAddQuantity"
fileprivate let ESDT_NFT_CREATE_FUNC_NAME: StaticString = "ESDTNFTCreate"

fileprivate let ISSUE_FUNGIBLE_ENDPOINT_NAME: StaticString = "issue"
fileprivate let ISSUE_NON_FUNGIBLE_ENDPOINT_NAME: StaticString = "issueNonFungible"
fileprivate let ISSUE_SEMI_FUNGIBLE_ENDPOINT_NAME: StaticString = "issueSemiFungible"
fileprivate let REGISTER_META_ESDT_ENDPOINT_NAME: StaticString = "registerMetaESDT"
fileprivate let ISSUE_AND_SET_ALL_ROLES_ENDPOINT_NAME: StaticString = "registerAndSetAllRoles"

fileprivate let ESDT_SYSTEM_SC_ADDRESS_BYTES: Bytes32 = (0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 255, 255)

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
    
    public static func createNft<T: TopEncode>(
        tokenIdentifier: MXBuffer,
        amount: BigUint,
        name: MXBuffer,
        royalties: BigUint,
        hash: MXBuffer,
        attributes: T,
        uris: MXArray<MXBuffer>
    ) -> UInt64 {
        var argBuffer = ArgBuffer()
        argBuffer.pushSingleValue(arg: tokenIdentifier)
        argBuffer.pushSingleValue(arg: amount)
        argBuffer.pushSingleValue(arg: name)
        argBuffer.pushSingleValue(arg: royalties)
        argBuffer.pushSingleValue(arg: hash)
        argBuffer.pushSingleValue(arg: attributes)
        
        if uris.isEmpty {
            // Rust framework's note: at least one URI is required, so we push an empty one
            argBuffer.pushArg(arg: MXBuffer())
        } else {
            // Rust framework's note: The API function has the last argument as variadic,
            // so we top-encode each and send as separate argument
            
            uris.forEach { uri in
                argBuffer.pushArg(arg: uri)
            }
        }
        
        return ContractCall(
            receiver: Blockchain.getSCAddress(),
            endpointName: MXBuffer(stringLiteral: ESDT_NFT_CREATE_FUNC_NAME),
            argBuffer: argBuffer
        ).call(
            gas: Blockchain.getGasLeft(),
            value: 0
        )
    }
    
    private static func issueToken(
        tokenType: TokenType,
        tokenDisplayName: MXBuffer,
        tokenTicker: MXBuffer,
        initialSupply: BigUint,
        properties: TokenProperties
    ) -> AsyncContractCall {
        // TODO: add tests
        let esdtSystemScAddress = Address(bytes: ESDT_SYSTEM_SC_ADDRESS_BYTES)
        
        let endpointName: StaticString = switch tokenType {
        case .fungible:
            ISSUE_FUNGIBLE_ENDPOINT_NAME
        case .nonFungible:
            ISSUE_NON_FUNGIBLE_ENDPOINT_NAME
        case .semiFungible:
            ISSUE_SEMI_FUNGIBLE_ENDPOINT_NAME
        case .meta:
            REGISTER_META_ESDT_ENDPOINT_NAME
        case .invalid:
            ""
        }
        
        var argBuffer = ArgBuffer()
        
        argBuffer.pushArg(arg: tokenDisplayName)
        argBuffer.pushArg(arg: tokenTicker)
        
        if tokenType == .fungible {
            argBuffer.pushArg(arg: initialSupply)
            argBuffer.pushArg(arg: properties.numDecimals)
        } else if tokenType == .meta {
            argBuffer.pushArg(arg: properties.numDecimals)
        }
        
        var tokenPropArgs = TokenPropertiesArgument(
            canFreeze: properties.canFreeze,
            canWipe: properties.canWipe,
            canPause: properties.canPause,
            canTransferCreateRole: nil,
            canMint: nil,
            canBurn: nil,
            canChangeOwner: properties.canChangeOwner,
            canUpgrade: properties.canUpgrade,
            canAddSpecialRoles: properties.canAddSpecialRoles
        )
        
        if tokenType == .fungible {
            tokenPropArgs.canMint = properties.canMint
            tokenPropArgs.canBurn = properties.canBurn
        } else {
            tokenPropArgs.canTransferCreateRole = properties.canTransferCreateRole
        }
        
        tokenPropArgs.multiEncode(output: &argBuffer)
        
        let contractCall = ContractCall(
            receiver: esdtSystemScAddress,
            endpointName: MXBuffer(stringLiteral: endpointName),
            argBuffer: argBuffer
        )
        
        return AsyncContractCall(contractCall: contractCall)
    }
    
    public static func issueNonFungibleToken(
        tokenDisplayName: MXBuffer,
        tokenTicker: MXBuffer,
        properties: NonFungibleTokenProperties
    ) -> AsyncContractCall {
        // TODO: add tests
        return Blockchain.issueToken(
            tokenType: .nonFungible,
            tokenDisplayName: tokenDisplayName,
            tokenTicker: tokenTicker,
            initialSupply: 0,
            properties: TokenProperties(
                numDecimals: 0,
                canFreeze: properties.canFreeze,
                canWipe: properties.canWipe,
                canPause: properties.canPause,
                canTransferCreateRole: properties.canTransferCreateRole,
                canMint: false,
                canBurn: false,
                canChangeOwner: properties.canChangeOwner,
                canUpgrade: properties.canUpgrade,
                canAddSpecialRoles: properties.canAddSpecialRoles
            )
        )
    }
    
    public static func setTokenRoles(
        for address: Address,
        tokenIdentifier: MXBuffer,
        roles: EsdtLocalRoles
    ) -> AsyncContractCall {
        var argBuffer = ArgBuffer()
        
        argBuffer.pushArg(arg: tokenIdentifier)
        argBuffer.pushArg(arg: address)
        
        roles.forEachFlag { flag in
            argBuffer.pushArg(arg: flag.getRoleName())
        }
        
        let contractCall = ContractCall(
            receiver: Address(bytes: ESDT_SYSTEM_SC_ADDRESS_BYTES),
            endpointName: "setSpecialRoles",
            argBuffer: argBuffer
        )
        
        return AsyncContractCall(contractCall: contractCall)
    }
}
