import SpaceKit

@Proxy enum CalleeProxy {
    case deposit
}

@Controller struct MyController {
    
    public mutating func initiateDeposit(receiverAddress: Address) {
        
    }
    
}
