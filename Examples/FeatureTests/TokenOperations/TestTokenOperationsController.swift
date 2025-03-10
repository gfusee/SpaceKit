import SpaceKit

@Controller public struct TestTokenOperationsController {
    @Storage(key: "lastIssuedTokenIdentifier") var lastIssuedTokenIdentifier: TokenIdentifier
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
    
    public func issueNonFungibleToken(
        tokenDisplayName: Buffer,
        tokenTicker: Buffer,
        canFreeze: Bool,
        canWipe: Bool,
        canPause: Bool,
        canTransferCreateRole: Bool,
        canChangeOwner: Bool,
        canUpgrade: Bool,
        canAddSpecialRoles: Bool
    ) {
        let caller = Message.caller
        
        Blockchain
            .issueNonFungibleToken(
                tokenDisplayName: tokenDisplayName,
                tokenTicker: tokenTicker,
                properties: NonFungibleTokenProperties(
                    canFreeze: canFreeze,
                    canWipe: canWipe,
                    canPause: canPause,
                    canTransferCreateRole: canTransferCreateRole,
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
    
    public func issueSemiFungibleToken(
        tokenDisplayName: Buffer,
        tokenTicker: Buffer,
        canFreeze: Bool,
        canWipe: Bool,
        canPause: Bool,
        canTransferCreateRole: Bool,
        canChangeOwner: Bool,
        canUpgrade: Bool,
        canAddSpecialRoles: Bool
    ) {
        let caller = Message.caller
        
        Blockchain
            .issueSemiFungibleToken(
                tokenDisplayName: tokenDisplayName,
                tokenTicker: tokenTicker,
                properties: SemiFungibleTokenProperties(
                    canFreeze: canFreeze,
                    canWipe: canWipe,
                    canPause: canPause,
                    canTransferCreateRole: canTransferCreateRole,
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
    
    public func registerMetaToken(
        tokenDisplayName: Buffer,
        tokenTicker: Buffer,
        numDecimals: UInt32,
        canFreeze: Bool,
        canWipe: Bool,
        canPause: Bool,
        canTransferCreateRole: Bool,
        canChangeOwner: Bool,
        canUpgrade: Bool,
        canAddSpecialRoles: Bool
    ) {
        let caller = Message.caller
        
        Blockchain
            .registerMetaEsdt(
                tokenDisplayName: tokenDisplayName,
                tokenTicker: tokenTicker,
                properties: MetaTokenProperties(
                    numDecimals: numDecimals,
                    canFreeze: canFreeze,
                    canWipe: canWipe,
                    canPause: canPause,
                    canTransferCreateRole: canTransferCreateRole,
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
    
    public func setSpecialRoles(
        tokenIdentifier: TokenIdentifier,
        roleFlags: UInt64
    ) {
        Blockchain.setTokenRoles(
            for: Blockchain.getSCAddress(),
            tokenIdentifier: tokenIdentifier,
            roles: EsdtLocalRoles(flags: roleFlags)
        )
        .registerPromise(
            gas: 100_000_000
        )
    }
    
    public func mintTokens(
        tokenIdentifier: TokenIdentifier,
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
        tokenIdentifier: TokenIdentifier,
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
        tokenIdentifier: TokenIdentifier,
        nonce: UInt64,
        amount: BigUint
    ) {
        Blockchain.burnTokens(
            tokenIdentifier: tokenIdentifier,
            nonce: nonce,
            amount: amount
        )
    }
    
    public func modifyTokenRoyalties(
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
    
    public func getTokenRoyalties(
        tokenIdentifier: TokenIdentifier,
        nonce: UInt64
    ) -> BigUint {
        Blockchain.getTokenRoyalties(
            tokenIdentifier: tokenIdentifier,
            nonce: nonce
        )
    }
    
    public func updateNftAttributes(
        tokenIdentifier: TokenIdentifier,
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
        tokenIdentifier: TokenIdentifier,
        nonce: UInt64
    ) -> Buffer {
        Blockchain.getTokenAttributes(
            tokenIdentifier: tokenIdentifier,
            nonce: nonce
        )
    }
    
    public func assertSelfHaveSpecialRole(
        tokenIdentifier: TokenIdentifier,
        expectedFlags: UInt64
    ) {
        let roles = Blockchain.getESDTLocalRoles(tokenIdentifier: tokenIdentifier)
        
        guard roles.flags == expectedFlags else {
            smartContractError(message: "Contract doesn't the expected role(s) for \(tokenIdentifier).")
        }
    }
    
    public func getLastIssuedTokenIdentifier() -> TokenIdentifier {
        self.lastIssuedTokenIdentifier
    }
    
    public func assertLastIssuedTokenIdentifierIsValid(
        expectedTicker: Buffer
    ) {
        let lastIssuedTokenIdentifier = self.lastIssuedTokenIdentifier
        
        guard !lastIssuedTokenIdentifier.buffer.isEmpty else {
            smartContractError(message: "Empty last issued token identifier")
        }
        
        let expectedTickerCount = expectedTicker.count
        
        guard lastIssuedTokenIdentifier.buffer.getSubBuffer(startIndex: 0, length: expectedTickerCount + 1) == "\(expectedTicker)-" else {
            smartContractError(message: "Last issued token identifier (\(lastIssuedTokenIdentifier)) doesn't start with \(expectedTicker)-")
        }
        
        guard lastIssuedTokenIdentifier.buffer.count >= expectedTickerCount + 7 else {
            smartContractError(message: "Last issued token identifier too short")
        }
    }
    
    @Callback public mutating func issueCallback(
        caller: Address
    ) {
        let asyncResult: AsyncCallResult<TokenIdentifier> = Message.asyncCallResult()
        
        switch asyncResult {
        case .success(let tokenIdentifier):
            self.lastIssuedTokenIdentifier = tokenIdentifier
        case .error(let asyncCallError):
            self.lastErrorMessage = asyncCallError.errorMessage
        }
    }
}
