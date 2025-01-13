fileprivate let ESDT_SYSTEM_SC_ADDRESS_BYTES: Bytes32 = (0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 255, 255)

// TODO: add caching when needed (and turn related function into computed variables)

public struct Blockchain {
    private init() {}
    
    public static func getSCAddress() -> Address {
        let handle = API.getNextHandle()
        
        API.managedSCAddress(resultHandle: handle)
        
        return Address(handle: handle)
    }
    
    public static func getShardOfAddress(address: Address) -> UInt32 {
        var addressBytes = address.buffer.to32BytesStackArray()
        
        return toBigEndianUInt32(from: API.getShardOfAddress(addressPtr: &addressBytes).toBytes4())
        // TODO: super tricky, we should ensure it works
    }
    
    public static func getBlockTimestamp() -> UInt64 {
        // TODO: add tests
        return toBigEndianUInt64(from: API.getBlockTimestamp().toBytes8()) // TODO: super tricky, we should ensure it works
    }
    
    public static func getBlockRound() -> UInt64 { // TODO: add tests
        return toBigEndianUInt64(from: API.getBlockRound().toBytes8()) // TODO: super tricky, we should ensure it works
    }
    
    public static func getBlockEpoch() -> UInt64 { // TODO: add tests
        return toBigEndianUInt64(from: API.getBlockEpoch().toBytes8()) // TODO: super tricky, we should ensure it works
    }
    
    public static func getBlockRandomSeed() -> Buffer {
        // TODO: add tests
        let result = Buffer()
        
        API.managedGetBlockRandomSeed(resultHandle: result.handle)
        
        return result
    }
    
    public static func getBalance(
        address: Address
    ) -> BigUint {
        var addressBytes = address.buffer.to32BytesStackArray()
        
        let destHandle = API.getNextHandle()
        
        API.bigIntGetExternalBalance(
            addressPtr: &addressBytes,
            dest: destHandle
        )
        
        return BigUint(handle: destHandle)
    }
    
    public static func getESDTBalance(
        address: Address,
        tokenIdentifier: Buffer,
        nonce: UInt64
    ) -> BigUint {
        var addressBytes = address.buffer.to32BytesStackArray()
        var tokenIdentifierBytes = tokenIdentifier.to32BytesStackArray()
        
        let destHandle = API.getNextHandle()
        
        API.bigIntGetESDTExternalBalance(
            addressPtr: &addressBytes,
            tokenIDOffset: &tokenIdentifierBytes,
            tokenIDLen: tokenIdentifier.count,
            nonce: toBigEndianInt64(from: nonce.toBytes8()), // TODO: super tricky, we should ensure it works
            dest: destHandle
        )
        
        return BigUint(handle: destHandle)
    }
    
    public static func getSCBalance() -> BigUint {
        Blockchain
            .getBalance(address: Blockchain.getSCAddress())
    }
    
    public static func getSCBalance(
        tokenIdentifier: Buffer,
        nonce: UInt64
    ) -> BigUint {
        Blockchain
            .getESDTBalance(
                address: Blockchain.getSCAddress(),
                tokenIdentifier: tokenIdentifier,
                nonce: nonce
            )
    }

    public static func getOwner() -> Address {
        // TODO: add caching
        let resultHandle = API.getNextHandle()
        
        API.managedOwnerAddress(resultHandle: resultHandle)
        
        return Address(handle: resultHandle)
    }
    
    public static func getGasLeft() -> UInt64 {
        return toBigEndianUInt64(from: API.getGasLeft().toBytes8()) // TODO: super tricky, we should ensure it works
    }
    
    private static func getEGLDOrESDTBalance(
        address: Address,
        tokenIdentifier: Buffer,
        nonce: UInt64
    ) -> BigUint {
        switch tokenIdentifier {
        case "EGLD": // TODO: no hardcoded EGLD identifier
            Blockchain.getBalance(address: address)
        default:
            Blockchain.getEGLDOrESDTBalance(address: address, tokenIdentifier: tokenIdentifier, nonce: nonce)
        }
    }
    
    public static func getESDTLocalRoles(tokenIdentifier: Buffer) -> EsdtLocalRoles { // TODO: use TokenIdentifier type
        let flags = API.getESDTLocalRoles(tokenIdHandle: tokenIdentifier.handle)
        
        return EsdtLocalRoles(flags: UInt64(flags))
    }
    
