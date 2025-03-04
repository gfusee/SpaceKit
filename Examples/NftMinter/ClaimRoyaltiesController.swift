import SpaceKit

@Controller public struct ClaimRoyaltiesController {
    public func claimRoyaltiesFromMarketplace(
        marketplaceAddress: Address,
        tokenIdentifier: TokenIdentifier,
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
