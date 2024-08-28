import Space

@Codable struct ExampleAttributes {
    let creationTimestamp: UInt64
}

@Contract struct NftMinter {
    
    // TODO: use TokenIdentifier type once implemented
    public func createNft(
        name: MXBuffer,
        royalties: BigUint,
        uri: MXBuffer,
        sellingPrice: BigUint,
        optTokenUsedAsPayment: OptionalArgument<MXBuffer>,
        optTokenUsedAsPaymentNonce: OptionalArgument<UInt64>
    ) {
        assertOwner()
        
        let tokenUsedAsPayment: MXBuffer = if let tokenUsedAsPayment = optTokenUsedAsPayment.intoOptional() {
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
        
        let _ = NftModule.createNftWithAttributes(
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
        tokenIdentifier: MXBuffer,
        tokenNonce: UInt64
    ) {
        assertOwner()
        
        let caller = Message.caller
        
        NftMarketplaceProxy.claimTokens(
            tokenId: tokenIdentifier,
            nonce: tokenNonce,
            claimDestination: caller
        ).registerPromise(
            receiver: marketplaceAddress,
            callbackName: "", // TODO: no callback
            gas: Blockchain.getGasLeft(),
            gasForCallback: 0,
            callbackArgs: ArgBuffer()
        )
    }
    
    public func buyNft(nftNonce: UInt64) {
        NftModule.buyNft(nftNonce: nftNonce)
    }
    
    @Callback public func issueCallback() {
        NftModule.issueCallback()
    }
}
