#if !WASM
@Controller public struct ESDTSystemContract {
    @Storage(key: "lastIssuedTokenIdentifier") public var lastIssuedTokenIdentifier: Buffer
    
    public mutating func issue(
        tokenDisplayName: Buffer,
        tokenTicker: Buffer,
        initialSupply: BigUint,
        numDecimals: UInt32,
        tokenProperties: MultiValueEncoded<Buffer>
    ) -> OptionalArgument<Buffer> {
        guard Message.egldValue == self.getIssuanceCost() else {
            smartContractError(message: "Not enough payment.") // TODO: use the same error as the WASM VM
        }
        
        self.validateToken(
            tokenDisplayName: tokenDisplayName,
            tokenTicker: tokenTicker
        )
        
        let tokenProperties = self.computeTokenProperties(
            numDecimals: numDecimals,
            tokenProperties: tokenProperties
        )
        
        var encodedProperties = Buffer()
        tokenProperties.topEncode(output: &encodedProperties)
        
        let newTokenIdentifier = Buffer()
        
        var tokenTypeBuffer = Buffer()
        TokenType.fungible.topEncode(output: &tokenTypeBuffer)

        API.registerToken(
            tickerHandle: tokenTicker.handle,
            managerAddressHandle: Message.caller.buffer.handle,
            initialSupplyHandle: initialSupply.handle,
            tokenTypeHandle: tokenTypeBuffer.handle,
            propertiesHandle: encodedProperties.handle,
            resultHandle: newTokenIdentifier.handle
        )
        
        self.lastIssuedTokenIdentifier = newTokenIdentifier
        
        if initialSupply > 0 {
            Message.caller
                .send(
                    tokenIdentifier: newTokenIdentifier,
                    nonce: 0,
                    amount: initialSupply
                )
            
            return OptionalArgument.none
        } else {
            return OptionalArgument.some(newTokenIdentifier)
        }
    }
    
    public mutating func issueNonFungible(
        tokenDisplayName: Buffer,
        tokenTicker: Buffer,
        tokenProperties: MultiValueEncoded<Buffer>
    ) -> Buffer {
        guard Message.egldValue == self.getIssuanceCost() else {
            smartContractError(message: "Not enough payment.") // TODO: use the same error as the WASM VM
        }
        
        self.validateToken(
            tokenDisplayName: tokenDisplayName,
            tokenTicker: tokenTicker
        )
        
        let tokenProperties = self.computeTokenProperties(
            numDecimals: 0,
            tokenProperties: tokenProperties
        )
        
        var encodedProperties = Buffer()
        tokenProperties.topEncode(output: &encodedProperties)
        
        var tokenTypeBuffer = Buffer()
        TokenType.nonFungible.topEncode(output: &tokenTypeBuffer)

        let newTokenIdentifier = Buffer()
        
        self.lastIssuedTokenIdentifier = newTokenIdentifier

        API.registerToken(
            tickerHandle: tokenTicker.handle,
            managerAddressHandle: Message.caller.buffer.handle,
            initialSupplyHandle: BigUint(0).handle,
            tokenTypeHandle: tokenTypeBuffer.handle,
            propertiesHandle: encodedProperties.handle,
            resultHandle: newTokenIdentifier.handle
        )
        
        return newTokenIdentifier
    }
    
