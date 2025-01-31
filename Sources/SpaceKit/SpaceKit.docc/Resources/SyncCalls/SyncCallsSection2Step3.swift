import SpaceKit

@Proxy enum CalleeProxy {
    case deposit
    case withdraw(amount: BigUint)
    case getTotalDepositedAmount
}

@Controller public struct MyController {
    public func callDeposit(receiverAddress: Address) {
        let payment = Message.egldValue
    }
}
