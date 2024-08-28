import MultiversX

@Proxy enum CryptoKittiesOwnershipProxy {
    case createGenZeroKitty
    case allowAuctioning(by: Address, kittyId: UInt32)
    case transfer(to: Address, kittyId: UInt32)
    case approveSiringAndReturnKitty(approvedAddress: Address, kittyOwner: Address, kittyId: UInt32)
}

@Contract struct CryptoKittiesAuction {
    @Storage(key: "kittyOwnershipContractAddress") var kittyOwnershipContractAddress: Address
    @Storage(key: "genZeroKittyStartingPrice") var genZeroKittyStartingPrice: BigUint
    @Storage(key: "genZeroKittyEndingPrice") var genZeroKittyEndingPrice: BigUint
    @Storage(key: "genZeroKittyAuctionDuration") var genZeroKittyAuctionDuration: UInt64
    @Mapping<UInt32, Auction>(key: "auction") var auctionForKittyId
    
    
    init(
        genZeroKittyStartingPrice: BigUint,
        genZeroKittyEndingPrice: BigUint,
        genZeroKittyAuctionDuration: UInt64,
        optKittyOwnershipContractAddress: OptionalArgument<Address>
    ) {
        self.genZeroKittyStartingPrice = genZeroKittyStartingPrice
        self.genZeroKittyEndingPrice = genZeroKittyEndingPrice
        self.genZeroKittyAuctionDuration = genZeroKittyAuctionDuration
        
        if let kittyOwnershipContractAddress = optKittyOwnershipContractAddress.intoOptional() {
            self.kittyOwnershipContractAddress = kittyOwnershipContractAddress
        }
    }
    
    public mutating func setKittyOwnershipContractAddress(address: Address) {
        assertOwner()
        
        self.kittyOwnershipContractAddress = address
    }
    
    public func createAndAuctionGenZeroKitty() {
        assertOwner()
        
        let kittyOwnershipContractAddress = self.getKittyOwnershipContractAddress()
        
        require(
            !kittyOwnershipContractAddress.isZero(),
            "Kitty Ownership contract address not set!"
        )
        
        // TODO: removing 10_000_000 is huge
        let gasLeft = Blockchain.getGasLeft() - 10_000_000
        let gasForCallback: UInt64 = 20_000_000
        
        let gasForExecution = gasLeft - gasForCallback
        
        CryptoKittiesOwnershipProxy
            .createGenZeroKitty
            .registerPromise(
                receiver: kittyOwnershipContractAddress,
                callbackName: "createGenZeroKittyCallback",
                gas: gasForExecution,
                gasForCallback: gasForCallback,
                callbackArgs: ArgBuffer()
            )
    }
    
    public func isUpForAuction(kittyId: UInt32) -> Bool {
        return !self.$auctionForKittyId[kittyId].isEmpty()
    }
    
    public func getAuctionStatus(kittyId: UInt32) -> Auction {
        require(
            self.isUpForAuction(kittyId: kittyId),
            "Kitty is not up for auction!"
        )
        
        return self.auctionForKittyId[kittyId]
    }
    
    public func getCurrentWinningBid(kittyId: UInt32) -> BigUint {
        require(
            self.isUpForAuction(kittyId: kittyId),
            "Kitty is not up for auction!"
        )
        
        return self.auctionForKittyId[kittyId].currentBid
    }
    
    public func createSaleAuction(
        kittyId: UInt32,
        startingPrice: BigUint,
        endingPrice: BigUint,
        duration: UInt64
    ) {
        let currentTimestamp = Blockchain.getBlockTimestamp()
        let deadline = currentTimestamp + duration
        
        require(
            !self.isUpForAuction(kittyId: kittyId),
            "kitty already auctioned!"
        )
        require(
            startingPrice > 0,
            "starting price must be higher than 0!"
        )
        require(
            startingPrice < endingPrice,
            "starting price must be less than ending price!"
        )
        require(
            deadline > currentTimestamp,
            "deadline can't be in the past!"
        )
        
        self.createAuction(
            auctionType: .selling,
            kittyId: kittyId,
            startingPrice: startingPrice,
            endingPrice: endingPrice,
            deadline: deadline
        )
    }
    
