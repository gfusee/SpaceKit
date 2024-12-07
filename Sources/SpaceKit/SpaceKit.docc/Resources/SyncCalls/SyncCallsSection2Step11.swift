import SpaceKit

@Proxy enum CalleeControllerProxy {
    case deposit
    case withdraw(amount: BigUint)
    case getTotalDepositedAmount
}

@Controller struct MyController {
    public func callDeposit(receiverAddress: Address) {
        let payment = Message.egldValue
        
        CalleeControllerProxy
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
        let payment: TokenPayment = CalleeControllerProxy
            .withdraw(amount: amount)
            .call(
                receiver: receiverAddress
            )
        
        guard payment.amount > 0 else {
            smartContractError(message: "No payment received")
        }
    }
}
