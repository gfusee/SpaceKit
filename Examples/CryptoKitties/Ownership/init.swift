import SpaceKit

@Init func initialize(
    birthFee: BigUint,
    optGeneScienceContractAddress: OptionalArgument<Address>,
    optKittyAuctionContractAddress: OptionalArgument<Address>
) {
    var controller = CryptoKittiesOwnershipController()
    
    controller.birthFee = birthFee
    
    if let geneScienceContractAddress = optGeneScienceContractAddress.intoOptional() {
        controller.geneScienceContractAddress = geneScienceContractAddress
    }
    
    if let kittyAuctionContractAddress = optKittyAuctionContractAddress.intoOptional() {
        controller.kittyAuctionContractAddress = kittyAuctionContractAddress
    }
    
    controller.createGenesisKitty()
}
