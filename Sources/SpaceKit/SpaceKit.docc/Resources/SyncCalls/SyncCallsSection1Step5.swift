import SpaceKit

@Proxy enum CalleeProxy {
    case deposit
    case withdraw(amount: BigUint)
}

@Controller struct MyController {
    
}
