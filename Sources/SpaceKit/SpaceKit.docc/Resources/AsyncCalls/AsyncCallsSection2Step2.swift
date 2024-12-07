import SpaceKit

@Proxy enum CalleeControllerProxy {
    case deposit
}

@Controller struct MyController {
    
    public mutating func initiateDeposit(receiverAddress: Address) {
        
    }
    
}