    public mutating func issueSemiFungible(
        tokenDisplayName: Buffer,
        tokenTicker: Buffer,
        tokenProperties: MultiValueEncoded<Buffer>
    ) -> Buffer {
        guard Message.egldValue == self.getIssuanceCost() else {
            smartContractError(message: "Not enough payment.") // TODO: use the same error as the WASM VM
        }
        
        self.validateToken(
            tokenDisplayName: tokenDisplayName,
            tokenTicker: tokenTicker
        )
        
        let tokenProperties = self.computeTokenProperties(
            numDecimals: 0,
            tokenProperties: tokenProperties
        )
        
        var encodedProperties = Buffer()
        tokenProperties.topEncode(output: &encodedProperties)
        
        var tokenTypeBuffer = Buffer()
        TokenType.semiFungible.topEncode(output: &tokenTypeBuffer)

        let newTokenIdentifier = Buffer()
        
        self.lastIssuedTokenIdentifier = newTokenIdentifier

        API.registerToken(
            tickerHandle: tokenTicker.handle,
            managerAddressHandle: Message.caller.buffer.handle,
            initialSupplyHandle: BigUint(0).handle,
            tokenTypeHandle: tokenTypeBuffer.handle,
            propertiesHandle: encodedProperties.handle,
            resultHandle: newTokenIdentifier.handle
        )
        
        return newTokenIdentifier
    }
    
    public mutating func registerMetaESDT(
        tokenDisplayName: Buffer,
        tokenTicker: Buffer,
        numDecimals: UInt32,
        tokenProperties: MultiValueEncoded<Buffer>
    ) -> Buffer {
        guard Message.egldValue == self.getIssuanceCost() else {
            smartContractError(message: "Not enough payment.") // TODO: use the same error as the WASM VM
        }
        
        self.validateToken(
            tokenDisplayName: tokenDisplayName,
            tokenTicker: tokenTicker
        )
        
        let tokenProperties = self.computeTokenProperties(
            numDecimals: numDecimals,
            tokenProperties: tokenProperties
        )
        
        var encodedProperties = Buffer()
        tokenProperties.topEncode(output: &encodedProperties)
        
        var tokenTypeBuffer = Buffer()
        TokenType.meta.topEncode(output: &tokenTypeBuffer)

        let newTokenIdentifier = Buffer()
        
        self.lastIssuedTokenIdentifier = newTokenIdentifier

        API.registerToken(
            tickerHandle: tokenTicker.handle,
            managerAddressHandle: Message.caller.buffer.handle,
            initialSupplyHandle: BigUint(0).handle,
            tokenTypeHandle: tokenTypeBuffer.handle,
            propertiesHandle: encodedProperties.handle,
            resultHandle: newTokenIdentifier.handle
        )
        
        return newTokenIdentifier
    }
    
    public mutating func registerAndSetAllRoles(
        tokenDisplayName: Buffer,
        tokenTicker: Buffer,
        tokenTypeName: Buffer,
        numDecimals: UInt32
    ) -> Buffer {
        let tokenPropertiesArgs = TokenPropertiesArgument(
            canFreeze: true,
            canWipe: true,
            canPause: true,
            canTransferCreateRole: true,
            canMint: true,
            canBurn: true,
            canChangeOwner: true,
            canUpgrade: true,
            canAddSpecialRoles: true
        )
        var tokenPropertiesEncodedArray = Vector<Buffer>()
        tokenPropertiesArgs.multiEncode(output: &tokenPropertiesEncodedArray)
        let tokenPropertiesEncoded = MultiValueEncoded(items: tokenPropertiesEncodedArray)
        
        let issuedTokenIdentifier = switch tokenTypeName {
        case "FNG":
            self.issue(
                tokenDisplayName: tokenDisplayName,
                tokenTicker: tokenTicker,
                initialSupply: 0,
                numDecimals: numDecimals,
                tokenProperties: tokenPropertiesEncoded
            ).intoOptional() ?? self.lastIssuedTokenIdentifier
        case "NFT":
            self.issueNonFungible(
                tokenDisplayName: tokenDisplayName,
                tokenTicker: tokenTicker,
                tokenProperties: tokenPropertiesEncoded
            )
        case "SFT":
            self.issueSemiFungible(
                tokenDisplayName: tokenDisplayName,
                tokenTicker: tokenTicker,
                tokenProperties: tokenPropertiesEncoded
            )
        case "META":
            self.registerMetaESDT(
                tokenDisplayName: tokenDisplayName,
                tokenTicker: tokenTicker,
                numDecimals: numDecimals,
                tokenProperties: tokenPropertiesEncoded
            )
        default:
            smartContractError(message: "Unknown token type.") // TODO: use the same error as the WASM VM
        }
        
        let allRoles = EsdtLocalRoles(
            canMint: true,
            canBurn: true,
            canCreateNft: true,
            canAddNftQuantity: true,
            canBurnNft: true,
            canUpdateNftAttributes: true,
            canAddNftUri: true,
            canRecreateNft: true,
            canModifyCreator: true,
            canModifyRoyalties: true,
            canSetNewUri: true
        )
        
        var roleNamesEncoded = MultiValueEncoded<Buffer>()
        
        allRoles.forEachFlag { flag in
            roleNamesEncoded = roleNamesEncoded.appended(value: flag.getRoleName())
        }
        
        self.setSpecialRole(
            tokenIdentifier: issuedTokenIdentifier,
            address: Message.caller,
            roles: roleNamesEncoded
        )
        
        return issuedTokenIdentifier
    }

