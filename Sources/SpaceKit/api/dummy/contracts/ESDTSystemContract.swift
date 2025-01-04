#if !WASM
@Controller public struct ESDTSystemContract {
    public func issue(
        tokenDisplayName: Buffer,
        tokenTicker: Buffer,
        initialSupply: BigUint,
        numDecimals: UInt32,
        tokenProperties: MultiValueEncoded<Buffer>
    ) {
        let tokenProperties = self.computeTokenProperties(
            numDecimals: numDecimals,
            tokenProperties: tokenProperties
        )
        
        var encodedProperties = Buffer()
        tokenProperties.topEncode(output: &encodedProperties)
        
        let newTokenIdentifier = Buffer()

        API.registerToken(
            tickerHandle: tokenTicker.handle,
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
}
#endif
