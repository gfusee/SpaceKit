#if !WASM
@Controller public struct ESDTSystemContract {
    public func issue(
        tokenDisplayName: Buffer,
        tokenTicker: Buffer,
        initialSupply: BigUint,
        numDecimals: UInt32,
        tokenProperties: MultiValueEncoded<Buffer>
    ) -> Buffer {
        guard Message.egldValue == self.getIssuanceCost() else {
            smartContractError(message: "Not enough payment.") // TODO: use the same error as the WASM VM
        }
        
        let tokenProperties = self.computeTokenProperties(
            numDecimals: numDecimals,
            tokenProperties: tokenProperties
        )
        
        var encodedProperties = Buffer()
        tokenProperties.topEncode(output: &encodedProperties)
        
        let newTokenIdentifier = Buffer()

        API.registerToken(
            tickerHandle: tokenTicker.handle,
            managerAddressHandle: Message.caller.buffer.handle,
            initialSupplyHandle: initialSupply.handle,
            propertiesHandle: encodedProperties.handle,
            resultHandle: newTokenIdentifier.handle
        )
        
        if initialSupply > 0 {
            Message.caller
                .send(
                    tokenIdentifier: newTokenIdentifier,
                    nonce: 0,
                    amount: initialSupply
                )
        }
        
        return newTokenIdentifier
    }
    
    public func issueNonFungible(
        tokenDisplayName: Buffer,
        tokenTicker: Buffer,
        tokenProperties: MultiValueEncoded<Buffer>
    ) -> Buffer {
        guard Message.egldValue == self.getIssuanceCost() else {
            smartContractError(message: "Not enough payment.") // TODO: use the same error as the WASM VM
        }
        
        let tokenProperties = self.computeTokenProperties(
            numDecimals: 0,
            tokenProperties: tokenProperties
        )
        
        var encodedProperties = Buffer()
        tokenProperties.topEncode(output: &encodedProperties)
        
        let newTokenIdentifier = Buffer()

        API.registerToken(
            tickerHandle: tokenTicker.handle,
            managerAddressHandle: Message.caller.buffer.handle,
            initialSupplyHandle: BigUint(0).handle,
            propertiesHandle: encodedProperties.handle,
            resultHandle: newTokenIdentifier.handle
        )
        
        return newTokenIdentifier
    }
    
    public func ESDTNFTCreate(
        tokenIdentifier: Buffer,
        initialQuantity: BigUint,
        nftName: Buffer,
        royalties: BigUint,
        attributes: Buffer,
        uris: MultiValueEncoded<Buffer>
    ) -> UInt64 {
        let caller = Message.caller
        
        let flags = API.getAddressTokenRoles(
            tokenIdentifierHandle: tokenIdentifier.handle,
            addressHandle: caller.buffer.handle
        )
        
        let roles = EsdtLocalRoles(flags: Int32(flags))
        
        guard roles.contains(flag: .nftCreate) else {
            smartContractError(message: "Caller doesn't have the role to create a new NFT.") // TODO: use the same error as the WASM VM
        }
        
        let newNonce = API.createNonFungibleToken(
            tokenIdentifierHandle: tokenIdentifier.handle,
            initialQuantityHandle: initialQuantity.handle
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
    
    public func setSpecialRole(
        tokenIdentifier: Buffer,
        address: Address,
        roles: MultiValueEncoded<Buffer>
    ) {
        let tokenPropertiesBuffer = Buffer()
        
        API.getTokenProperties(
            tokenIdentifierHandle: tokenIdentifier.handle,
            resultHandle: tokenPropertiesBuffer.handle
        )
        
        let tokenProperties = TokenProperties(topDecode: tokenPropertiesBuffer)
        
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
            case "ESDTRoleNFTAddURI":
                roleToAdd = .nftAddUri
            case "ESDTRoleNFTUpdateAttributes":
                roleToAdd = .nftUpdateAttributes
            case "ESDTTransferRole":
                roleToAdd = .transfer
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

    private func computeTokenProperties(
        numDecimals: UInt32,
        tokenProperties: MultiValueEncoded<Buffer>
    ) -> TokenProperties {
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
        
        while tokenPropertyEncodedIndex < tokenPropertiesCount {
            let tokenPropertyName = tokenProperties.get(tokenPropertyEncodedIndex)
            let tokenPropertyRawValue = tokenProperties.get(tokenPropertyEncodedIndex + 1)
            let tokenPropertyValue = Bool(topDecode: tokenPropertyRawValue)
            
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
    
    private func getIssuanceCost() -> BigUint {
        // TODO: do better when pow is implemented
        let ten: BigUint = 10
        
        // 5 * 10^16 = 0.05 EGLD
        return BigUint(5) * ten * ten * ten * ten * ten * ten * ten * ten * ten * ten * ten * ten * ten * ten * ten * ten
    }
}
#endif
