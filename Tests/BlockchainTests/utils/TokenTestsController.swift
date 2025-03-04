import SpaceKitTesting

@Codable public struct TestAttributes: Equatable {
    let buffer: Buffer
    let biguint: BigUint
}

@Controller public struct TokenTestsController {
    @Storage(key: "lastIssuedTokenIdentifier") var lastIssuedTokenIdentifier: TokenIdentifier
    @Storage(key: "lastErrorMessage") var lastErrorMessage: Buffer
    
    public func issueToken(
        tokenDisplayName: Buffer,
        tokenTicker: Buffer,
        initialSupply: BigUint,
        properties: FungibleTokenProperties
    ) {
        let caller = Message.caller
        
        Blockchain
            .issueFungibleToken(
                tokenDisplayName: tokenDisplayName,
                tokenTicker: tokenTicker,
                initialSupply: initialSupply,
                properties: properties
            )
            .registerPromise(
                gas: 100_000_000,
                value: Message.egldValue,
                callback: self.$issueCallback(
                    caller: caller,
                    mintedAmount: initialSupply,
                    gasForCallback: 100_000_000
                )
            )
    }
    
    public func issueNonFungible(
        tokenDisplayName: Buffer,
        tokenTicker: Buffer,
        properties: NonFungibleTokenProperties
    ) {
        let caller = Message.caller
        
        Blockchain
            .issueNonFungibleToken(
                tokenDisplayName: tokenDisplayName,
                tokenTicker: tokenTicker,
                properties: properties
            )
            .registerPromise(
                gas: 100_000_000,
                value: Message.egldValue,
                callback: self.$issueCallback(
                    caller: caller,
                    mintedAmount: 0,
                    gasForCallback: 100_000_000
                )
            )
    }
    
    public func issueSemiFungible(
        tokenDisplayName: Buffer,
        tokenTicker: Buffer,
        properties: SemiFungibleTokenProperties
    ) {
        let caller = Message.caller
        
        Blockchain
            .issueSemiFungibleToken(
                tokenDisplayName: tokenDisplayName,
                tokenTicker: tokenTicker,
                properties: properties
            )
            .registerPromise(
                gas: 100_000_000,
                value: Message.egldValue,
                callback: self.$issueCallback(
                    caller: caller,
                    mintedAmount: 0,
                    gasForCallback: 100_000_000
                )
            )
    }
    
    public func registerMetaEsdt(
        tokenDisplayName: Buffer,
        tokenTicker: Buffer,
        properties: MetaTokenProperties
    ) {
        let caller = Message.caller
        
        Blockchain
            .registerMetaEsdt(
                tokenDisplayName: tokenDisplayName,
                tokenTicker: tokenTicker,
                properties: properties
            )
            .registerPromise(
                gas: 100_000_000,
                value: Message.egldValue,
                callback: self.$issueCallback(
                    caller: caller,
                    mintedAmount: 0,
                    gasForCallback: 100_000_000
                )
            )
    }
    
    public func registerAndSetAllRoles(
        tokenDisplayName: Buffer,
        tokenTicker: Buffer,
        tokenType: TokenType,
        numDecimals: UInt32
    ) {
        let caller = Message.caller
        
        Blockchain
            .registerAndSetAllRoles(
                tokenDisplayName: tokenDisplayName,
                tokenTicker: tokenTicker,
                tokenType: tokenType,
                numDecimals: numDecimals
            )
            .registerPromise(
                gas: 100_000_000,
                value: Message.egldValue,
                callback: self.$issueCallback(
                    caller: caller,
                    mintedAmount: 0,
                    gasForCallback: 100_000_000
                )
            )
    }

    public func createAndSendNonFungibleToken(
        tokenIdentifier: TokenIdentifier,
        amount: BigUint,
        royalties: BigUint,
        attributes: Buffer,
        to: Address
    ) {
        let createdNonce = Blockchain.createNft(
            tokenIdentifier: tokenIdentifier,
            amount: amount,
            name: "MyNFT",
            royalties: royalties,
            hash: "",
            attributes: attributes,
            uris: Vector()
        )
        
        to.send(
            tokenIdentifier: tokenIdentifier,
            nonce: createdNonce,
            amount: amount
        )
    }
    
    public func updateAttributesRaw(
        tokenIdentifier: TokenIdentifier,
        nonce: UInt64,
        attributes: Buffer
    ) {
        Blockchain
            .updateNftAttributes(
                tokenIdentifier: tokenIdentifier,
                nonce: nonce,
                attributes: attributes
            )
    }
    
