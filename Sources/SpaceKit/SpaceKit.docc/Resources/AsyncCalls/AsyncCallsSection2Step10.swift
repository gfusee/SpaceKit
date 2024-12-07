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
                callback: self.$depositCallback(
                    sentPayment: payment,
                    originalCaller: Message.caller,
                    gasForCallback: 50_000_000
                )
            )
    }
    
    @Callback public func depositCallback(sentPayment: BigUint, originalCaller: Address) {
        let result: AsyncCallResult<TokenPayment> = Message.asyncCallResult()
        
        switch result {
        case .success(let resultPayment):
            // The deposit is a success, we can send the payment to the original caller
            originalCaller.send(
                tokenIdentifier: resultPayment.tokenIdentifier,
                nonce: resultPayment.nonce,
                amount: resultPayment.amount
            )
        case .error(_):
            // The deposit is an error and the payment made in the async call has been cancelled.
            // We have to send it back to the original caller
            originalCaller.send(egldValue: sentPayment)
        }
    }
}