    public func ESDTLocalMint(
        tokenIdentifier: Buffer,
        amount: BigUint
    ) {
        let tokenType = self.getTokenType(tokenIdentifier: tokenIdentifier)
        
        guard tokenType == .fungible else {
            smartContractError(message: "Token is not a fungible token.") // TODO: use the same error as the WASM VM
        }
        
        let tokenProperties = self.getTokenProperties(tokenIdentifier: tokenIdentifier)
        
        guard tokenProperties.canMint else {
            smartContractError(message: "Token is not mintable.") // TODO: use the same error as the WASM VM
        }
        
        let caller = Message.caller
        
        let callerRoles = self.getAddressRoles(
            tokenIdentifier: tokenIdentifier,
            address: caller
        )
        
        guard callerRoles.contains(flag: .mint) else {
            smartContractError(message: "Caller doesn't have the role to mint.") // TODO: use the same error as the WASM VM
        }
        
        API.mintTokens(
            tokenIdentifierHandle: tokenIdentifier.handle,
            nonce: 0,
            amountHandle: amount.handle
        )
        
        if amount > 0 {
            caller
                .send(
                    tokenIdentifier: tokenIdentifier,
                    nonce: 0,
                    amount: amount
                )
        }
    }
    
    public func ESDTLocalBurn(
        tokenIdentifier: Buffer,
        amount: BigUint
    ) {
        let tokenType = self.getTokenType(tokenIdentifier: tokenIdentifier)
        
        guard tokenType == .fungible else {
            smartContractError(message: "Token is not a fungible token.") // TODO: use the same error as the WASM VM
        }
        
        let tokenProperties = self.getTokenProperties(tokenIdentifier: tokenIdentifier)
        
        guard tokenProperties.canBurn else {
            smartContractError(message: "Token is not burnable.") // TODO: use the same error as the WASM VM
        }
        
        let caller = Message.caller
        
        let callerRoles = self.getAddressRoles(
            tokenIdentifier: tokenIdentifier,
            address: caller
        )
        
        guard callerRoles.contains(flag: .burn) else {
            smartContractError(message: "Caller doesn't have the role to burn.") // TODO: use the same error as the WASM VM
        }
        
        API.burnTokens(
            addressHandle: caller.buffer.handle,
            tokenIdentifierHandle: tokenIdentifier.handle,
            nonce: 0,
            amountHandle: amount.handle
        )
    }
    
