import SpaceKit

let PERCENTAGE_TOTAL: UInt32 = 100
let THIRTY_DAYS_IN_SECONDS: UInt64 = 60 * 60 * 24 * 30
let MAX_TICKETS: UInt32 = 800

@Controller public struct LotteryController {
    @Mapping(key: "lotteryInfo") var lotteryInfoForLotteryName: StorageMap<Buffer, LotteryInfo>
    @Mapping(key: "burnPercentageForLottery") var burnPercentageForLottery: StorageMap<Buffer, BigUint>
    
    public mutating func start(
        lotteryName: Buffer,
        tokenIdentifier: TokenIdentifier,
        ticketPrice: BigUint,
        optTotalTickets: UInt32?,
        optDeadline: UInt64?,
        optMaxEntriesPerUser: UInt32?,
        optPrizeDistribution: Vector<UInt8>?,
        optWhitelist: Vector<Address>?,
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
    
    mutating func startLottery(
        lotteryName: Buffer,
        tokenIdentifier: TokenIdentifier,
        ticketPrice: BigUint,
        optTotalTickets: UInt32?,
        optDeadline: UInt64?,
        optMaxEntriesPerUser: UInt32?,
        optPrizeDistribution: Vector<UInt8>?,
        optWhitelist: Vector<Address>?,
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
        let prizeDistribution = optPrizeDistribution ?? Vector(singleItem: UInt8(PERCENTAGE_TOTAL))
        
        require(
            self.status(lotteryName: lotteryName) == .inactive,
            "Lottery is already active!"
        )
        require(
            !lotteryName.isEmpty,
            "Can't have empty lottery name!"
        )
        // TODO: require token identifier is valid
        require(
            ticketPrice > 0,
            "Ticket price must be higher than 0!"
        )
        require(
            totalTickets > 0,
            "Must have more than 0 tickets available!"
        )
        require(
            totalTickets <= MAX_TICKETS,
            "Only 800 or less total tickets per lottery are allowed!"
        )
        require(
            deadline > timestamp,
            "Deadline can't be in the past!"
        )
        require(
            deadline <= timestamp + THIRTY_DAYS_IN_SECONDS,
            "Deadline can't be later than 30 days from now!"
        )
        require(
            maxEntriesPerUser > 0,
            "Must have more than 0 max entries per user!"
        )
        require(
            self.sumArray(array: prizeDistribution) == PERCENTAGE_TOTAL,
            "Prize distribution must add up to exactly 100(%)!"
        )
        
        if let burnPercentage = optBurnPercentage.intoOptional() {
            require(
                !tokenIdentifier.isEGLD,
                "EGLD can't be burned!"
            )
            
            let roles = Blockchain.getESDTLocalRoles(tokenIdentifier: tokenIdentifier)
            require(
                roles.contains(flag: .burn),
                "The contract can't burn the selected token!"
            )
            
            require(
                burnPercentage < BigUint(value: PERCENTAGE_TOTAL),
                "Invalid burn percentage!"
            )
            
            self.burnPercentageForLottery[lotteryName] = burnPercentage
        }
        
        if let whitelist = optWhitelist {
            let mapper = self.getLotteryWhitelistMapper(lotteryName: lotteryName)
            
            whitelist.forEach { let _ = mapper.insert(value: $0) }
        }
        
        let info = LotteryInfo(
            tokenIdentifier: tokenIdentifier,
            ticketPrice: ticketPrice,
            ticketsLeft: totalTickets,
            deadline: deadline,
            maxEntriesPerUser: maxEntriesPerUser,
            prizeDistribution: prizeDistribution,
            prizePool: 0
        )
        
        self.lotteryInfoForLotteryName[lotteryName] = info
    }
    
    public mutating func createLotteryPool(
        lotteryName: Buffer,
        tokenIdentifier: TokenIdentifier,
        ticketPrice: BigUint,
        optTotalTickets: UInt32?,
        optDeadline: UInt64?,
        optMaxEntriesPerUser: UInt32?,
        optPrizeDistribution: Vector<UInt8>?,
        optWhitelist: Vector<Address>?,
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
    
    public func buyTicket(lotteryName: Buffer) {
        let payment = Message.egldOrSingleEsdtTransfer
        
        let status = self.status(lotteryName: lotteryName)
        
        switch status {
        case .inactive:
            smartContractError(message: "Lottery is currently inactive.")
        case .running:
            self.updateAfterBuyTicket(
                lotteryName: lotteryName,
                tokenIdentifier: payment.tokenIdentifier,
                payment: payment.amount
            )
        case .ended:
            smartContractError(message: "Lottery entry period has ended! Awaiting winner announcement.")
        }
    }
    
    public func determineWinner(lotteryName: Buffer) {
        let status = self.status(lotteryName: lotteryName)
        switch status {
        case .inactive:
            smartContractError(message: "Lottery is inactive!")
        case .running:
            smartContractError(message: "Lottery is still running!")
        case .ended:
            self.distributePrizes(lotteryName: lotteryName)
            self.clearStorage(lotteryName: lotteryName)
        }
    }
    
    func distributePrizes(lotteryName: Buffer) {
        var info = self.lotteryInfoForLotteryName[lotteryName]
        let ticketHoldersMapper = self.getTicketsHoldersMapper(lotteryName: lotteryName)
        let totalTickets = ticketHoldersMapper.count
        
        guard totalTickets > 0 else {
            return
        }
        
        let burnPercentage = self.burnPercentageForLottery[lotteryName]
        if burnPercentage > 0 {
            let burnAmount = self.calculatePercentageOf(value: info.prizePool, percentage: burnPercentage)
            
            // Prevent crashing if the role was unset while the lottery was running
            // The tokens will simply remain locked forever
            let esdtTokenId = info.tokenIdentifier
            let roles = Blockchain.getESDTLocalRoles(tokenIdentifier: esdtTokenId)
            if roles.contains(flag: .burn) {
                Blockchain.burnTokens(
                    tokenIdentifier: esdtTokenId,
                    nonce: 0,
                    amount: burnAmount
                )
            }
            
            info.prizePool = info.prizePool - burnAmount
        }
        
        let prizeDistributionCount = info.prizeDistribution.count
        let totalWinningTickets = if totalTickets < prizeDistributionCount {
            totalTickets
        } else {
            UInt32(prizeDistributionCount)
        }
        
        let totalPrize = info.prizePool
        let winningTickets = self.getDistinctRandom(min: 1, max: totalTickets, amount: totalWinningTickets)
        
        for i in 1..<totalWinningTickets {
            let winningTicketId = winningTickets[Int32(i)]
            let winnerAddress = ticketHoldersMapper.get(index: winningTicketId)
            
            let prize = self.calculatePercentageOf(
                value: totalPrize,
                percentage: BigUint(value: info.prizeDistribution.get(Int32(i)))
            )
            winnerAddress.send(
                tokenIdentifier: info.tokenIdentifier,
                nonce: 0,
                amount: prize
            )
            
            info.prizePool = info.prizePool - prize
        }
        
        let firstPlaceWinner = ticketHoldersMapper.get(index: winningTickets.get(0))
        firstPlaceWinner.send(
            tokenIdentifier: info.tokenIdentifier,
            nonce: 0,
            amount: info.prizePool
        )
    }
    
    func updateAfterBuyTicket(
        lotteryName: Buffer,
        tokenIdentifier: TokenIdentifier,
        payment: BigUint
    ) {
        let infoMapper = self.$lotteryInfoForLotteryName[lotteryName]
        
        var info = infoMapper.get()
        let caller = Message.caller
        let whitelist = self.getLotteryWhitelistMapper(lotteryName: lotteryName)
        
        require(
            whitelist.isEmpty || whitelist.contains(value: caller),
            "You are not allowed to participate in this lottery!"
        )
        require(
            tokenIdentifier == info.tokenIdentifier && payment == info.ticketPrice,
            "Wrong ticket fee!"
        )
        
        let entriesMapper = self.getNumberOfEntriesForUserMapper(
            lotteryName: lotteryName,
            user: caller
        )
        var entries = entriesMapper.get()
        
        require(
            entries < info.maxEntriesPerUser,
            "Ticket limit exceeded for this lottery!"
        )
        
        let _ = self.getTicketsHoldersMapper(lotteryName: lotteryName).append(item: caller)
        
        entries += 1
        info.ticketsLeft -= 1
        info.prizePool += info.ticketPrice
        
        entriesMapper.set(entries)
        infoMapper.set(info)
    }
    
    public func status(lotteryName: Buffer) -> Status {
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
    
    func sumArray(array: Vector<UInt8>) -> UInt32 {
        var sum: UInt32 = 0
        
        array.forEach { item in
            sum += UInt32(item)
        }
        
        return sum
    }
    
    func calculatePercentageOf(value: BigUint, percentage: BigUint) -> BigUint {
        return value * percentage / BigUint(value: PERCENTAGE_TOTAL)
    }
    
    func getDistinctRandom(
        min: UInt32,
        max: UInt32,
        amount: UInt32
    ) -> Vector<UInt32> {
        var randNumbers: Vector<UInt32> = Vector()
        
        for number in min...max {
            randNumbers = randNumbers.appended(number)
        }
        
        let totalNumbers = UInt32(randNumbers.count)
        
        for i in 0..<amount {
            let randIndex = Randomness.nextUInt32InRange(min: 0, max: totalNumbers)
            
            if i != randIndex {
                let temp = randNumbers[Int32(i)]
                randNumbers = randNumbers.replaced(at: Int32(i), value: randNumbers[Int32(randIndex)])
                randNumbers = randNumbers.replaced(at: Int32(randIndex), value: temp)
            }
        }
        
        return randNumbers
    }
    
    func clearStorage(lotteryName: Buffer) {
        let ticketsHolderMapper = self.getTicketsHoldersMapper(lotteryName: lotteryName)
        let currentTicketNumber = ticketsHolderMapper.count
        
        for i in 1..<(1 + currentTicketNumber) {
            let addr = ticketsHolderMapper.get(index: i)
            self.getNumberOfEntriesForUserMapper(lotteryName: lotteryName, user: addr).clear()
        }
        
        ticketsHolderMapper.clear()
        self.$lotteryInfoForLotteryName[lotteryName].clear()
        self.getLotteryWhitelistMapper(lotteryName: lotteryName).clear()
        self.$burnPercentageForLottery[lotteryName].clear()
    }
    
    func getLotteryWhitelistMapper(lotteryName: Buffer) -> UnorderedSetMapper<Address> {
        UnorderedSetMapper(baseKey: "lotteryWhitelist") {
            lotteryName
        }
    }
    
    func getNumberOfEntriesForUserMapper(lotteryName: Buffer, user: Address) -> SingleValueMapper<UInt32> {
        return SingleValueMapper(baseKey: "numberOfEntriesForUser") {
            lotteryName
            user
        }
    }
    
    func getTicketsHoldersMapper(lotteryName: Buffer) -> VecMapper<Address> {
        return VecMapper(baseKey: "ticketHolder") {
            lotteryName
        }
    }
}
