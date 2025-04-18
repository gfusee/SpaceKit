import SpaceKit

@Controller public struct MyContract {
    @Storage(key: "issuedTokenIdentifier") var issuedTokenIdentifier: TokenIdentifier
    
    public func issueToken() {
        assertOwner()

        if !self.$issuedTokenIdentifier.isEmpty() {
            smartContractError(message: "Token already issued")
        }
        
        let payment = Message.egldValue
        
        Blockchain
            .issueFungibleToken(
                tokenDisplayName: "SpaceKitToken",
                tokenTicker: "SPACE",
                initialSupply: 1,
                properties: FungibleTokenProperties(
                    numDecimals: 18,
                    canFreeze: false,
                    canWipe: false,
                    canPause: false,
                    canMint: true,
                    canBurn: true,
                    canChangeOwner: true,
                    canUpgrade: true,
                    canAddSpecialRoles: true
                )
            )
            .registerPromise(
                gas: 30_000_000,
                value: payment,
                callback: // We will fill this parameter later
            )
    }
    
    @Callback public mutating func issueTokenCallback(sentValue: BigUint) {
        let result: AsyncCallResult<IgnoreValue> = Message.asyncCallResult()
        
        switch result {
        case .success(_):
            // We will fill the success case later
        case .error(_):
            // We will fill the error case later
        }
    }

}

