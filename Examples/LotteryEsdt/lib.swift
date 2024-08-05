import MultiversX

let PERCENTAGE_TOTAL: UInt32 = 100
let THIRTY_DAYS_IN_SECONDS: UInt64 = 60 * 60 * 24 * 30
let MAX_TICKETS: UInt32 = 800

@Contract struct Lottery {
    
    @Mapping(key: "lotteryInfo") var lotteryInfoForLotteryName: StorageMap<MXBuffer, LotteryInfo>
    
    func start(
        lotteryName: MXBuffer,
        tokenIdentifier: MXBuffer,
        ticketPrice: BigUint,
        optTotalTickets: UInt32?,
        optDeadline: UInt64?,
        optMaxEntriesPerUser: UInt32?,
        optPrizeDistribution: MXArray<UInt8>?,
        optWhitelist: MXArray<Address>?,
        optBurnPercentage: OptionalArgument<BigUint>
    ) {
        self.startLottery(
            lotteryName: lotteryName,
            tokenIdentifier: tokenIdentifier,
            ticketPrice: ticketPrice,
            optTotalTickets: optTotalTickets,
            optDeadline: optDeadline,
            optMaxEntriesPerUser: optMaxEntriesPerUser,
            optPrizeDistribution: optPrizeDistribution,
            optWhitelist: optWhitelist,
            optBurnPercentage: optBurnPercentage
        )
    }
    
    func startLottery(
        lotteryName: MXBuffer,
        tokenIdentifier: MXBuffer,
        ticketPrice: BigUint,
        optTotalTickets: UInt32?,
        optDeadline: UInt64?,
        optMaxEntriesPerUser: UInt32?,
        optPrizeDistribution: MXArray<UInt8>?,
        optWhitelist: MXArray<Address>?,
        optBurnPercentage: OptionalArgument<BigUint>
    ) {
        require(
            !lotteryName.isEmpty,
            "Name can't be empty!"
        )
        
        let timestamp = Blockchain.getBlockTimestamp()
        let totalTickets = optTotalTickets ?? MAX_TICKETS
        let deadline = optDeadline ?? (timestamp + THIRTY_DAYS_IN_SECONDS)
        let maxEntriesPerUser = optMaxEntriesPerUser ?? MAX_TICKETS
        let prizeDistribution = optPrizeDistribution ?? [UInt8(PERCENTAGE_TOTAL)]
        
        // TODO
    }
    
    public func status(lotteryName: MXBuffer) -> Status {
        let lotteryInfoMapper = self.$lotteryInfoForLotteryName[lotteryName]
        
        guard !lotteryInfoMapper.isEmpty() else {
            return .inactive
        }
        
        let info = lotteryInfoMapper.get()
        let currentTime = Blockchain.getBlockTimestamp()
        
        guard currentTime <= info.deadline && info.ticketsLeft > 0 else {
            return .ended
        }
        
        return .running
    }
}
