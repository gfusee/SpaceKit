import SpaceKit

@Proxy enum CalleeControllerProxy {
    case deposit
    case withdraw(amount: BigUint)
}

@Controller struct MyController {
    
}
