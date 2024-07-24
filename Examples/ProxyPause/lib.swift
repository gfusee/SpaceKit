import MultiversX

@Proxy enum PausableProxy {
    case pause
    case unpause
}

@Contract struct PauseProxy {
    
    @SetMapping<Address>(key: "owners") var allOwners
    @SetMapping<Address>(key: "contracts") var allContracts
    
    init() {
        let _ = self.allOwners.insert(value: Message.caller)
    }
    
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
    
    public func owners() -> SetMap<Address> {
        return self.allOwners
    }
    
    public func contracts() -> SetMap<Address> {
        return self.allContracts
    }
    
    func requireOwner() {
        require(
            self.allOwners.contains(Message.caller),
            "caller is not an owner"
        )
    }
    
}
