import Space

let PERCENTAGE_TOTAL: UInt64 = 100

@Contract struct TokenRelease {
    @Storage(key: "activationTimestamp") var activationTimestamp: UInt64
    @Storage(key: "tokenIdentifier") var tokenIdentifier: Buffer
    @Storage(key: "tokenTotalSupply") var tokenTotalSupply: BigUint
    @Storage(key: "setupPeriodStatus") var setupPeriodStatus: Bool
    @Mapping<Address, Address>(key: "addressChangeRequest") var addressChangeRequestForAddress
    @Mapping<Buffer, Schedule>(key: "groupSchedule") var groupScheduleForGroupIdentifier
    @Mapping<Address, Vector<Buffer>>(key: "userGroups") var userGroupsForAddress
    @Mapping<Buffer, UInt64>(key: "usersInGroup") var usersInGroupForGroupIdentifier
    @Mapping<Address, BigUint>(key: "claimedBalance") var claimedBalanceForAddress
    
    // TODO: use TokenIdentifier type once implemented
    init(tokenIdentifier: Buffer) {
        // TODO: add a require to check that the token identifier is valid (same as the Rust contract)
        
        self.tokenIdentifier = tokenIdentifier
        self.setupPeriodStatus = true
    }
    
    public mutating func addFixedAmountGroup(
        groupIdentifier: Buffer,
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
        
        groupScheduleMapper.set(newSchedule)
    }
    
    public mutating func addPercentageBasedGroup(
        groupIdentifier: Buffer,
        groupTotalAmount: BigUint,
        periodUnlockPercentage: UInt8,
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
            UInt64(periodUnlockPercentage) * releaseTicks == PERCENTAGE_TOTAL,
            "The final percentage is invalid"
        )
        
        let tokenTotalSupplyMapper = self.$tokenTotalSupply
        let tokenTotalSupply = tokenTotalSupplyMapper.get()
        tokenTotalSupplyMapper.set(tokenTotalSupply + groupTotalAmount)
        
        let unlockType = UnlockType.percentage(
            PercentageUnlockType(
                periodUnlockPercentage: periodUnlockPercentage,
                releasePeriod: releasePeriod,
                releaseTicks: releaseTicks
            )
        )
        
        let newSchedule = Schedule(
            groupTotalAmount: groupTotalAmount,
            unlockType: unlockType
        )
        
