import SpaceKit

@Codable struct ExampleAttributes {
    let creationTimestamp: UInt64
}

@Contract struct NftMinter {
    
    // TODO: use TokenIdentifier type once implemented
    public func createNft(
        name: Buffer,
        royalties: BigUint,
        uri: Buffer,
        sellingPrice: BigUint,
        optTokenUsedAsPayment: OptionalArgument<Buffer>,
        optTokenUsedAsPaymentNonce: OptionalArgument<UInt64>
    ) {
        assertOwner()
        
        let tokenUsedAsPayment: Buffer = if let tokenUsedAsPayment = optTokenUsedAsPayment.intoOptional() {
            tokenUsedAsPayment
        } else {
            "EGLD" // TODO: no hardcoded EGLD
        }
        
        // TODO: add a require that checks the token identifier is valid
        
        let tokenUsedAsPaymentNonce: UInt64 = if tokenUsedAsPayment == "EGLD" { // TODO: no hardcoded EGLD
            0
        } else {
            optTokenUsedAsPaymentNonce.intoOptional() ?? 0
        }
        
        let attributes = ExampleAttributes(creationTimestamp: Blockchain.getBlockTimestamp())
        
        var nftModule = NftModule()
        
        let _ = nftModule.createNftWithAttributes(
            name: name,
            royalties: royalties,
            attributes: attributes,
            uri: uri,
            sellingPrice: sellingPrice,
            tokenUsedAsPayment: tokenUsedAsPayment,
            tokenUsedAsPaymentNonce: tokenUsedAsPaymentNonce
        )
    }
    
    public func claimRoyaltiesFromMarketplace(
        marketplaceAddress: Address,
        tokenIdentifier: Buffer,
        tokenNonce: UInt64
    ) {
        assertOwner()
        
        let caller = Message.caller
        
        NftMarketplaceProxy.claimTokens(
            tokenId: tokenIdentifier,
            nonce: tokenNonce,
            claimDestination: caller
        ).registerPromiseRaw(
            receiver: marketplaceAddress,
            gas: Blockchain.getGasLeft()
        )
    }
    
    public func buyNft(nftNonce: UInt64) {
        let nftModule = NftModule()
        
        nftModule.buyNft(nftNonce: nftNonce)
    }
    
    @Callback public func issueCallback() {
        var nftModule = NftModule()
        
        nftModule.issueCallback()
    }
}