    public func ESDTNFTBurn(
        tokenIdentifier: Buffer,
        nonce: UInt64,
        amount: BigUint
    ) {
        let tokenType = self.getTokenType(tokenIdentifier: tokenIdentifier)
        
        guard tokenType != .fungible else {
            smartContractError(message: "Token is not a non/semi fungible or meta token.") // TODO: use the same error as the WASM VM
        }
        
        let caller = Message.caller
        
        let callerRoles = self.getAddressRoles(
            tokenIdentifier: tokenIdentifier,
            address: caller
        )
        
        guard callerRoles.contains(flag: .nftBurn) else {
            smartContractError(message: "Caller doesn't have the role to burn.") // TODO: use the same error as the WASM VM
        }
        
        API.burnTokens(
            addressHandle: caller.buffer.handle,
            tokenIdentifierHandle: tokenIdentifier.handle,
            nonce: nonce,
            amountHandle: amount.handle
        )
    }

    public func ESDTNFTCreate(
        tokenIdentifier: Buffer,
        initialQuantity: BigUint,
        nftName: Buffer,
        royalties: BigUint,
        hash: Buffer,
        attributes: Buffer,
        uris: MultiValueEncoded<Buffer>
    ) -> UInt64 {
        let tokenType = self.getTokenType(tokenIdentifier: tokenIdentifier)
        
        guard tokenType != .fungible else {
            smartContractError(message: "Token is not a non/semi fungible or meta token.") // TODO: use the same error as the WASM VM
        }
        
        if tokenType == .nonFungible {
            guard initialQuantity == 1 else {
                smartContractError(message: "NFT tokens can only have have a supply of 1.") // TODO: use the same error as the WASM VM
            }
        }
        
        let caller = Message.caller
        
        let callerRoles = self.getAddressRoles(
            tokenIdentifier: tokenIdentifier,
            address: caller
        )
        
        guard callerRoles.contains(flag: .nftCreate) else {
            smartContractError(message: "Caller doesn't have the role to create nft.") // TODO: use the same error as the WASM VM
        }
        
        let urisVector = uris.toArray()
        
        let newNonce = API.createNonFungibleToken(
            tokenIdentifierHandle: tokenIdentifier.handle,
            initialQuantityHandle: initialQuantity.handle,
            hashHandle: hash.handle,
            nameHandle: nftName.handle,
            attributesHandle: attributes.handle,
            creatorHandle: caller.buffer.handle,
            royaltiesHandle: royalties.handle,
            urisHandle: urisVector.buffer.handle
        )
        
        if initialQuantity > 0 {
            caller.send(
                tokenIdentifier: tokenIdentifier,
                nonce: newNonce,
                amount: initialQuantity
            )
        }
        
        return newNonce
    }
    
    public func ESDTNFTAddQuantity(
        tokenIdentifier: Buffer,
        nonce: UInt64,
        amount: BigUint
    ) {
        let tokenType = self.getTokenType(tokenIdentifier: tokenIdentifier)
        
        guard tokenType != .fungible && tokenType != .nonFungible else {
            smartContractError(message: "Can add quantity only on SFT and Meta ESDT tokens.") // TODO: use the same error as the WASM VM
        }
        
        guard self.doesNonFungibleNonceExist(
            tokenIdentifier: tokenIdentifier,
            nonce: nonce
        ) else {
            smartContractError(message: "Token and nonce not found.") // TODO: use the same error as the WASM VM
        }
        
        let caller = Message.caller
        
        let callerRoles = self.getAddressRoles(
            tokenIdentifier: tokenIdentifier,
            address: caller
        )
        
        guard callerRoles.contains(flag: .nftAddQuantity) else {
            smartContractError(message: "Caller doesn't have the role to add quantity.") // TODO: use the same error as the WASM VM
        }
        
        API.mintTokens(
            tokenIdentifierHandle: tokenIdentifier.handle,
            nonce: nonce,
            amountHandle: amount.handle
        )
        
        if amount > 0 {
            caller
                .send(
                    tokenIdentifier: tokenIdentifier,
                    nonce: nonce,
                    amount: amount
                )
        }
    }

