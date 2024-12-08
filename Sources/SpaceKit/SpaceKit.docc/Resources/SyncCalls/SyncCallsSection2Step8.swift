import SpaceKit

@Proxy enum CalleeProxy {
    case deposit
    case withdraw(amount: BigUint)
    case getTotalDepositedAmount
}

@Controller struct MyController {
    public func callDeposit(receiverAddress: Address) {
        let payment = Message.egldValue
        
        CalleeProxy
            .deposit
            .callAndIgnoreResult(
                receiver: receiverAddress,
                egldValue: payment
            )
    }
    
    public func callWithdraw(
        receiverAddress: Address,
        amount: BigUint
    ) {
        CalleeProxy
            .withdraw(amount: amount)
    }
}