    public func updateAttributes(
        tokenIdentifier: TokenIdentifier,
        nonce: UInt64,
        attributes: TestAttributes
    ) {
        Blockchain
            .updateNftAttributes(
                tokenIdentifier: tokenIdentifier,
                nonce: nonce,
                attributes: attributes
            )
    }

    public func retrieveAttributesRaw(
        tokenIdentifier: TokenIdentifier,
        nonce: UInt64
    ) -> Buffer {
        Blockchain
            .getTokenAttributes(
                tokenIdentifier: tokenIdentifier,
                nonce: nonce
            )
    }
    
    public func retrieveAttributes(
        tokenIdentifier: TokenIdentifier,
        nonce: UInt64
    ) -> TestAttributes {
        Blockchain
            .getTokenAttributes(
                tokenIdentifier: tokenIdentifier,
                nonce: nonce
            )
    }
    
    public func retrieveRoyalties(
        tokenIdentifier: TokenIdentifier,
        nonce: UInt64
    ) -> BigUint {
        Blockchain
            .getTokenRoyalties(
                tokenIdentifier: tokenIdentifier,
                nonce: nonce
            )
    }
    
    public func getSelfTokenRoles(
        tokenIdentifier: TokenIdentifier
    ) -> UInt64 {
        Blockchain.getESDTLocalRoles(tokenIdentifier: tokenIdentifier).flags
    }
    
    public func mintAndSendTokens(
        tokenIdentifier: TokenIdentifier,
        nonce: UInt64,
        amount: BigUint
    ) {
        Blockchain
            .mintTokens(
                tokenIdentifier: tokenIdentifier,
                nonce: nonce,
                amount: amount
            )
        
        if amount > 0 {
            Message.caller
                .send(
                    tokenIdentifier: tokenIdentifier,
                    nonce: nonce,
                    amount: amount
                )
        }
    }
    
    public func burnTokens() {
        Message.allEsdtTransfers
            .forEach { payment in
                Blockchain
                    .burnTokens(
                        tokenIdentifier: payment.tokenIdentifier,
                        nonce: payment.nonce,
                        amount: payment.amount
                    )
            }
    }
    
    public func setTokenRoles(
        tokenIdentifier: TokenIdentifier,
        address: Address,
        roles: UInt64
    ) {
        Blockchain.setTokenRoles(
            for: address,
            tokenIdentifier: tokenIdentifier,
            roles: EsdtLocalRoles(flags: roles)
        )
        .registerPromise(
            gas: 100_000_000,
            callback: self.$setSpecialRolesCallback(gasForCallback: 100_000_000)
        )
    }
    
    public func modifyRoyalties(
        tokenIdentifier: TokenIdentifier,
        nonce: UInt64,
        royalties: UInt64
    ) {
        Blockchain.modifyTokenRoyalties(
            tokenIdentifier: tokenIdentifier,
            nonce: nonce,
            royalties: royalties
        )
    }
    
    public func getLastIssuedTokenIdentifier() -> TokenIdentifier {
        self.lastIssuedTokenIdentifier
    }

    public func getLastErrorMessage() -> Buffer {
        self.lastErrorMessage
    }
    
    @Callback public mutating func issueCallback(
        caller: Address,
        mintedAmount: BigUint
    ) {
        var tokenIdentifier: TokenIdentifier?
        var asyncCallError: AsyncCallError?
        
        if mintedAmount == 0 {
            let asyncResult: AsyncCallResult<TokenIdentifier> = Message.asyncCallResult()
            
            switch asyncResult {
            case .success(let issuedTokenIdentifier):
                tokenIdentifier = issuedTokenIdentifier
            case .error(let error):
                asyncCallError = error
            }
        } else {
            let asyncResult: AsyncCallResult<IgnoreValue> = Message.asyncCallResult()
            
            switch asyncResult {
            case .success(_):
                tokenIdentifier = Message.singleEsdt.tokenIdentifier
            case .error(let error):
                asyncCallError = error
            }
        }
        
        if let tokenIdentifier = tokenIdentifier {
            self.lastIssuedTokenIdentifier = tokenIdentifier
            
            if mintedAmount > 0 {
                caller.send(
                    tokenIdentifier: tokenIdentifier,
                    nonce: 0,
                    amount: mintedAmount
                )
            }
        } else if let asyncCallError = asyncCallError {
            self.lastErrorMessage = asyncCallError.errorMessage
        } else {
            smartContractError(message: "Unreachable.")
        }
    }
    
    @Callback public mutating func setSpecialRolesCallback() {
        let asyncResult: AsyncCallResult<IgnoreValue> = Message.asyncCallResult()
        
        switch asyncResult {
        case .success(_):
            break
        case .error(let error):
            self.lastErrorMessage = error.errorMessage
        }
    }
}