    public func setSpecialRole(
        tokenIdentifier: Buffer,
        address: Address,
        roles: MultiValueEncoded<Buffer>
    ) {
        let tokenProperties = self.getTokenProperties(tokenIdentifier: tokenIdentifier)
        
        guard tokenProperties.canAddSpecialRoles else {
            smartContractError(message: "Cannot add special roles on this token.") // TODO: use the same error as the WASM VM
        }
        
        let managerAddress = Address()
        
        API.getTokenManagerAddress(
            tokenIdentifierHandle: tokenIdentifier.handle,
            resultHandle: managerAddress.buffer.handle
        )
        
        guard Message.caller == managerAddress else {
            smartContractError(message: "Only the manager of the token can add special roles.") // TODO: use the same error as the WASM VM
        }
        
        let oldRoles = self.getAddressRoles(
            tokenIdentifier: tokenIdentifier,
            address: address
        )
        
        var parsedRoles = EsdtLocalRoles()
        
        roles.forEach { roleName in
            let roleToAdd: EsdtLocalRolesFlag
            
            switch roleName {
            case "":
                roleToAdd = .none
            case "ESDTRoleLocalMint":
                roleToAdd = .mint
            case "ESDTRoleLocalBurn":
                roleToAdd = .burn
            case "ESDTRoleNFTCreate":
                roleToAdd = .nftCreate
            case "ESDTRoleNFTAddQuantity":
                roleToAdd = .nftAddQuantity
            case "ESDTRoleNFTBurn":
                roleToAdd = .nftBurn
            case "ESDTRoleNFTUpdateAttributes":
                roleToAdd = .nftUpdateAttributes
                
                let numberOfAddressesWithRole = self.getNumberOfAddressesWithRoles(
                    tokenIdentifier: tokenIdentifier,
                    roles: EsdtLocalRoles(canUpdateNftAttributes: true)
                )
                
                guard numberOfAddressesWithRole == 0 || oldRoles.contains(flag: roleToAdd) else {
                    smartContractError(message: "Only one account at a time can have the role ESDTRoleNFTUpdateAttributes for a given token.") // TODO: use the same error as the WASM VM
                }
            case "ESDTRoleNFTAddURI":
                roleToAdd = .nftAddUri
            case "ESDTRoleNFTRecreate":
                roleToAdd = .nftRecreate
            case "ESDTRoleModifyCreator":
                roleToAdd = .modifyCreator
            case "ESDTRoleModifyRoyalties":
                roleToAdd = .modifyRoyalties
                
                let numberOfAddressesWithRole = self.getNumberOfAddressesWithRoles(
                    tokenIdentifier: tokenIdentifier,
                    roles: EsdtLocalRoles(canModifyRoyalties: true)
                )
                
                guard numberOfAddressesWithRole == 0 || oldRoles.contains(flag: roleToAdd) else {
                    smartContractError(message: "Only one account at a time can have the role ESDTRoleModifyRoyalties for a given token.") // TODO: use the same error as the WASM VM
                }
            case "ESDTRoleSetNewURI":
                roleToAdd = .setNewUri
            default:
                smartContractError(message: "Unknown role.") // TODO: use the same error as the WASM VM
            }
            
            parsedRoles.addRoles(roles: EsdtLocalRoles(flags: roleToAdd.rawValue))
        }
        
        API.setAddressTokenRoles(
            tokenIdentifierHandle: tokenIdentifier.handle,
            addressHandle: address.buffer.handle,
            roles: parsedRoles.flags
        )
    }
    
