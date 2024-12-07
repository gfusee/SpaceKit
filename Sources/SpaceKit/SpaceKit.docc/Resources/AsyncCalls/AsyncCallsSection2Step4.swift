import SpaceKit

@Proxy enum CalleeControllerProxy {
    case deposit
}

@Controller struct MyController {
    
    public mutating func initiateDeposit(receiverAddress: Address) {
        let payment = Message.egldValue
        
        CalleeControllerProxy
            .deposit
            .registerPromise(
                receiver: receiverAddress,
                gas: 60_000_000,
                callback: // We will set this parameter later
            )
    }
    
}
