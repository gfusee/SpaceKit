import SpaceKit

@Codable public struct LotteryInfo {
    let tokenIdentifier: TokenIdentifier
    let ticketPrice: BigUint
    var ticketsLeft: UInt32
    let deadline: UInt64
    let maxEntriesPerUser: UInt32
    let prizeDistribution: Vector<UInt8>
    var prizePool: BigUint
}
