import SpaceKit

@Controller struct MyContract {
    @Storage(key: "issuedTokenIdentifier") var issuedTokenIdentifier: Buffer
    
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
                callback: self.$issueTokenCallback(
                    sentValue: payment,
                    gasForCallback: 15_000_000
                )
            )
    }
    
    public func setMintAndBurnRoles() {
        assertOwner()
        
        guard !self.$issuedTokenIdentifier.isEmpty() else {
            smartContractError(message: "Token not issued")
        }
    }
    
    @Callback public mutating func issueTokenCallback(sentValue: BigUint) {
        let result: AsyncCallResult<IgnoreValue> = Message.asyncCallResult()
        
        switch result {
        case .success(_):
            let receivedPayment = Message.singleFungibleEsdt
            
            self.issuedTokenIdentifier = receivedPayment.tokenIdentifier
        case .error(_):
            Blockchain.getOwner()
                .send(egldValue: sentValue)
        }
    }
}

