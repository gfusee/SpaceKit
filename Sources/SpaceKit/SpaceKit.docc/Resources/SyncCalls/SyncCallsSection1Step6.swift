import SpaceKit

@Proxy enum CalleeContractProxy {
    case deposit
    case withdraw(amount: BigUint)
    case getTotalDepositedAmount
}

@Contract struct MyContract {
    
}
