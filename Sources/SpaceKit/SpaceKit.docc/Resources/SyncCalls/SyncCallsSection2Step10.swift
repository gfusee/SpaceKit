import SpaceKit

@Proxy enum CalleeProxy {
    case deposit
    case withdraw(amount: BigUint)
    case getTotalDepositedAmount
}

@Controller public struct MyController {
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
        let payment: TokenPayment = CalleeProxy
            .withdraw(amount: amount)
            .call(
                receiver: receiverAddress
            )
    }
}
