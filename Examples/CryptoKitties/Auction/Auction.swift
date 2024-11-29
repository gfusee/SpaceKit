import SpaceKit

@Codable enum AuctionType {
    case selling
    case siring
}

@Codable struct Auction {
    let auctionType: AuctionType
    let startingPrice: BigUint
    let endingPrice: BigUint
    let deadline: UInt64
    let kittyOwner: Address
    var currentBid: BigUint
    var currentWinner: Address
}
