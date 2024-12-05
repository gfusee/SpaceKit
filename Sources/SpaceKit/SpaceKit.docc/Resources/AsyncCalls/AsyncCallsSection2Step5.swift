import SpaceKit

@Proxy enum CalleeContractProxy {
    case deposit
}

@Controller struct MyContract {
    
    public mutating func initiateDeposit(receiverAddress: Address) {
        let payment = Message.egldValue
        
        CalleeContractProxy
            .deposit
            .registerPromise(
                receiver: receiverAddress,
                gas: 60_000_000,
                callback: // We will set this parameter later
            )
    }
    
    @Callback public func depositCallback(sentPayment: BigUint, originalCaller: Address) {
        
    }
}
