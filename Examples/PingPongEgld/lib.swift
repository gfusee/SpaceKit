import MultiversX

// TODO: Use OptionalValue in the init when implemented

let PONG_ALL_LOW_GAS_LIMIT: UInt64 = 3_000_000

@Contract struct PingPong {
    @Storage(key: "pingAmount") var pingAmount: BigUint
    @Storage(key: "deadline") var deadline: UInt64
    @Storage(key: "activationTimestamp") var activationTimestamp: UInt64
    @Storage(key: "maxFunds") var maxFunds: BigUint?
    @Storage(key: "users") var users: MXArray<Address> // TODO: This is not efficient, use a specific mapper once implemented
    @Mapping(key: "userStatus") var userStatus: StorageMap<Address, UserStatus>
    @Storage(key: "pongAllLastUser") var pongAllLastUser: Int32
    
    init(
        pingAmount: BigUint,
        durationInSeconds: UInt64,
        optActivationTimestamp: UInt64?,
        maxFunds: BigUint?
    ) {
        self.pingAmount = pingAmount
        let activationTimestamp = if let activationTimestamp = optActivationTimestamp {
            activationTimestamp
        } else {
            Blockchain.getBlockTimestamp()
        }
        
        let deadline = activationTimestamp + durationInSeconds
        self.deadline = deadline
        self.activationTimestamp = activationTimestamp
        self.maxFunds = maxFunds
    }
    
    public mutating func ping() {
        let payment = Message.egldValue
        
        require(
            payment == self.pingAmount,
            "the payment must match the fixed sum"
        )
        
        let blockTimestamp = Blockchain.getBlockTimestamp()
        
        require(
            self.activationTimestamp <= blockTimestamp,
            "smart contract not active yet"
        )
        
        require(
            blockTimestamp < self.deadline,
            "deadline has passed"
        )
        
        if let maxFunds = self.maxFunds {
            require(
                Blockchain.getSCBalance(
                    tokenIdentifier: "EGLD", // TODO: don't use hard coded EGLD value
                    nonce: 0
                ) <= maxFunds,
                "smart contract full"
            )
        }
        
        let caller = Message.caller
        let userStatus = self.userStatus[caller]
        
        switch userStatus {
        case .new:
            self.users = self.users.appended(caller)
            self.userStatus[caller] = .registered
        case .registered:
            smartContractError(message: "can only ping once")
        case .withdrawn:
            smartContractError(message: "already withdrawn")
        }
    }
    
    mutating func pongByUserAddress(user: Address) -> MXBuffer? {
        let userStatus = self.userStatus[user]
        
        switch userStatus {
        case .new:
            return "can't pong, never pinged"
        case .registered:
            self.userStatus[user] = .withdrawn
            
            let amount = self.pingAmount
            user.send(egldValue: amount)
        case .withdrawn:
            return "already withdrawn"
        }
    }
    
    public mutating func pong() {
        require(
            Blockchain.getBlockTimestamp() >= self.deadline,
            "can't withdraw before deadline"
        )
        
        if let errorMessage = self.pongByUserAddress(user: Message.caller) {
            smartContractError(message: errorMessage)
        }
    }
    
    public mutating func pongAll() -> OperationCompletionStatus {
        require(
            Blockchain.getBlockTimestamp() >= self.deadline,
            "can't withdraw before deadline"
        )
        
        let users = self.users
        let usersCount = users.count
        var pongAllLastUser = self.pongAllLastUser
        
        while true {
            if pongAllLastUser >= usersCount {
                self.pongAllLastUser = 0
                
                return .completed
            }
            
            if Blockchain.getGasLeft() < PONG_ALL_LOW_GAS_LIMIT {
                self.pongAllLastUser = pongAllLastUser
                
                return .interruptedBeforeOutOfGas
            }
            
            pongAllLastUser += 1
            
            let _ = self.pongByUserAddress(user: users[pongAllLastUser])
        }
    }
}
