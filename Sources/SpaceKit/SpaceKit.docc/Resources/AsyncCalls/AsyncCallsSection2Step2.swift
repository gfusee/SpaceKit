import SpaceKit

@Proxy enum CalleeProxy {
    case deposit
}

@Controller public struct MyController {
    
    public mutating func initiateDeposit(receiverAddress: Address) {
        
    }
    
}
