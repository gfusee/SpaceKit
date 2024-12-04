import SpaceKit

@Init func initialize(
    target: BigUint,
    deadline: UInt64,
    tokenIdentifier: Buffer
) {
    var controller = CrowdfundingEsdt()
    
    require(target > 0, "Target must be more than 0")
    controller.target = target

    require(
        deadline > Blockchain.getBlockTimestamp(),
        "Deadline can't be in the past"
    )
    controller.deadline = deadline

    // TODO: once the TokenIdentifier type is implemented, add a require to check if it is valid
    controller.tokenIdentifier = tokenIdentifier
}

@Contract struct CrowdfundingEsdt {
    @Storage(key: "target") var target: BigUint
    @Storage(key: "deadline") var deadline: UInt64
    @Mapping(key: "deposit") var depositForDonor: StorageMap<Address, BigUint>
    @Storage(key: "tokenIdentifier") var tokenIdentifier: Buffer

    public mutating func fund() {
        let allEsdtTransfers = Message.allEsdtTransfers
        let payment: TokenPayment = switch allEsdtTransfers.count {
            case 0:
                TokenPayment.new(
                    tokenIdentifier: "EGLD", // TODO: no hardcoded EGLD
                    nonce: 0,
                    amount: Message.egldValue
                )
            case 1:
                allEsdtTransfers[0]
            default:
                smartContractError(message: "wrong payment")
        }

        require(
            self.status() == .fundingPeriod,
            "cannot fund after deadline"
        )
        require(payment.tokenIdentifier == self.tokenIdentifier, "wrong token")

        let caller = Message.caller
        self.depositForDonor[caller] = self.depositForDonor[caller] + payment.amount
    }

    public mutating func claim() {
        switch self.status() {
            case .fundingPeriod:
                smartContractError(message: "cannot claim before deadline")
            case .successful:
                let caller = Message.caller
                require(
                    caller == Blockchain.getOwner(),
                    "only owner can claim successful funding"
                )

                let tokenIdentifier = self.tokenIdentifier
                let scBalance = self.getCurrentFunds()

                caller.send(tokenIdentifier: tokenIdentifier, nonce: 0, amount: scBalance)
            case .failed:
                let caller = Message.caller
                let deposit = self.depositForDonor[caller]

                if deposit > 0 {
                    let tokenIdentifier = self.tokenIdentifier

                    self.depositForDonor.clear(caller)
                    caller.send(tokenIdentifier: tokenIdentifier, nonce: 0, amount: deposit)
                }
        }
    }

    public func status() -> Status {
        if Blockchain.getBlockTimestamp() < self.deadline {
            return .fundingPeriod
        } else if self.getCurrentFunds() >= self.target {
            return .successful
        } else {
            return .failed
        }
    }

    public func getCurrentFunds() -> BigUint {
        let token = self.tokenIdentifier

        let scAddress = Blockchain.getSCAddress()
        if token == "EGLD" { // TODO: no hardcoded EGLD
            return Blockchain.getBalance(address: scAddress)
        } else {
            return Blockchain.getESDTBalance(address: scAddress, tokenIdentifier: tokenIdentifier, nonce: 0)
        }
    }
}
