import SpaceKit

@Proxy enum CryptoKittiesOwnershipProxy {
    case createGenZeroKitty
    case allowAuctioning(by: Address, kittyId: UInt32)
    case transfer(to: Address, kittyId: UInt32)
    case approveSiringAndReturnKitty(approvedAddress: Address, kittyOwner: Address, kittyId: UInt32)
}
