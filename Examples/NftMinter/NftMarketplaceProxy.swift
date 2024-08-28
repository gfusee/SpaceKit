import Space

@Proxy enum NftMarketplaceProxy {
    case claimTokens(
        tokenId: Buffer,
        nonce: UInt64,
        claimDestination: Address
    )
}
