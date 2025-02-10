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
        
        Blockchain
            .setTokenRoles(
                for: Blockchain.getSCAddress(),
                tokenIdentifier: self.issuedTokenIdentifier,
                roles: EsdtLocalRoles(
                    canMint: true,
                    canBurn: true
                )
            )
            .registerPromise(
                gas: 60_000_000,
            )
    }
    
    public func mintTokens(mintAmount: BigUint) {
        assertOwner()
        
        let tokenRoles = Blockchain.getESDTLocalRoles(tokenIdentifier: self.issuedTokenIdentifier)
        
        guard tokenRoles.contains(flag: .mint) else {
            smartContractError(message: "Cannot mint tokens")
        }
        
        Blockchain
            .mintTokens(
                tokenIdentifier: self.issuedTokenIdentifier,
                nonce: 0,
                amount: mintAmount
            )
        
        Message.caller
            .send(
                tokenIdentifier: self.issuedTokenIdentifier,
                nonce: 0,
                amount: mintAmount
            )
    }
    
    public func burnTokens(burnAmount: BigUint) {
        assertOwner()
        
        let tokenRoles = Blockchain.getESDTLocalRoles(tokenIdentifier: self.issuedTokenIdentifier)
        
        guard tokenRoles.contains(flag: .burn) else {
            smartContractError(message: "Cannot mint tokens")
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

