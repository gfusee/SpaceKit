import SpaceKit

@Init public func initialize(
    ownerPercentFees: UInt64,
    bountyPercentFees: UInt64,
    minimumBlockBounty: UInt64
) {
    var storageController = StorageController()
    
    storageController.ownerPercentFees = ownerPercentFees
    storageController.bountyPercentFees = bountyPercentFees
}
