import SpaceKit

@Proxy enum CalleeControllerProxy {
    case deposit
    case withdraw(amount: BigUint)
    case getTotalDepositedAmount
}

@Controller struct MyController {
    
}
