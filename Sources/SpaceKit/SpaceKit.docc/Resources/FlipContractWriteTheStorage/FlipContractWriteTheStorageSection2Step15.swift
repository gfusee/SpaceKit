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
    
    public func getMaximumBetPercent(
        tokenIdentifier: TokenIdentifier,
        tokenNonce: UInt64
    ) -> SingleValueMapper<UInt64> {
        SingleValueMapper(baseKey: "maximumBetPercent") {
            tokenIdentifier
            tokenNonce
        }
    }
    
    public func getTokenReserve(
        tokenIdentifier: TokenIdentifier,
        tokenNonce: UInt64
    ) -> SingleValueMapper<BigUint> {
        SingleValueMapper(baseKey: "tokenReserve") {
            tokenIdentifier
            tokenNonce
        }
    }
    
    public func getOwnerPercentFees() -> UInt64 {
        self.ownerPercentFees
    }
    
    public func getBountyPercentFees() -> UInt64 {
        self.bountyPercentFees
    }
    
    public func getMinimumBlockBounty() -> UInt64 {
        self.minimumBlockBounty
    }
}
