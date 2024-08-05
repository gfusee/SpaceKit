import MultiversX

@Codable struct LotteryInfo {
    let tokenIdentifier: MXBuffer // TODO: use TokenIdentifier type
    let ticketPrice: BigUint
    let ticketsLeft: UInt32
    let deadline: UInt64
    let maxEntriesPerUser: UInt32
    let prizeDistribution: MXArray<UInt8>
    let prizePool: BigUint
}
