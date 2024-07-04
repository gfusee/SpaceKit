import MultiversX

// TODO: Use OptionalValue in the init when implemented

@Contract struct PingPong {
    @Storage(key: "pingAmount") var pingAmount: BigUint
    @Storage(key: "deadline") var deadline: UInt64
    @Storage(key: "activationTimestamp") var activationTimestamp: UInt64
    @Storage(key: "maxFunds") var maxFunds: BigUint?
    @Mapping(key: "userStatus") var userStatus: StorageMap<UInt32, UserStatus>
    @Storage(key: "pongAllLastUser") var pongAllLastUser: UInt32
    
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
    
    public func ping() {
        let payment = Message.egldValue
    }
}