        groupScheduleMapper.set(newSchedule)
    }
    
    public mutating func removeGroup(groupIdentifier: Buffer) {
        assertOwner()
        
        self.requireSetupPeriodLive()
        
        let groupScheduleMapper = self.$groupScheduleForGroupIdentifier[groupIdentifier]
        
        require(
            !groupScheduleMapper.isEmpty(),
            "The group does not exist"
        )
        
        let schedule = groupScheduleMapper.get()
        self.tokenTotalSupply = self.tokenTotalSupply - schedule.groupTotalAmount
        groupScheduleMapper.clear()
        self.$usersInGroupForGroupIdentifier[groupIdentifier].clear()
    }
    
    public mutating func addUserGroup(
        address: Address,
        groupIdentifier: Buffer
    ) {
        assertOwner()
        
        self.requireSetupPeriodLive()
        
        let groupScheduleMapper = self.$groupScheduleForGroupIdentifier[groupIdentifier]
        
        require(
            !groupScheduleMapper.isEmpty(),
            "The group does not exist"
        )
        
        let userGroupsMapper = self.$userGroupsForAddress[address]
        let userGroups = userGroupsMapper.get()
        let userGroupsCount = userGroups.count
        
        var groupExists = false
        for groupIndex in 0..<userGroups.count {
            let group = userGroups.get(groupIndex)
            
            if group == groupIdentifier {
                groupExists = true
                break
            }
        }
        
        if !groupExists {
            let usersInGroupsMapper = self.$usersInGroupForGroupIdentifier[groupIdentifier]
            let usersInGroups = usersInGroupsMapper.get()
            usersInGroupsMapper.set(usersInGroups + 1)
            
            userGroupsMapper.set(userGroups.appended(groupIdentifier))
        }
    }
    
    public mutating func removeUser(address: Address) {
        assertOwner()
        
        self.requireSetupPeriodLive()
        
        let userGroupsMapper = self.$userGroupsForAddress[address]
        
        require(
            !userGroupsMapper.isEmpty(),
            "The address is not defined"
        )
        
        let addressGroup = userGroupsMapper.get()
        
        for groupIdentifierIndex in 0..<addressGroup.count {
            let groupIdentifier = addressGroup[groupIdentifierIndex]
            let usersInGroupMapper = self.$usersInGroupForGroupIdentifier[groupIdentifier]
            let usersInGroup = usersInGroupMapper.get()
            usersInGroupMapper.set(usersInGroup - 1)
        }
        
        userGroupsMapper.clear()
        self.$claimedBalanceForAddress[address].clear()
    }
    
    public mutating func requestAddressChange(newAddress: Address) {
        self.requireSetupPeriodEnded()
        
        let userAddress = Message.caller
        self.addressChangeRequestForAddress[userAddress] = newAddress
    }
    
    public mutating func approveAddressChange(userAddress: Address) {
        assertOwner()
        
        self.requireSetupPeriodEnded()
        
        let addressRequestChangeMapper = self.$addressChangeRequestForAddress[userAddress]
        require(
            !addressRequestChangeMapper.isEmpty(),
            "The address does not have a change request"
        )
        
        // Get old address values
        let newAddress = addressRequestChangeMapper.get()
        let userGroupsMapper = self.$userGroupsForAddress[userAddress]
        let userCurrentGroups = userGroupsMapper.get()
        let userClaimedBalanceMapper = self.$claimedBalanceForAddress[userAddress]
        let userClaimedBalance = userClaimedBalanceMapper.get()
        
        // Save the new address with the old address values
        self.userGroupsForAddress[newAddress] = userCurrentGroups
        self.claimedBalanceForAddress[newAddress] = userClaimedBalance
        
        // Delete the old address
        userGroupsMapper.clear()
        userClaimedBalanceMapper.clear()
        
        // Delete the change request
        addressRequestChangeMapper.clear()
    }
    
    public mutating func endSetupPeriod() {
        assertOwner()
        
        self.requireSetupPeriodLive()
        
        let tokenIdentifier = self.tokenIdentifier
        let totalMintTokens = self.tokenTotalSupply
        self.mintAllTokens(tokenIdentifier: tokenIdentifier, amount: totalMintTokens)
        self.activationTimestamp = Blockchain.getBlockTimestamp()
        self.setupPeriodStatus = false
    }
    
    public mutating func claimTokens() -> BigUint {
        self.requireSetupPeriodEnded()
        
        let tokenIdentifier = self.tokenIdentifier
        let caller = Message.caller
        let currentClaimableAmount = self.getClaimableTokens(address: caller)
        
        require(
            currentClaimableAmount > 0,
            "This address cannot currently claim any more tokens"
        )
        
        self.sendTokens(tokenIdentifier: tokenIdentifier, address: caller, amount: currentClaimableAmount)
        
        let claimedBalanceMapper = self.$claimedBalanceForAddress[caller]
        let claimedBalance = claimedBalanceMapper.get()
        claimedBalanceMapper.set(claimedBalance + currentClaimableAmount)
        
        return currentClaimableAmount
    }
    
    public func verifyAddressChange(address: Address) -> Address {
        self.addressChangeRequestForAddress[address]
    }
    
    public func getClaimableTokens(address: Address) -> BigUint {
        let totalClaimableAmount = self.calculateClaimableTokens(address: address)
        let currentBalance = self.claimedBalanceForAddress[address]
        
        if totalClaimableAmount > currentBalance {
            return totalClaimableAmount - currentBalance
        } else {
            return 0
        }
    }
    
    func calculateClaimableTokens(address: Address) -> BigUint {
        let startingTimestamp = self.activationTimestamp
        let currentTimestamp = Blockchain.getBlockTimestamp()
        let addressGroups = self.userGroupsForAddress[address]
        
        var claimableAmount: BigUint = 0
        
        // Compute the total claimable amount at the time of the request, for all of the user groups
        for groupIdentifierIndex in 0..<addressGroups.count {
            let groupIdentifier = addressGroups[groupIdentifierIndex]
            let schedule = self.groupScheduleForGroupIdentifier[groupIdentifier]
            let usersInGroupNo = self.usersInGroupForGroupIdentifier[groupIdentifier]
            let timePassed = currentTimestamp - startingTimestamp
            
            switch schedule.unlockType {
            case .fixedAmount(let fixedAmountData):
                var periodsPassed = timePassed / fixedAmountData.releasePeriod
                if periodsPassed == 0 {
                    continue
                }
                if periodsPassed > fixedAmountData.releaseTicks {
                    periodsPassed = fixedAmountData.releaseTicks
                }
                
                claimableAmount = claimableAmount + (BigUint(value: periodsPassed) * fixedAmountData.periodUnlockAmount / BigUint(value: usersInGroupNo))
            case .percentage(let percentageData):
                var periodsPassed = timePassed / percentageData.releasePeriod
                if periodsPassed == 0 {
                    continue
                }
                if periodsPassed > percentageData.releaseTicks {
                    periodsPassed = percentageData.releaseTicks
                }
                
                claimableAmount = claimableAmount + (BigUint(value: periodsPassed) * schedule.groupTotalAmount * BigUint(value: percentageData.periodUnlockPercentage) / BigUint(value: PERCENTAGE_TOTAL) / BigUint(value: usersInGroupNo))
            }
        }
        
        return claimableAmount
    }
    
    func sendTokens(
        tokenIdentifier: Buffer,
        address: Address,
        amount: BigUint
    ) {
        address.send(tokenIdentifier: tokenIdentifier, nonce: 0, amount: amount)
    }
    
    func mintAllTokens(
        tokenIdentifier: Buffer,
        amount: BigUint
    ) {
        Blockchain.mintTokens(
            tokenIdentifier: tokenIdentifier,
            nonce: 0,
            amount: amount
        )
    }
    
    func requireSetupPeriodLive() {
        require(
            self.setupPeriodStatus,
            "Setup period has ended"
        )
    }
    
    func requireSetupPeriodEnded() {
        require(
            !self.setupPeriodStatus,
            "Setup period is still active"
        )
    }
    
}
