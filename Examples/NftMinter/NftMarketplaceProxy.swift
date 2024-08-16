import MultiversX

@Proxy enum NftMarketplaceProxy {
    case claimTokens(
        tokenId: MXBuffer,
        nonce: UInt64,
        claimDestination: Address
    )
}
