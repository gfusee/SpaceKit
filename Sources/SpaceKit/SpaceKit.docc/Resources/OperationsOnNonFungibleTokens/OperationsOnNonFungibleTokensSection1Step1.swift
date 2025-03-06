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