    public static func deploySCFromSource(
        gas: UInt64,
        sourceAddress: Address,
        codeMetadata: CodeMetadata,
        value: BigUint = 0,
        arguments: ArgBuffer = ArgBuffer()
    ) -> (newAddress: Address, results: Vector<Buffer>) {
        // TODO: add tests
        let resultAddress = Address()
        let resultBuffers: Vector<Buffer> = Vector()
        
        let codeMetadataBuffer = Buffer(data: codeMetadata.getFlag().asBigEndianBytes())
        
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
    ) -> Vector<Buffer> {
        let resultBuffers: Vector<Buffer> = Vector()
        let codeMetadataBuffer = Buffer(data: codeMetadata.getFlag().asBigEndianBytes())
        
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
        tokenIdentifier: Buffer, // TODO: use TokenIdentifier type when implemented
        nonce: UInt64,
        amount: BigUint
    ) {
        if nonce == 0 {
            var argBuffer = ArgBuffer()
            argBuffer.pushArg(arg: tokenIdentifier)
            argBuffer.pushArg(arg: amount)
            
            let _: IgnoreValue = ContractCall(
                receiver: Blockchain.getSCAddress(),
                endpointName: Buffer(stringLiteral: ESDT_LOCAL_MINT_FUNC_NAME),
                argBuffer: argBuffer
            ).call()
        } else {
            var argBuffer = ArgBuffer()
            argBuffer.pushArg(arg: tokenIdentifier)
            argBuffer.pushArg(arg: nonce)
            argBuffer.pushArg(arg: amount)
            
            let _: IgnoreValue = ContractCall(
                receiver: Blockchain.getSCAddress(),
                endpointName: Buffer(stringLiteral: ESDT_NFT_ADD_QUANTITY_FUNC_NAME),
                argBuffer: argBuffer
            ).call()
        }
    }
    
    public static func createNft<T: TopEncode>(
        tokenIdentifier: Buffer,
        amount: BigUint,
        name: Buffer,
        royalties: BigUint,
        hash: Buffer,
        attributes: T,
        uris: Vector<Buffer>
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
            argBuffer.pushArg(arg: Buffer())
        } else {
            // Rust framework's note: The API function has the last argument as variadic,
            // so we top-encode each and send as separate argument
            
            uris.forEach { uri in
                argBuffer.pushArg(arg: uri)
            }
        }
        
