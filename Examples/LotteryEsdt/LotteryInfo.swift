import MultiversX

@Codable struct LotteryInfo {
    let tokenIdentifier: MXBuffer // TODO: use TokenIdentifier type
    let ticketPrice: BigUint
    var ticketsLeft: UInt32
    let deadline: UInt64
    let maxEntriesPerUser: UInt32
    let prizeDistribution: MXArray<UInt8>
    var prizePool: BigUint
}
