import Space

@Proxy enum CalleeContractProxy {
    case .deposit
    case .withdraw(amount: BigUint)
    case .getTotalDepositedAmount
}

@Contract struct MyContract {
    public func callDeposit() {
        let payment = Message.egldValue
        
        CalleeContractProxy
            .deposit
    }
}
