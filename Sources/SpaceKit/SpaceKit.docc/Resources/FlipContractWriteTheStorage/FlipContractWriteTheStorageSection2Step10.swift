import SpaceKit

@Controller public struct StorageController {
    @Storage(key: "ownerPercentFees") var ownerPercentFees: UInt64
    @Storage(key: "bountyPercentFees") var bountyPercentFees: UInt64
    @Storage(key: "minimumBlockBounty") var minimumBlockBounty: UInt64
    @Storage(key: "lastFlipId") var lastFlipId: UInt64
    @Storage(key: "lastBountyFlipId") var lastBountyFlipId: UInt64
    
    @Mapping<UInt64, Flip>(key: "flipForId") var flipForId
    
    public func getMaximumBet(
        tokenIdentifier: TokenIdentifier,
        tokenNonce: UInt64
    ) -> SingleValueMapper<BigUint> {
        SingleValueMapper(baseKey: "maximumBet") {
            tokenIdentifier
            tokenNonce
        }
    }
}
