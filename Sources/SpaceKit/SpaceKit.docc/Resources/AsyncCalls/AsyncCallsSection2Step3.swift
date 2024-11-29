import SpaceKit

@Proxy enum CalleeContractProxy {
    case deposit
}

@Contract struct MyContract {
    
    public mutating func initiateDeposit(receiverAddress: Address) {
        let payment = Message.egldValue
    }
    
}
