import Space

struct StorageModule {
    @Mapping(key: "deposit") var depositForDonor: StorageMap<Address, DepositInfo>
    @Mapping(key: "fee") var feeForToken: StorageMap<MXBuffer, BigUint> // TODO: use TokenIdentifier once available
    @Mapping(key: "collectedFees") var collectedFeesForToken: StorageMap<MXBuffer, BigUint> // TODO: use TokenIdentifier once available
    @UnorderedSetMapping<MXBuffer>(key: "whitelistedFeeTokens") var whitelistedFeeTokens // TODO: use TokenIdentifier once available
    @UnorderedSetMapping<MXBuffer>(key: "allTimeFeeTokens") var allTimeFeeTokens // TODO: use TokenIdentifier once available
}
