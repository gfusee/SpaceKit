import Space

@Proxy enum CalleeContractProxy {
    case deposit
    case withdraw(amount: BigUint)
    case getTotalDepositedAmount
}

@Contract struct MyContract {
    public func callDeposit(receiverAddress: Address) {
        let payment = Message.egldValue
        
        CalleeContractProxy
            .deposit
    }
}
