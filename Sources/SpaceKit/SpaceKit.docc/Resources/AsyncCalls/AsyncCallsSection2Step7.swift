import SpaceKit

@Proxy enum CalleeProxy {
    case deposit
}

@Controller public struct MyController {
    
    public mutating func initiateDeposit(receiverAddress: Address) {
        let payment = Message.egldValue
        
        CalleeProxy
            .deposit
            .registerPromise(
                receiver: receiverAddress,
                gas: 60_000_000,
                callback: // We will set this parameter later
            )
    }
    
    @Callback public func depositCallback(sentPayment: BigUint, originalCaller: Address) {
        let result: AsyncCallResult<TokenPayment> = Message.asyncCallResult()
        
        switch result {
        case .success(let resultPayment):
            // The deposit is a success, we can send the payment to the original caller
            
        case .error(_):
            // The deposit is an error and the payment made in the async call has been cancelled.
            // We have to send it back to the original caller
            
        }
    }
}
