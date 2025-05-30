import SpaceKit

@Controller public struct MyContract {
    @Storage(key: "issuedTokenIdentifier") var issuedTokenIdentifier: TokenIdentifier
    
    public func issueSemiFungibleToken() {
        assertOwner()

        if !self.$issuedTokenIdentifier.isEmpty() {
            smartContractError(message: "Token already issued")
        }
        
        let payment = Message.egldValue
        
        Blockchain
            .issueSemiFungibleToken(
                tokenDisplayName: "TestToken",
                tokenTicker: "TEST",
                properties: SemiFungibleTokenProperties(
                    canFreeze: false,
                    canWipe: false,
                    canPause: false,
                    canTransferCreateRole: false,
                    canChangeOwner: false,
                    canUpgrade: false,
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
    
    public func setAllRoles() {
        assertOwner()
        
        guard !self.$issuedTokenIdentifier.isEmpty() else {
            smartContractError(message: "Token not issued")
        }
        
        Blockchain
            .setTokenRoles(
                for: Blockchain.getSCAddress(),
                tokenIdentifier: self.issuedTokenIdentifier,
                roles: EsdtLocalRoles(
                    canCreateNft: true,
                    canAddNftQuantity: true,
                    canBurnNft: true
                )
            )
            .registerPromise(
                gas: 60_000_000
            )
    }
    
    public func createNewNonce(initialQuantity: BigUint) -> UInt64 {
        assertOwner()
        
        let tokenRoles = Blockchain.getESDTLocalRoles(tokenIdentifier: self.issuedTokenIdentifier)
        
        guard tokenRoles.contains(flag: .nftCreate) else {
            smartContractError(message: "Cannot create new nonces")
        }
        
        let newNonce = Blockchain
            .createNft(
                tokenIdentifier: self.issuedTokenIdentifier,
                amount: initialQuantity,
                name: "MySemiFungibleToken",
                royalties: 0,
                hash: "",
                attributes: Buffer(),
                uris: Vector()
            )
        
        Message.caller
            .send(
                tokenIdentifier: self.issuedTokenIdentifier,
                nonce: newNonce,
                amount: initialQuantity
            )
        
        return newNonce
    }
    
    public func addQuantity(
        nonce: UInt64,
        amount: BigUint
    ) {
        assertOwner()
        
        let tokenRoles = Blockchain.getESDTLocalRoles(tokenIdentifier: self.issuedTokenIdentifier)
        
        guard tokenRoles.contains(flag: .nftAddQuantity) else {
            smartContractError(message: "Cannot add quantity")
        }
        
        Blockchain
            .mintTokens(
                tokenIdentifier: self.issuedTokenIdentifier,
                nonce: nonce,
                amount: amount
            )
        
        Message.caller
            .send(
                tokenIdentifier: self.issuedTokenIdentifier,
                nonce: nonce,
                amount: amount
            )
    }
    
    @Callback public mutating func issueTokenCallback(sentValue: BigUint) {
        let result: AsyncCallResult<TokenIdentifier> = Message.asyncCallResult()
        
        switch result {
        case .success(let tokenIdentifier):
            self.issuedTokenIdentifier = tokenIdentifier
        case .error(_):
            Blockchain.getOwner()
                .send(egldValue: sentValue)
        }
    }
}

