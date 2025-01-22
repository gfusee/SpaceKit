import SpaceKit

@Controller public struct TestTokenOperationsController {
    @Storage(key: "lastIssuedTokenIdentifier") var lastIssuedTokenIdentifier: Buffer
    @Storage(key: "lastErrorMessage") var lastErrorMessage: Buffer
    
    public func issueToken(
        tokenDisplayName: Buffer,
        tokenTicker: Buffer,
        numDecimals: UInt32,
        canFreeze: Bool,
        canWipe: Bool,
        canPause: Bool,
        canMint: Bool,
        canBurn: Bool,
        canChangeOwner: Bool,
        canUpgrade: Bool,
        canAddSpecialRoles: Bool
    ) {
        let caller = Message.caller
        
        Blockchain
            .issueFungibleToken(
                tokenDisplayName: tokenDisplayName,
                tokenTicker: tokenTicker,
                initialSupply: 0,
                properties: FungibleTokenProperties(
                    numDecimals: numDecimals,
                    canFreeze: canFreeze,
                    canWipe: canWipe,
                    canPause: canPause,
                    canMint: canMint,
                    canBurn: canBurn,
                    canChangeOwner: canChangeOwner,
                    canUpgrade: canUpgrade,
                    canAddSpecialRoles: canAddSpecialRoles
                )
            )
            .registerPromise(
                gas: 100_000_000,
                value: Message.egldValue,
                callback: self.$issueCallback(
                    caller: caller,
                    gasForCallback: 100_000_000
                )
            )
    }
    
    public func mintTokens(
        tokenIdentifier: Buffer,
        nonce: UInt64,
        amount: BigUint,
        to: Address
    ) {
        Blockchain.mintTokens(
            tokenIdentifier: tokenIdentifier,
            nonce: nonce,
            amount: amount
        )
        
        if to != Blockchain.getSCAddress() {
            to.send(
                tokenIdentifier: tokenIdentifier,
                nonce: nonce,
                amount: amount
            )
        }
    }
    
    public func createNFT(
        tokenIdentifier: Buffer,
        initialSupply: BigUint,
        royalties: BigUint,
        attributes: Buffer,
        to: Address
    ) -> UInt64 {
        let nonce = Blockchain.createNft(
            tokenIdentifier: tokenIdentifier,
            amount: initialSupply,
            name: "NFT",
            royalties: royalties,
            hash: "",
            attributes: attributes,
            uris: Vector()
        )
       
        if to != Blockchain.getSCAddress() {
            to.send(
                tokenIdentifier: tokenIdentifier,
                nonce: nonce,
                amount: initialSupply
            )
        }
        
        return nonce
    }
    
    public func burnTokens(
        tokenIdentifier: Buffer,
        nonce: UInt64,
        amount: BigUint
    ) {
        TokenPayment(
            tokenIdentifier: tokenIdentifier,
            nonce: nonce,
            amount: amount
        ).burn()
    }
    
    public func modifyTokenRoyalties(
        tokenIdentifier: Buffer,
        nonce: UInt64,
        royalties: UInt64
    ) {
        Blockchain.modifyTokenRoyalties(
            tokenIdentifier: tokenIdentifier,
            nonce: nonce,
            royalties: royalties
        )
    }
    
    public func getTokenRoyalties(
        tokenIdentifier: Buffer,
        nonce: UInt64
    ) -> BigUint {
        Blockchain.getTokenRoyalties(
            tokenIdentifier: tokenIdentifier,
            nonce: nonce
        )
    }
    
    public func updateNftAttributes(
        tokenIdentifier: Buffer,
        nonce: UInt64,
        attributes: Buffer
    ) {
        Blockchain.updateNftAttributes(
            tokenIdentifier: tokenIdentifier,
            nonce: nonce,
            attributes: attributes
        )
    }
    
    public func getTokenAttributes(
        tokenIdentifier: Buffer,
        nonce: UInt64
    ) -> Buffer {
        Blockchain.getTokenAttributes(
            tokenIdentifier: tokenIdentifier,
            nonce: nonce
        )
    }
    
    public func doesAddressHaveSpecialRole(
        tokenIdentifier: Buffer,
        address: Address,
        expectedFlags: UInt64
    ) -> Bool {
        let roles = Blockchain.getESDTLocalRoles(tokenIdentifier: tokenIdentifier)
        
        return roles.flags == expectedFlags
    }
    
    public func getLastIssuedTokenIdentifier() -> Buffer {
        self.lastIssuedTokenIdentifier
    }
    
    public func assertLastIssuedTokenIdentifierIsValid(
        expectedTicker: Buffer
    ) {
        let lastIssuedTokenIdentifier = self.lastIssuedTokenIdentifier
        
        guard !lastIssuedTokenIdentifier.isEmpty else {
            smartContractError(message: "Empty last issued token identifier")
        }
        
        let expectedTickerCount = expectedTicker.count
        
        guard lastIssuedTokenIdentifier.getSubBuffer(startIndex: 0, length: expectedTickerCount + 1) == "\(expectedTicker)-" else {
            smartContractError(message: "Last issued token identifier (\(lastIssuedTokenIdentifier)) doesn't start with \(expectedTicker)-")
        }
        
        guard lastIssuedTokenIdentifier.count >= expectedTickerCount + 7 else {
            smartContractError(message: "Last issued token identifier too short")
        }
    }
    
    @Callback public mutating func issueCallback(
        caller: Address
    ) {
        let asyncResult: AsyncCallResult<Buffer> = Message.asyncCallResult()
        
        switch asyncResult {
        case .success(let tokenIdentifier):
            self.lastIssuedTokenIdentifier = tokenIdentifier
        case .error(let asyncCallError):
            self.lastErrorMessage = asyncCallError.errorMessage
        }
    }
}
