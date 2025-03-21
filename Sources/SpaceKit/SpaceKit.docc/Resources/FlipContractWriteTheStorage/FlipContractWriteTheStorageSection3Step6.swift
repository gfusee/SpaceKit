import SpaceKit

@Init public func initialize(
    ownerPercentFees: UInt64,
    bountyPercentFees: UInt64,
    minimumBlockBounty: UInt64
) {
    var storageController = StorageController()
    
    storageController.ownerPercentFees = ownerPercentFees
    storageController.bountyPercentFees = bountyPercentFees
    
    require(
        minimumBlockBounty > 0,
        "Minimum block bounty should be greater than zero."
    )
}
