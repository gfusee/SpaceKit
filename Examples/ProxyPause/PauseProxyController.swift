import SpaceKit

@Controller public struct PauseProxyController {
    @SetMapping<Address>(key: "owners") var allOwners
    @SetMapping<Address>(key: "contracts") var allContracts
    
    public func addContracts(contracts: MultiValueEncoded<Address>) {
        self.requireOwner()
        self.allContracts.extend(iterable: contracts)
    }
    
    public func removeContracts(contracts: MultiValueEncoded<Address>) {
        self.requireOwner()
        self.allContracts.removeAll(iterable: contracts)
    }
    
    public func addOwners(contracts: MultiValueEncoded<Address>) {
        self.requireOwner()
        self.allOwners.extend(iterable: contracts)
    }
    
    public func removeOwners(contracts: MultiValueEncoded<Address>) {
        self.requireOwner()
        self.allOwners.removeAll(iterable: contracts)
    }
    
    public func pause() {
        self.requireOwner()
        
        for contract in self.allContracts {
            PausableProxy.pause.callAndIgnoreResult(receiver: contract)
        }
    }
    
    public func unpause() {
        self.requireOwner()
        
        for contract in self.allContracts {
            PausableProxy.unpause.callAndIgnoreResult(receiver: contract)
        }
    }
    
    public func owners() -> SetMapper<Address> {
        return self.allOwners
    }
    
    public func contracts() -> SetMapper<Address> {
        return self.allContracts
    }
    
    func requireOwner() {
        require(
            self.allOwners.contains(value: Message.caller),
            "caller is not an owner"
        )
    }
    
}
