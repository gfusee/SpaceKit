import SpaceKit

@Init func initialize(
    genZeroKittyStartingPrice: BigUint,
    genZeroKittyEndingPrice: BigUint,
    genZeroKittyAuctionDuration: UInt64,
    optKittyOwnershipContractAddress: OptionalArgument<Address>
) {
    var controller = CryptoKittiesAuctionController()
    
    controller.genZeroKittyStartingPrice = genZeroKittyStartingPrice
    controller.genZeroKittyEndingPrice = genZeroKittyEndingPrice
    controller.genZeroKittyAuctionDuration = genZeroKittyAuctionDuration
    
    if let kittyOwnershipContractAddress = optKittyOwnershipContractAddress.intoOptional() {
        controller.kittyOwnershipContractAddress = kittyOwnershipContractAddress
    }
}