        return ContractCall(
            receiver: Blockchain.getSCAddress(),
            endpointName: Buffer(stringLiteral: ESDT_NFT_CREATE_FUNC_NAME),
            argBuffer: argBuffer
        ).call(
            gas: Blockchain.getGasLeft(),
            value: 0
        )
    }
    
    private static func issueToken(
        tokenType: TokenType,
        tokenDisplayName: Buffer,
        tokenTicker: Buffer,
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
            endpointName: Buffer(stringLiteral: endpointName),
            argBuffer: argBuffer
        )
        
        return AsyncContractCall(contractCall: contractCall)
    }
    
    public static func issueFungibleToken(
        tokenDisplayName: Buffer,
        tokenTicker: Buffer,
        initialSupply: BigUint,
        properties: FungibleTokenProperties
    ) -> AsyncContractCall {
        // TODO: add tests
        Blockchain.issueToken(
            tokenType: .fungible,
            tokenDisplayName: tokenDisplayName,
            tokenTicker: tokenTicker,
            initialSupply: initialSupply,
            properties: TokenProperties(
                numDecimals: properties.numDecimals,
                canFreeze: properties.canFreeze,
                canWipe: properties.canWipe,
                canPause: properties.canPause,
                canTransferCreateRole: false,
                canMint: properties.canMint,
                canBurn: properties.canBurn,
                canChangeOwner: properties.canChangeOwner,
                canUpgrade: properties.canUpgrade,
                canAddSpecialRoles: properties.canAddSpecialRoles
            )
        )
    }

    public static func issueNonFungibleToken(
        tokenDisplayName: Buffer,
        tokenTicker: Buffer,
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
    
    public static func issueSemiFungibleToken(
        tokenDisplayName: Buffer,
        tokenTicker: Buffer,
        properties: SemiFungibleTokenProperties
    ) -> AsyncContractCall {
        // TODO: add tests
        return Blockchain.issueToken(
            tokenType: .semiFungible,
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
    
    public static func registerMetaEsdt(
        tokenDisplayName: Buffer,
        tokenTicker: Buffer,
        properties: MetaTokenProperties
    ) -> AsyncContractCall {
        // TODO: add tests
        return Blockchain.issueToken(
            tokenType: .meta,
            tokenDisplayName: tokenDisplayName,
            tokenTicker: tokenTicker,
            initialSupply: 0,
            properties: TokenProperties(
                numDecimals: properties.numDecimals,
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
        tokenIdentifier: Buffer,
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
            endpointName: "setSpecialRole",
            argBuffer: argBuffer
        )
        
        return AsyncContractCall(contractCall: contractCall)
    }
    
    public static func updateNftAttributes<T: TopEncode>(
        tokenIdentifier: Buffer,
        nonce: UInt64,
        attributes: T
    ) {
        var argBuffer = ArgBuffer()
        argBuffer.pushArg(arg: tokenIdentifier)
        argBuffer.pushArg(arg: nonce)
        
        var attributesEncoded = Buffer()
        attributes.topEncode(output: &attributesEncoded)
        argBuffer.pushArg(arg: attributesEncoded)
        
        let _: IgnoreValue = ContractCall(
            receiver: Blockchain.getSCAddress(),
            endpointName: Buffer(stringLiteral: ESDT_NFT_UPDATE_ATTRIBUTES_FUNC_NAME),
            argBuffer: argBuffer
        ).call()
    }
    
    public static func getTokenData(
        address: Address,
        tokenIdentifier: Buffer,
        nonce: UInt64
    ) -> TokenData {
        let value = BigUint()
        let properties = Buffer()
        let hash = Buffer()
        let name = Buffer()
        let attributes = Buffer()
        let creatorRaw = Buffer()
        let royalties = BigUint()
        let urisRaw = Buffer()
        
        API.managedGetESDTTokenData(
            addressHandle: address.buffer.handle,
            tokenIDHandle: tokenIdentifier.handle,
            nonce: toBigEndianInt64(from: nonce.toBytes8()), // TODO: super tricky, we should ensure it works
            valueHandle: value.handle,
            propertiesHandle: properties.handle,
            hashHandle: hash.handle,
            nameHandle: name.handle,
            attributesHandle: attributes.handle,
            creatorHandle: creatorRaw.handle,
            royaltiesHandle: royalties.handle,
            urisHandle: urisRaw.handle
        )
        
        let tokenType = if nonce == 0 {
            TokenType.fungible
        } else {
            TokenType.nonFungible
        }
        
        let creator = if creatorRaw.isEmpty {
            Address()
        } else {
            Address(buffer: creatorRaw)
        }
        
        let propertiesBytes = properties.toBigEndianBytes8() // The array contains 2 elements, therefore only the 7th and 8th ones matter
        
        let isFrozen = propertiesBytes.6 > 0 // This is how it is implemented in the Rust SDK
        
        return TokenData(
            tokenType: tokenType,
            amount: value,
            frozen: isFrozen,
            hash: hash,
            name: name,
            attributes: attributes,
            creator: creator,
            royaties: royalties,
            uris: Vector(handle: urisRaw.handle)
        )
    }
    
    public static func getTokenAttributes<T: TopDecode>(
        tokenIdentifier: Buffer,
        nonce: UInt64
    ) -> T {
        let rawAttributes = Blockchain.getTokenData(
            address: Blockchain.getSCAddress(),
            tokenIdentifier: tokenIdentifier,
            nonce: nonce
        ).attributes
        
        return T(topDecode: rawAttributes)
    }
    
    public static func getTokenRoyalties(
        tokenIdentifier: Buffer,
        nonce: UInt64
    ) -> BigUint {
        Blockchain.getTokenData(
            address: Blockchain.getSCAddress(),
            tokenIdentifier: tokenIdentifier,
            nonce: nonce
        ).royaties
    }
    
    public static func modifyTokenRoyalties(
        tokenIdentifier: Buffer,
        nonce: UInt64,
        royalties: UInt64
    ) {
        var argBuffer = ArgBuffer()
        
        argBuffer.pushArg(arg: tokenIdentifier)
        argBuffer.pushArg(arg: nonce)
        argBuffer.pushArg(arg: royalties)

        let _: IgnoreValue = ContractCall(
            receiver: Blockchain.getSCAddress(),
            endpointName: Buffer(stringLiteral: ESDT_MODIFY_ROYALTIES_FUNC_NAME),
            argBuffer: argBuffer
        ).call()
    }
}