    public func createSiringAuction(
        kittyId: UInt32,
        startingPrice: BigUint,
        endingPrice: BigUint,
        duration: UInt64
    ) {
        let currentTimestamp = Blockchain.getBlockTimestamp()
        let deadline = currentTimestamp + duration
        
        require(
            !self.isUpForAuction(kittyId: kittyId),
            "kitty already auctioned!"
        )
        require(
            startingPrice > 0,
            "starting price must be higher than 0!"
        )
        require(
            startingPrice < endingPrice,
            "starting price must be less than ending price!"
        )
        require(
            deadline > currentTimestamp,
            "deadline can't be in the past!"
        )
        
        self.createAuction(
            auctionType: .siring,
            kittyId: kittyId,
            startingPrice: startingPrice,
            endingPrice: endingPrice,
            deadline: deadline
        )
    }
    
    public func bid(
        kittyId: UInt32
    ) {
        let payment = Message.egldValue
        
        require(
            self.isUpForAuction(kittyId: kittyId),
            "Kitty is not up for auction!"
        )
        
        let caller = Message.caller
        let auctionMapper = self.$auctionForKittyId[kittyId]
        var auction = auctionMapper.get()
        
        require(
            caller != auction.kittyOwner,
            "can't bid on your own kitty!"
        )
        require(
            Blockchain.getBlockTimestamp() < auction.deadline,
            "auction ended already!"
        )
        require(
            payment >= auction.startingPrice,
            "bid amount must be higher than or equal to starting price!"
        )
        require(
            payment > auction.currentBid,
            "bid amount must be higher than current winning bid!"
        )
        require(
            payment <= auction.endingPrice,
            "bid amount must be less than or equal to ending price!"
        )
        
        // refund losing bid
        if !auction.currentWinner.isZero() {
            auction.currentWinner
                .send(egldValue: auction.currentBid)
        }
        
        // update auction bid and winner
        auction.currentBid = payment
        auction.currentWinner = caller
        
        auctionMapper.set(auction)
    }
    
    public func endAuction(kittyId: UInt32) {
        require(
            self.isUpForAuction(kittyId: kittyId),
            "kitty is not up for auction!"
        )
        
        let auction = self.auctionForKittyId[kittyId]
        
        require(
            Blockchain.getBlockTimestamp() > auction.deadline || auction.currentBid == auction.endingPrice,
            "auction has not ended yet!"
        )
        
        if !auction.currentWinner.isZero() {
            switch auction.auctionType {
            case .selling:
                self.transferTo(
                    address: auction.currentWinner,
                    kittyId: kittyId
                )
            case .siring:
                self.approveSiringAndReturnKitty(
                    approvedAddress: auction.currentWinner,
                    kittyOwner: auction.kittyOwner,
                    kittyId: kittyId
                )
            }
        } else {
            // return kitty to its owner
            self.transferTo(
                address: auction.kittyOwner,
                kittyId: kittyId
            )
        }
    }
    
    mutating func startGenZeroKittyAuction(kittyId: UInt32) {
        let startingPrice = self.genZeroKittyStartingPrice
        let endingPrice = self.genZeroKittyEndingPrice
        let duration = self.genZeroKittyAuctionDuration
        let deadline = Blockchain.getBlockTimestamp() + duration
        
        let auction = Auction(
            auctionType: .selling,
            startingPrice: startingPrice,
            endingPrice: endingPrice,
            deadline: deadline,
            kittyOwner: Blockchain.getSCAddress(),
            currentBid: 0,
            currentWinner: Address()
        )
        
        self.auctionForKittyId[kittyId] = auction
    }
    
    func createAuction(
        auctionType: AuctionType,
        kittyId: UInt32,
        startingPrice: BigUint,
        endingPrice: BigUint,
        deadline: UInt64
    ) {
        let caller = Message.caller
        
        let kittyOwnershipContractAddress = self.getKittyOwnershipContractAddress()
        if !kittyOwnershipContractAddress.isZero() {
            // TODO: removing 10_000_000 is huge
            let gasLeft = Blockchain.getGasLeft() - 10_000_000
            let gasForCallback: UInt64 = 20_000_000
            
            let gasForExecution = gasLeft - gasForCallback
            
            var callbackArgs = ArgBuffer()
            callbackArgs.pushArg(arg: auctionType)
            callbackArgs.pushArg(arg: kittyId)
            callbackArgs.pushArg(arg: startingPrice)
            callbackArgs.pushArg(arg: endingPrice)
            callbackArgs.pushArg(arg: deadline)
            callbackArgs.pushArg(arg: caller)
            
            
            CryptoKittiesOwnershipProxy
                .allowAuctioning(
                    by: caller,
                    kittyId: kittyId
                )
                .registerPromise(
                    receiver: kittyOwnershipContractAddress,
                    callbackName: "allowAuctioningCallback",
                    gas: gasForExecution,
                    gasForCallback: gasForCallback,
                    callbackArgs: callbackArgs
                )
        }
    }
    
