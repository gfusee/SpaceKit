import Space

@Proxy enum CalledContract {
    case .deposit
    case .withdraw(amount: BigUint)
    case .getTotalDepositedAmount
}

@Contract struct MyContract {
    public func callDeposit() {
        let payment = Message.egldValue
        
        CalledContract
            .deposit
            .callAndIgnoreResult(
                receiver: "<called contract's address>",
                egldValue: payment
            )
    }
    
    public func callWithdraw(amount: BigUint) {
        let payment: TokenPayment = CalledContract
            .withdraw(amount: amount)
            .call(
                receiver: "<called contract's address>"
            )
        
        guard payment.amount > 0 else {
            smartContractError(message: "No payment received")
        }
    }
}
