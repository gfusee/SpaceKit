import Space

@Proxy enum CalledContract {
    case .deposit
    case .withdraw(amount: BigUint)
}

@Contract struct MyContract {
    
}
