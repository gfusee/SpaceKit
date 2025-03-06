import SpaceKit

@Proxy enum NftMarketplaceProxy {
    case claimTokens(
        tokenId: TokenIdentifier,
        nonce: UInt64,
        claimDestination: Address
    )
}
