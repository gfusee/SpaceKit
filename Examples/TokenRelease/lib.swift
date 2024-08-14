import MultiversX

let PERCENTAGE_TOTAL: UInt64 = 100

@Contract struct TokenRelease {
    @Storage(key: "activationTimestamp") var activationTimestamp: UInt64
    @Storage(key: "tokenIdentifier") var tokenIdentifier: MXBuffer
    @Storage(key: "tokenTotalSupply") var tokenTotalSupply: BigUint
    @Storage(key: "setupPeriodStatus") var setupPeriodStatus: Bool
    @Storage(key: "addressChangeRequest") var addressChangeRequest: Address
    @Mapping<MXBuffer, Schedule>(key: "groupSchedule") var groupScheduleForGroupIdentifier
    @Mapping<Address, MXArray<MXBuffer>>(key: "userGroups") var userGroupsForAddress
    @Mapping<MXBuffer, UInt64>(key: "usersInGroup") var usersInGroupForGroupIdentifier
    @Mapping<Address, BigUint>(key: "claimedBalance") var claimedBalanceForAddress
    
    // TODO: use TokenIdentifier type once implemented
    init(tokenIdentifier: MXBuffer) {
        // TODO: add a require to check that the token identifier is valid (same as the Rust contract)
        
        self.tokenIdentifier = tokenIdentifier
        self.setupPeriodStatus = true
    }
    
    public mutating func addFixedAmountGroup(
        groupIdentifier: MXBuffer,
        groupTotalAmount: BigUint,
        periodUnlockAmount: BigUint,
        releasePeriod: UInt64,
        releaseTicks: UInt64
    ) {
        assertOwner()
        
        self.requireSetupPeriodLive()
        
        let groupScheduleMapper = self.$groupScheduleForGroupIdentifier[groupIdentifier]
        require(
            groupScheduleMapper.isEmpty(),
            "The group already exists"
        )
        
        require(
            releaseTicks > 0,
            "The schedule must have at least 1 unlock period"
        )
        
        require(
            groupTotalAmount > 0,
            "The schedule must have a positive number of total tokens released"
        )
        
        require(
            periodUnlockAmount * BigUint(value: releaseTicks) == groupTotalAmount,
            "The total number of tokens is invalid"
        )
        
        let tokenTotalSupplyMapper = self.$tokenTotalSupply
        let tokenTotalSupply = tokenTotalSupplyMapper.get()
        tokenTotalSupplyMapper.set(tokenTotalSupply + groupTotalAmount)
        
        let unlockType = UnlockType.fixedAmount(
            FixedAmountUnlockType(
                periodUnlockAmount: periodUnlockAmount,
                releasePeriod: releasePeriod,
                releaseTicks: releaseTicks
            )
        )
        
        let newSchedule = Schedule(
            groupTotalAmount: groupTotalAmount,
            unlockType: unlockType
        )
        
        self.groupScheduleForGroupIdentifier[groupIdentifier] = newSchedule
    }
    
    public mutating func addPercentageBasedGroup(
        groupIdentifier: MXBuffer,
        groupTotalAmount: BigUint,
        periodUnlockPercentage: UInt8,
        releasePeriod: UInt64,
        releaseTicks: UInt64
    ) {
        self.requireSetupPeriodLive()
        
        require(
            groupScheduleMapper.isEmpty(),
            "The group already exists"
        )
        
        require(
            releaseTicks > 0,
            "The schedule must have at least 1 unlock period"
        )
        
        require(
            groupTotalAmount > 0,
            "The schedule must have a positive number of total tokens released"
        )
        
        require(
            UInt64(periodUnlockPercentage) * releaseTicks == PERCENTAGE_TOTAL,
            "The final percentage is invalid"
        )
        
        // TODO: implement the rest of the endpoint
    }
    
    func requireSetupPeriodLive() {
        require(
            self.setupPeriodStatus,
            "Setup period has ended"
        )
    }
    
}
