import SpaceKit

struct Storage {
    @Mapping(key: "deposit") var depositForDonor: StorageMap<Address, DepositInfo>
    @Mapping(key: "fee") var feeForToken: StorageMap<TokenIdentifier, BigUint>
    @Mapping(key: "collectedFees") var collectedFeesForToken: StorageMap<TokenIdentifier, BigUint>
    @UnorderedSetMapping<TokenIdentifier>(key: "whitelistedFeeTokens") var whitelistedFeeTokens
    @UnorderedSetMapping<TokenIdentifier>(key: "allTimeFeeTokens") var allTimeFeeTokens
}
