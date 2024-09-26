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
}
