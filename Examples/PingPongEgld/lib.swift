import SpaceKit

// TODO: Assert in the @Controller macro that OptionalArgument args are the last ones

let PONG_ALL_LOW_GAS_LIMIT: UInt64 = 3_000_000

@Init func initialize(
    pingAmount: BigUint,
    durationInSeconds: UInt64,
    optActivationTimestamp: UInt64?,
    maxFunds: OptionalArgument<BigUint>
) {
    var controller = PingPong()
    
    controller.pingAmount = pingAmount
    let activationTimestamp = if let activationTimestamp = optActivationTimestamp {
        activationTimestamp
    } else {
        Blockchain.getBlockTimestamp()
    }
    
    let deadline = activationTimestamp + durationInSeconds
    controller.deadline = deadline
    controller.activationTimestamp = activationTimestamp
    controller.maxFunds = maxFunds.intoOptional()
}

@Controller struct PingPongController {
    @Storage(key: "pingAmount") var pingAmount: BigUint
    @Storage(key: "deadline") var deadline: UInt64
    @Storage(key: "activationTimestamp") var activationTimestamp: UInt64
    @Storage(key: "maxFunds") var maxFunds: BigUint?
    @UserMapping(key: "user") var users: UserMapper
    @Mapping(key: "userStatus") var userStatus: StorageMap<UInt32, UserStatus>
    @Storage(key: "pongAllLastUser") var pongAllLastUser: UInt32
    
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
                Blockchain.getBalance(
                    address: Blockchain.getSCAddress()
                ) <= maxFunds,
                "smart contract full"
            )
        }
        
        let caller = Message.caller
        let userId = self.users.getOrCreateUser(address: caller)
        let userStatus = self.userStatus[ifPresent: userId] ?? .new
        
        switch userStatus {
        case .new:
            self.userStatus[userId] = .registered
        case .registered:
            smartContractError(message: "can only ping once")
        case .withdrawn:
            smartContractError(message: "already withdrawn")
        }
    }
    
    mutating func pongByUserId(userId: UInt32) -> Buffer? {
        let userStatus = self.userStatus[ifPresent: userId] ?? .new
        
        switch userStatus {
        case .new:
            return "can't pong, never pinged"
        case .registered:
            guard let user = self.users.getUserAddress(id: userId) else {
                smartContractError(message: "unknown user")
            }
            
            self.userStatus[userId] = .withdrawn
            
            let amount = self.pingAmount
            user.send(egldValue: amount)
            
            return nil
        case .withdrawn:
            return "already withdrawn"
        }
    }
    
    public mutating func pong() {
        require(
            Blockchain.getBlockTimestamp() >= self.deadline,
            "can't withdraw before deadline"
        )
        
        let userId = self.users.getUserId(address: Message.caller)
        
        if let errorMessage = self.pongByUserId(userId: userId) {
            smartContractError(message: errorMessage)
        }
    }
    
    public mutating func pongAll() -> OperationCompletionStatus {
        require(
            Blockchain.getBlockTimestamp() >= self.deadline,
            "can't withdraw before deadline"
        )
        
        let usersCount = self.users.getUserCount()
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
            
            let _ = self.pongByUserId(userId: pongAllLastUser)
        }
    }
    
    // TODO: the original Rust contract returns a TopDecodeMulti type with multiple outputs
    // TODO: creating views for storages is annoying
    public func getUserAddresses() -> UserMapper {
        return self.users
    }
}
