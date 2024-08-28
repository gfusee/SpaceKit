import Space

struct StorageModule {
    @Mapping(key: "deposit") var depositForDonor: StorageMap<Address, DepositInfo>
    @Mapping(key: "fee") var feeForToken: StorageMap<Buffer, BigUint> // TODO: use TokenIdentifier once available
    @Mapping(key: "collectedFees") var collectedFeesForToken: StorageMap<Buffer, BigUint> // TODO: use TokenIdentifier once available
    @UnorderedSetMapping<Buffer>(key: "whitelistedFeeTokens") var whitelistedFeeTokens // TODO: use TokenIdentifier once available
    @UnorderedSetMapping<Buffer>(key: "allTimeFeeTokens") var allTimeFeeTokens // TODO: use TokenIdentifier once available
}