    public func ESDTNFTUpdateAttributes(
        tokenIdentifier: Buffer,
        nonce: UInt64,
        attributes: Buffer
    ) {
        let tokenType = self.getTokenType(tokenIdentifier: tokenIdentifier)
        
        guard tokenType == .nonFungible else {
            smartContractError(message: "Token is not a non fungible token.") // TODO: use the same error as the WASM VM
        }
        
        guard self.doesNonFungibleNonceExist(
            tokenIdentifier: tokenIdentifier,
            nonce: nonce
        ) else {
            smartContractError(message: "Token and nonce not found.") // TODO: use the same error as the WASM VM
        }
        
        let caller = Message.caller
        
        let callerRoles = self.getAddressRoles(
            tokenIdentifier: tokenIdentifier,
            address: caller
        )
        
        guard callerRoles.contains(flag: .nftUpdateAttributes) else {
            smartContractError(message: "Caller doesn't have the role to update attributes.") // TODO: use the same error as the WASM VM
        }
        
        // TODO: is it required for the caller to own the nonce?
        
        API.setTokenAttributes(
            tokenIdentifierHandle: tokenIdentifier.handle,
            nonce: nonce,
            attributesHandle: attributes.handle
        )
    }
    
    public func ESDTModifyRoyalties(
        tokenIdentifier: Buffer,
        nonce: UInt64,
        royalties: UInt64
    ) {
        let tokenType = self.getTokenType(tokenIdentifier: tokenIdentifier)
        
        guard tokenType == .nonFungible else {
            smartContractError(message: "Token is not a non fungible token.") // TODO: use the same error as the WASM VM
        }
        
        guard self.doesNonFungibleNonceExist(
            tokenIdentifier: tokenIdentifier,
            nonce: nonce
        ) else {
            smartContractError(message: "Token and nonce not found.") // TODO: use the same error as the WASM VM
        }
        
        let caller = Message.caller
        
        let callerRoles = self.getAddressRoles(
            tokenIdentifier: tokenIdentifier,
            address: caller
        )
        
        guard callerRoles.contains(flag: .modifyRoyalties) else {
            smartContractError(message: "Caller doesn't have the role to modify royalties.") // TODO: use the same error as the WASM VM
        }
        
        // TODO: is it required for the caller to own the nonce?
        
        API.setTokenRoyalties(
            tokenIdentifierHandle: tokenIdentifier.handle,
            nonce: nonce,
            royalties: royalties
        )
    }

    private func computeTokenProperties(
        numDecimals: UInt32,
        tokenProperties: MultiValueEncoded<Buffer>
    ) -> TokenProperties {
        guard numDecimals <= 18 else {
            smartContractError(message: "num decimals too high.") // TODO: use the same error as the WASM VM
        }
        
        var canFreeze = false
        var canWipe = false
        var canPause = false
        var canTransferCreateRole = false
        var canMint = false
        var canBurn = false
        var canChangeOwner = false
        var canUpgrade = false
        var canAddSpecialRoles = false
        
        let tokenPropertiesCount = tokenProperties.count
        var tokenPropertyEncodedIndex: Int32 = 0
        
        while tokenPropertyEncodedIndex + 1 < tokenPropertiesCount {
            let tokenPropertyName = tokenProperties.get(tokenPropertyEncodedIndex)
            let tokenPropertyRawValue = tokenProperties.get(tokenPropertyEncodedIndex + 1)
            let tokenPropertyValue = switch tokenPropertyRawValue {
            case "true":
                true
            case "false":
                false
            default:
                smartContractError(message: "Invalid argument.") // TODO: use the same error as the WASM VM
            }
            
            switch tokenPropertyName {
            case "canFreeze":
                canFreeze = tokenPropertyValue
            case "canWipe":
                canWipe = tokenPropertyValue
            case "canPause":
                canPause = tokenPropertyValue
            case "canTransferNFTCreateRole":
                canTransferCreateRole = tokenPropertyValue
            case "canMint":
                canMint = tokenPropertyValue
            case "canBurn":
                canBurn = tokenPropertyValue
            case "canChangeOwner":
                canChangeOwner = tokenPropertyValue
            case "canUpgrade":
                canUpgrade = tokenPropertyValue
            case "canAddSpecialRoles":
                canAddSpecialRoles = tokenPropertyValue
            default:
                smartContractError(message: "Unknown token property argument.")
            }
            
            tokenPropertyEncodedIndex += 2
        }
        
        return TokenProperties(
            numDecimals: numDecimals,
            canFreeze: canFreeze,
            canWipe: canWipe,
            canPause: canPause,
            canTransferCreateRole: canTransferCreateRole,
            canMint: canMint,
            canBurn: canBurn,
            canChangeOwner: canChangeOwner,
            canUpgrade: canUpgrade,
            canAddSpecialRoles: canAddSpecialRoles
        )
    }
    
