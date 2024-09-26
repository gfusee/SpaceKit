import Space

@Proxy enum CalledContract {
    case .deposit
    case .withdraw(amount: BigUint)
    case .getTotalDepositedAmount
}

@Contract struct MyContract {
    public func callDeposit() {
        
    }
}
