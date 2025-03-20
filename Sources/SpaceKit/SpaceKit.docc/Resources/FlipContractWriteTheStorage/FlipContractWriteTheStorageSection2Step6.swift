import SpaceKit

@Controller public struct StorageController {
    @Storage(key: "ownerPercentFees") var ownerPercentFees: UInt64
    @Storage(key: "bountyPercentFees") var bountyPercentFees: UInt64
    @Storage(key: "minimumBlockBounty") var minimumBlockBounty: UInt64
}
