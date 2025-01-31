import SpaceKit

@Controller public struct ClaimRoyaltiesController {
    // TODO: use TokenIdentifier type once implemented
    
    
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
}