    func getKittyOwnershipContractAddress() -> Address {
        let kittyOwnershipContractAddressMapper = self.$kittyOwnershipContractAddress
        
        return if kittyOwnershipContractAddressMapper.isEmpty() {
            Address()
        } else {
            kittyOwnershipContractAddressMapper.get()
        }
    }
    
    func transferTo(
        address: Address,
        kittyId: UInt32
    ) {
        let kittyOwnershipContractAddress = self.getKittyOwnershipContractAddress()
        
        if !kittyOwnershipContractAddress.isZero() {
            // TODO: removing 10_000_000 is huge
            let gasLeft = Blockchain.getGasLeft() - 10_000_000
            let gasForCallback: UInt64 = 20_000_000
            
            let gasForExecution = gasLeft - gasForCallback
            
            var callbackArgs = ArgBuffer()
            callbackArgs.pushArg(arg: kittyId)
            
            CryptoKittiesOwnershipProxy
                .transfer(
                    to: address,
                    kittyId: kittyId
                )
                .registerPromise(
                    receiver: kittyOwnershipContractAddress,
                    callbackName: "transferCallback",
                    gas: gasForExecution,
                    gasForCallback: gasForCallback,
                    callbackArgs: callbackArgs
                )
        }
    }
    
    func approveSiringAndReturnKitty(
        approvedAddress: Address,
        kittyOwner: Address,
        kittyId: UInt32
    ) {
        let kittyOwnershipContractAddress = self.getKittyOwnershipContractAddress()
        
        if !kittyOwnershipContractAddress.isZero() {
            // TODO: removing 10_000_000 is huge
            let gasLeft = Blockchain.getGasLeft() - 10_000_000
            let gasForCallback: UInt64 = 20_000_000
            
            let gasForExecution = gasLeft - gasForCallback
            
            var callbackArgs = ArgBuffer()
            callbackArgs.pushArg(arg: kittyId)
            
            CryptoKittiesOwnershipProxy
                .approveSiringAndReturnKitty(
                    approvedAddress: approvedAddress,
                    kittyOwner: kittyOwner,
                    kittyId: kittyId
                )
                .registerPromise(
                    receiver: kittyOwnershipContractAddress,
                    callbackName: "transferCallback", // not a mistake, same callback for transfer and approveSiringAndReturnKitty
                    gas: gasForExecution,
                    gasForCallback: gasForCallback,
                    callbackArgs: callbackArgs
                )
        }
    }
    
    @Callback public mutating func createGenZeroKittyCallback() {
        let result: AsyncCallResult<UInt32> = Message.asyncCallResult()
        
        switch result {
        case .success(let kittyId):
            self.startGenZeroKittyAuction(kittyId: kittyId)
        case .error(_):
            // this can only fail if the kitty_ownership contract address is invalid
            // nothing to revert in case of error
            break
        }
    }
    
    @Callback public mutating func allowAuctioningCallback(
        auctionType: AuctionType,
        callbackKittyId: UInt32,
        startingPrice: BigUint,
        endingPrice: BigUint,
        deadline: UInt64,
        kittyOwner: Address
    ) {
        let result: AsyncCallResult<IgnoreValue> = Message.asyncCallResult()
        
        switch result {
        case .success(_):
            let auction = Auction(
                auctionType: auctionType,
                startingPrice: startingPrice,
                endingPrice: endingPrice,
                deadline: deadline,
                kittyOwner: kittyOwner,
                currentBid: 0,
                currentWinner: Address()
            )
            
            self.auctionForKittyId[callbackKittyId] = auction
        case .error(_):
            // nothing to revert in case of error
            break
        }
    }
    
    @Callback public mutating func transferCallback(callbackKittyId: UInt32) {
        let result: AsyncCallResult<IgnoreValue> = Message.asyncCallResult()
        
        switch result {
        case .success(_):
            let auctionMapper = self.$auctionForKittyId[callbackKittyId]
            let auction = auctionMapper.get()
            auctionMapper.clear()
            
            // send winning bid money to kitty owner
            // condition needed for gen zero kitties, since this sc is their owner
            // and for when no bid was made
            if auction.kittyOwner != Blockchain.getSCAddress() && !auction.currentWinner.isZero() {
                auction.kittyOwner
                    .send(egldValue: auction.currentBid)
            }
        case .error(_):
            // this can only fail if the kitty_ownership contract address is invalid
            // nothing to revert in case of error
            break
        }
    }
}