    private func getTokenProperties(
        tokenIdentifier: Buffer
    ) -> TokenProperties {
        let tokenPropertiesBuffer = Buffer()
        
        API.getTokenProperties(
            tokenIdentifierHandle: tokenIdentifier.handle,
            resultHandle: tokenPropertiesBuffer.handle
        )
        
        return TokenProperties(topDecode: tokenPropertiesBuffer)
    }
    
    private func getTokenType(
        tokenIdentifier: Buffer
    ) -> TokenType {
        let tokenPropertiesBuffer = Buffer()
        
        API.getTokenType(
            tokenIdentifierHandle: tokenIdentifier.handle,
            resultHandle: tokenPropertiesBuffer.handle
        )
        
        return TokenType(topDecode: tokenPropertiesBuffer)
    }
    
    private func getNumberOfAddressesWithRoles(
        tokenIdentifier: Buffer,
        roles: EsdtLocalRoles
    ) -> UInt64 {
        API.getNumberOfAddressesWithRolesForToken(
            tokenIdentifierHandle: tokenIdentifier.handle,
            roles: roles.flags
        )
    }
    
    private func getAddressRoles(
        tokenIdentifier: Buffer,
        address: Address
    ) -> EsdtLocalRoles {
        let flags = API.getAddressTokenRoles(
            tokenIdentifierHandle: tokenIdentifier.handle,
            addressHandle: address.buffer.handle
        )
        
        return EsdtLocalRoles(flags: flags)
    }
    
    private func doesNonFungibleNonceExist(
        tokenIdentifier: Buffer,
        nonce: UInt64
    ) -> Bool {
        let result = API.doesNonFungibleNonceExist(
            tokenIdentifierHandle: tokenIdentifier.handle,
            nonce: nonce
        )
        
        return result == 1
    }
    
    private func getIssuanceCost() -> BigUint {
        // TODO: do better when pow is implemented
        let ten: BigUint = 10
        
        // 5 * 10^16 = 0.05 EGLD
        return BigUint(5) * ten * ten * ten * ten * ten * ten * ten * ten * ten * ten * ten * ten * ten * ten * ten * ten
    }
    
    private func validateToken(tokenDisplayName: Buffer, tokenTicker: Buffer) {
        // Note: This functions use types that are forbidden by SpaceKit.
        // This is not an issue because this code is not compiled when targetting the WASM VM.
        
        guard let name = String(data: Data(tokenDisplayName.toBytes()), encoding: .utf8) else {
            smartContractError(message: "token's display name is not a valid UTF-8 string.") // TODO: use the same error as the WASM VM
        }
        
        guard let ticker = String(data: Data(tokenTicker.toBytes()), encoding: .utf8) else {
            smartContractError(message: "token's ticker is not a valid UTF-8 string.") // TODO: use the same error as the WASM VM
        }
        
        let nameRegex = /^[a-zA-Z0-9]{3,50}$/
        let tickerRegex = /^[A-Z0-9]{3,10}$/
        
        guard name.firstMatch(of: nameRegex) != nil else {
            smartContractError(message: "invalid token display name.") // TODO: use the same error as the WASM VM
        }
        
        guard ticker.firstMatch(of: tickerRegex) != nil else {
            smartContractError(message: "invalid token ticker.") // TODO: use the same error as the WASM VM
        }
    }
}
#endif
