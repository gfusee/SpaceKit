import SpaceKit

@Proxy enum CalleeProxy {
    case deposit
    case withdraw(amount: BigUint)
    case getTotalDepositedAmount
}

@Controller struct MyController {
    public func callDeposit(receiverAddress: Address) {
        
    }
}
