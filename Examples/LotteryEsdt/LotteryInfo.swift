import SpaceKit

// TODO: use TokenIdentifier type
@Codable public struct LotteryInfo {
    let tokenIdentifier: Buffer
    let ticketPrice: BigUint
    var ticketsLeft: UInt32
    let deadline: UInt64
    let maxEntriesPerUser: UInt32
    let prizeDistribution: Vector<UInt8>
    var prizePool: BigUint
}
