import SpaceKit

@Proxy enum CalleeContractProxy {
    case deposit
}

@Controller struct MyContract {
    
    public mutating func initiateDeposit(receiverAddress: Address) {
        
    }
    
}
