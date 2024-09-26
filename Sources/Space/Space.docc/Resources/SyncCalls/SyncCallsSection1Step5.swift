import Space

@Proxy enum CalleeContractProxy {
    case .deposit
    case .withdraw(amount: BigUint)
}

@Contract struct MyContract {
    
}
