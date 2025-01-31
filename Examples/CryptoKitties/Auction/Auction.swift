import SpaceKit

@Codable public enum AuctionType {
    case selling
    case siring
}

@Codable public struct Auction {
    let auctionType: AuctionType
    let startingPrice: BigUint
    let endingPrice: BigUint
    let deadline: UInt64
    let kittyOwner: Address
    var currentBid: BigUint
    var currentWinner: Address
}
